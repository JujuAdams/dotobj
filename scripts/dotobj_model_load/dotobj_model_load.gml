/// Turns an ASCII .obj file, stored in a buffer, into a series of vertex buffers stored in a tree-like heirachy.
/// @jujuadams    contact@jujuadams.com
/// 
/// @param buffer          Buffer to read from
/// @param vertexFormat    Vertex format to use. See below for details on what vertex formats are supported
/// @param writeNormals    Whether to write normals into the vertex buffer. Set this to <false> if your vertex format does not contain normals
/// @param writeUVs        Whether to write texture coordinates into the vertex buffer. Set this to <false> if your vertex format does not contain texture coordinates
/// @param flipUVs         Whether to flip the y-axis (V-component) of the texture coordinates. This is useful to correct for DirectX / OpenGL idiosyncrasies
/// @param reverseTris     Whether to reverse the triangle definition order to be compatible with the culling mode of your choice (clockwise/counter-clockwise)
/// 
/// Returns: A dotobj model (an array).
/// 
/// 
/// 
/// This script expects the vertex format to be set up as follows:
/// - 3D Position
/// - Normal
/// - Colour
/// - Texture Coordinate
/// If your preferred vertex format does not have normals or texture coordinates,
/// use the "writeNormals" and/or "writeTexcoords" to toggle writing that data.
/// 
/// .obj format documentation can be found here:
/// http://paulbourke.net/dataformats/obj/
/// 
/// The .obj format does not natively support vertex colours; vertex colours will
/// default to white and 100% alpha. If you use a custom exporter that supports
/// vertex colours (such as MeshLab or MeshMixer) then vertex colours will be
/// respected in the final vertex buffer.
/// 
/// Texture coordinates for .obj models will typically be normalised and in the
/// range (0,0) -> (1,1). Please use another script to remap texture coordinates
/// to GameMaker's atlased UV space.
/// 
/// This .obj load does *not* support the following features:
/// - Smoothing groups
/// - Map libraries
/// - Freeform curve/surface geometry (NURBs/Bezier curves etc.)
/// - Line primitives
/// - Separate in-file LOD

if (DOTOBJ_OUTPUT_LOAD_TIME) var _timer = get_timer();

var _buffer            = argument0;
var _vformat           = argument1;
var _write_normals     = argument2;
var _write_texcoords   = argument3;
var _flip_texcoords    = argument4;
var _reverse_triangles = argument5;

//Create some variables to track errors
var _vec4_error            = false;
var _texture_depth_error   = false;
var _smoothing_group_error = false;
var _map_error             = false;
var _missing_positions     = 0;
var _missing_normals       = 0;
var _missing_uvs           = 0;
var _negative_references   = 0;


//Create some lists to store the .obj file's data
//We fill in the 0th element because .obj vertices are 1-indexed (!)
var _position_list = ds_list_create(); ds_list_add(_position_list, 0,0,0  );
var _colour_list   = ds_list_create(); ds_list_add(_colour_list,   1,1,1,1);
var _normal_list   = ds_list_create(); ds_list_add(_normal_list,   0,0,0  );
var _texture_list  = ds_list_create(); ds_list_add(_texture_list,  0,0    );

//Create a model for us to fill
//We add a default group and default mesh to the model for use later during parsing
var _model_array      = dotobj_new_model();
var _group_array      = dotobj_new_group(_model_array, __DOTOBJ_DEFAULT_GROUP, 0);
var _mesh_array       = dotobj_new_mesh(_group_array, __DOTOBJ_DEFAULT_MATERIAL_NAME);
var _mesh_vertex_list = _mesh_array[@ eDotObjMesh.VertexList];

//Handle materials
var _material_library  = __DOTOBJ_DEFAULT_MATERIAL_LIBRARY;
var _material_specific = __DOTOBJ_DEFAULT_MATERIAL_SPECIFIC;

//We keep a list of data per line
var _line_data_list = ds_list_create();

//Metadata
var _meta_line           = 1;
var _meta_vertex_buffers = 0;
var _meta_triangles      = 0;

//Start at the start of the buffer...
var _buffer_size = buffer_get_size(_buffer);
var _old_tell = buffer_tell(_buffer);
buffer_seek(_buffer, buffer_seek_start, 0);

//And let's iterate over the entire buffer, byte-by-byte
var _line_started = false;
var _value_read_start   = 0;
var _i = 0;
repeat(_buffer_size)
{
    //Grab a value
    var _value = buffer_read(_buffer, buffer_u8);
    ++_i;
    
    if (!_line_started)
    {
        //If we haven't found a valid starting character yet (i.e. a character that has ASCII code > 32)...
        
        if (_value > 32)
        {
            //If we find a valid starting character, update the line-start position and start reading the line!
            _value_read_start = buffer_tell(_buffer)-1;
            _line_started = true;
        }
    }
    else
    {
        if ((_value == 10) || (_value == 13) || (_value == 32) || (_i >= _buffer_size))
        {
            //Put in a null character at the breaking character so we can easily read the value
            if (_i < _buffer_size) buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0);
            
            //Jump back to the where the value started, then read it in as a string
            buffer_seek(_buffer, buffer_seek_start, _value_read_start);
            var _string = buffer_read(_buffer, buffer_string);
            if (_string != "") ds_list_add(_line_data_list, _string);
            
            //And reset our value read position for the next value
            _value_read_start = buffer_tell(_buffer);
            
            if (_value != 32)
            {
                //If we've reached the end of a line or the end of the buffer, process the line
                
                switch(_line_data_list[| 0]) //Use the first piece of data we read to determine what kind of line this is
                {
                    case "v": //Position
                        if (ds_list_size(_line_data_list) == 1+4)
                        {
                            if (DOTOBJ_OUTPUT_WARNINGS && !_vec4_error)
                            {
                                show_debug_message("dotobj_load(): Warning! 4-element vertex position data is for mathematical curves/surfaces. This is not supported. (ln=" + string(_meta_line) + ")");
                                _vec4_error = true;
                            }
                            break;
                        }
                        
                        //Add the position to our global list of positions
                        ds_list_add(_position_list, real(_line_data_list[| 1]), real(_line_data_list[| 2]), real(_line_data_list[| 3]));
                        
                        if (ds_list_size(_line_data_list) == 1+3+3)
                        {
                            //Three extra pieces of data: this is an RGB value
                            ds_list_add(_colour_list, real(_line_data_list[| 4]), real(_line_data_list[| 5]), real(_line_data_list[| 6]), 1);
                        }
                        else if (ds_list_size(_line_data_list) == 1+3+4)
                        {
                            //Four extra pieces of data: this is an RGBA value
                            ds_list_add(_colour_list, real(_line_data_list[| 4]), real(_line_data_list[| 5]), real(_line_data_list[| 6]), real(_line_data_list[| 7]));
                        }
                        else
                        {
                            //If we have insufficient data for this line, presume this vertex is white with 100%
                            ds_list_add(_colour_list, 1, 1, 1, 1);
                        }
                    break;
                    
                    case "vt": //Texture coordinate
                        if (ds_list_size(_line_data_list) == 1+3)
                        {
                            if (DOTOBJ_OUTPUT_WARNINGS && !_texture_depth_error)
                            {
                                switch(_line_data_list[| 3])
                                {
                                    case "0":
                                    case "0.0":
                                    case "0.00":
                                    case "0.000":
                                    case "0.0000":
                                    case "0.00000":
                                        //Ignore texture depths of exactly 0
                                    break;
                                    
                                    default:
                                        show_debug_message("dotobj_load(): Warning! Texture depth is not supported; W-component of the texture coordinate will be ignored. (ln=" + string(_meta_line) + ")");
                                        _texture_depth_error = true;
                                    break;
                                }
                            }
                        }
                        
                        //Add our UVs to the global list of UVs
                        ds_list_add(_texture_list, real(_line_data_list[| 1]), real(_line_data_list[| 2]));
                    break;
                    
                    case "vn": //Normal
                        //Add our normal to the global list of normals
                        ds_list_add(_normal_list, real(_line_data_list[| 1]), real(_line_data_list[| 2]), real(_line_data_list[| 3]));
                    break;
                    
                    case "f": //Face definition
                        var _line_data_size = ds_list_size(_line_data_list);
                        
                        //Add all triangles, vertex-by-vertex, defined by this face to the mesh's vertex list
                        _meta_triangles += _line_data_size-3;
                        var _f = 0;
                        repeat(_line_data_size-3)
                        {
                            if (!_reverse_triangles)
                            {
                                ds_list_add(_mesh_vertex_list, _line_data_list[| 1], _line_data_list[| 2+_f], _line_data_list[| 3+_f]);
                            }
                            else
                            {
                                ds_list_add(_mesh_vertex_list, _line_data_list[| 1], _line_data_list[| 3+_f], _line_data_list[| 2+_f]);
                            }
                            
                            ++_f;
                        }
                    break;
                    
                    case "l": //Line definition
                        if (DOTOBJ_OUTPUT_WARNINGS && !DOTOBJ_IGNORE_LINES) show_debug_message("dotobj_load(): Warning! Line primitives are not currently supported. (ln=" + string(_meta_line) + ")");
                    break;
                    
                    case "g": //Group definition
                        //Build the group name from all the line data
                        var _group_name = "";
                        var _i = 1;
                        var _size = ds_list_size(_line_data_list);
                        repeat(_size-1)
                        {
                            _group_name += _line_data_list[| _i] + ((_i < _size-1)? " " : "");
                            ++_i;
                        }
                        
                        //Create a new group and give it a blank mesh
                        var _group_array      = dotobj_new_group(_model_array, _group_name, _meta_line);
                        var _mesh_array       = dotobj_new_mesh(_group_array, __DOTOBJ_DEFAULT_MATERIAL_NAME);
                        var _mesh_vertex_list = _mesh_array[eDotObjMesh.VertexList];
                    break;
                    
                    case "o": //Object definition
                        //Build the object name from all the line data
                        var _group_name = "";
                        var _i = 1;
                        var _size = ds_list_size(_line_data_list);
                        repeat(_size-1)
                        {
                            _group_name += _line_data_list[| _i] + ((_i < _size-1)? " " : "");
                            ++_i;
                        }
                        
                        if (DOTOBJ_OBJECTS_ARE_GROUPS)
                        {
                            //If we want to parse objects as groups, create a new group and give it a blank mesh
                            var _group_array      = dotobj_new_group(_model_array, _group_name, _meta_line);
                            var _mesh_array       = dotobj_new_mesh(_group_array, __DOTOBJ_DEFAULT_MATERIAL_NAME);
                            var _mesh_vertex_list = _mesh_array[eDotObjMesh.VertexList];
                        }
                        else if (DOTOBJ_OUTPUT_WARNINGS)
                        {
                            show_debug_message("dotobj_load(): Warning! Object \"" + string(_string) + "\" found. Objects are not supported; use groups instead, or set DOTOBJ_OBJECTS_ARE_GROUPS to <true>. (ln=" + string(_meta_line) + ")");
                        }
                    break;
                    
                    case "s": //Section definition
                        if (DOTOBJ_OUTPUT_WARNINGS && !_smoothing_group_error)
                        {
                            show_debug_message("dotobj_load(): Warning! Smoothing groups are not currently supported. (ln=" + string(_meta_line) + ")");
                            _smoothing_group_error = true;
                        }
                    break;
                    
                    case "#": //Comments
                        if (DOTOBJ_OUTPUT_COMMENTS)
                        {
                            var _string = "";
                            var _i = 1;
                            var _size = ds_list_size(_line_data_list);
                            repeat(_size-1)
                            {
                                _string += _line_data_list[| _i] + ((_i < _size-1)? " " : "");
                                ++_i;
                            }
                            
                            show_debug_message("dotobj_load(): \"" + _string + "\"");
                        }
                    break;
                    
                    case "mtllib":
                        //Build the library name from all the line data
                        var _material_library = "";
                        var _i = 1;
                        var _size = ds_list_size(_line_data_list);
                        repeat(_size-1)
                        {
                            _material_library += _line_data_list[| _i] + ((_i < _size-1)? " " : "");
                            ++_i;
                        }
                        
                        if (DOTOBJ_OUTPUT_DEBUG) show_debug_message("dotobj_load(): Set material library to \"" + _material_library + "\"");
                    break;
                    
                    case "usemtl":
                        //Build the material name from all the line data
                        var _material_specific = "";
                        var _i = 1;
                        var _size = ds_list_size(_line_data_list);
                        repeat(_size-1)
                        {
                            _material_specific += _line_data_list[| _i] + ((_i < _size-1)? " " : "");
                            ++_i;
                        }
                        
                        //Then build a full material name from that
                        var _material_name = _material_library + "." + _material_specific;
                        
                        if ((_mesh_array[eDotObjMesh.Material] == __DOTOBJ_DEFAULT_MATERIAL_NAME) && ds_list_empty(_mesh_vertex_list))
                        {
                            //If our mesh's material hasn't been set and the vertex list is empty, set this mesh to use this material
                            _mesh_array[@ eDotObjMesh.Material] = _material_name;
                        }
                        else
                        {
                            //If our mesh's material has been set or we've added some vertices, create a new mesh to add triangles to
                            var _mesh_array = dotobj_new_mesh(_group_array, _material_name);
                            var _mesh_vertex_list = _mesh_array[eDotObjMesh.VertexList];
                        }
                    break;
                    
                    case "maplib":
                    case "usemap":
                        if (DOTOBJ_OUTPUT_WARNINGS && !_map_error)
                        {
                            show_debug_message("dotobj_load(): Warning! External texture map files are not currently supported. (ln=" + string(_meta_line) + ")");
                            _map_error = true;
                        }
                    break;
                    
                    case "shadow_obj":
                    case "trace_obj":
                        if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load(): Warning! \"" + string(_line_data_list[| 0]) + "\" is an external .obj reference. This is not supported. (ln=" + string(_meta_line) + ")");
                    break;
                    
                    case "vp":
                    case "cstype":
                    case "deg":
                    case "bmat":
                    case "step":
                    case "curv":
                    case "curv2":
                    case "surf":
                    case "end":
                    case "parm":
                    case "trim":
                    case "hole":
                    case "scrv":
                    case "sp":
                    case "con":
                    case "mg":
                    case "ctech":
                    case "stech":
                    case "bsp":   //Depreciated
                    case "bzp":   //Depreciated
                    case "cdc":   //Depreciated
                    case "cdp":   //Depreciated
                    case "res":   //Depreciated
                        if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load(): Warning! \"" + string(_line_data_list[| 0]) + "\" is for mathematical curves/surfaces. This is not supported. (ln=" + string(_meta_line) + ")");
                    break;
                    
                    case "lod":
                        if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load(): Warning! In-file LODs are not currently supported. (ln=" + string(_meta_line) + ")");
                    break;
                    
                    case "bevel":
                    case "c_interp":
                    case "d_interp":
                        if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load(): Warning! \"" + string(_line_data_list[| 0]) + "\" is a rendering attribute. This is not supported. (ln=" + string(_meta_line) + ")");
                    break;
                    
                    default: //Something else that we don't recognise!
                        if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load(): Warning! \"" + string(_line_data_list[| 0]) + "\" is not recognised. (ln=" + string(_meta_line) + ")");
                    break;
                }
                
                //Once we're done with the line, clear the data out and start again
                ds_list_clear(_line_data_list);
                _line_started = false;
            }
        }
    }
    
    //If we've hit a \n or \r character then increment our line counter
    if ((_value == 10) || (_value == 13)) ++_meta_line;
}

//Iterate over all the groups we've found
//If we're not returning arrays, the group map should only contain one group
var _group_map  = _model_array[eDotObjModel.GroupMap ];
var _group_list = _model_array[eDotObjModel.GroupList];

var _g = 0;
repeat(ds_list_size(_group_list))
{
    var _group_name = _group_list[| _g];
    
    //Find our list of faces for this group
    var _group_array     = _group_map[? _group_name];
    var _group_line      = _group_array[eDotObjGroup.Line    ];
    var _group_name      = _group_array[eDotObjGroup.Name    ];
    var _group_mesh_list = _group_array[eDotObjGroup.MeshList];
    
    var _mesh = 0;
    repeat(ds_list_size(_group_mesh_list))
    {
        var _mesh_array = _group_mesh_list[| _mesh];
        var _mesh_vertex_list = _mesh_array[eDotObjMesh.VertexList];
        var _mesh_material    = _mesh_array[eDotObjMesh.Material  ];
        
        if (DOTOBJ_OUTPUT_DEBUG) show_debug_message("dotobj_load(): Group \"" + _group_name + "\" (ln=" + string(_group_line) + ") mesh " + string(_mesh) + " uses material \"" + _mesh_material + "\" and has " + string(ds_list_size(_mesh_vertex_list)/3) + " triangles");
        
        //Check if this mesh is empty
        if (ds_list_size(_mesh_vertex_list) <= 0)
        {
            if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load(): Warning! Group \"" + string(_group_name) + "\" mesh " + string(_mesh) + " has no triangles");
            ++_mesh;
            continue;
        }
        
        //Check if this mesh's material exists
        var _material_array = global.__dotobj_material_library[? _mesh_material];
        if (_material_array == undefined)
        {
            if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load(): Warning! Material \"" + _mesh_material + "\" doesn't exist for group \"" + _group_name + "\" (ln=" + string(_group_line) + ") mesh " + string(_mesh) + ", using default material instead");
            _material_array = global.__dotobj_material_library[? __DOTOBJ_DEFAULT_MATERIAL_NAME];
        }
        
        //Create a vertex buffer for this mesh
        ++_meta_vertex_buffers;
        var _vbuff = vertex_create_buffer();
        _mesh_array[@ eDotObjMesh.VertexBuffer] = _vbuff;
        vertex_begin(_vbuff, _vformat);
        
        //Iterate over all the vertices
        var _i = 0;
        repeat(ds_list_size(_mesh_vertex_list))
        {
            //N.B. This whole vertex decoding thing that uses strings can probably be done earlier by parsing data as it comes out of the buffer
            //     This can definitely be improved in terms of speed!
            
            //Get the vertex string, and count how many slashes it contains
            var _vertex_string = _mesh_vertex_list[| _i++];
            var _slash_count = string_count("/", _vertex_string);
            
            //Reset our lookup indexes
            var _v_index = -1;
            var _t_index = -1;
            var _n_index = -1;
            
            //Reset our vertex data
            var _vx = undefined; //X
            var _vy = undefined; //Y
            var _vz = undefined; //Z
            var _cr = 1;         //Red
            var _cg = 1;         //Green
            var _cb = 1;         //Blue
            var _ca = 1;         //Alpha
            var _tx = 0;         //U
            var _ty = 0;         //V
            var _nx = 0;         //Normal X
            var _ny = 0;         //Normal Y
            var _nz = 0;         //Normal Z
            
            if (_slash_count == 0)
            {
                //If there are no slashes in the string, then it's a simple vertex position definition
                _v_index = _vertex_string;
                _t_index = -1;
                _n_index = -1;
            }
            else if (_slash_count == 1)
            {
                //If there's one slash in the string, then it's a position + texture coordinate definition
                _v_index = string_copy(  _vertex_string, 1, string_pos("/", _vertex_string)-1);
                _t_index = string_delete(_vertex_string, 1, string_pos("/", _vertex_string)  );
                _n_index = -1;
            }
            else if (_slash_count == 2)
            {
                //If there're two slashes in the string, then it could be one of two things...
                
                var _double_slash_count = string_count("//", _vertex_string);
                if (_double_slash_count == 0)
                {
                    //If we find no double slashes then this is a position + UV + normal defintion
                    _v_index       = string_copy(  _vertex_string, 1, string_pos( "/", _vertex_string)-1);
                    _vertex_string = string_delete(_vertex_string, 1, string_pos( "/", _vertex_string)  );
                    _t_index       = string_copy(  _vertex_string, 1, string_pos( "/", _vertex_string)-1);
                    _n_index       = string_delete(_vertex_string, 1, string_pos( "/", _vertex_string)  );
                }
                else if (_double_slash_count == 1)
                {
                    //If we find a single double slashes then this is a position + normal defintion
                    _vertex_string = string_replace(_vertex_string, "//", "/" );
                    _v_index       = string_copy(   _vertex_string, 1, string_pos("/", _vertex_string)-1);
                    _t_index       = -1;
                    _n_index       = string_delete( _vertex_string, 1, string_pos("/", _vertex_string)  );
                }
                else
                {
                    if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load(): Warning! Triangle " + string(_i) + " for group \"" + string(_group_name) + "\" has an unsupported number of slashes (" + string(_slash_count) + ")");
                    continue;
                }
            }
            else
            {
                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load(): Warning! Triangle " + string(_i) + " for group \"" + string(_group_name) + "\" has an unsupported number of slashes (" + string(_slash_count) + ")");
                continue;
            }
            
            //If we've got any blank strings set the indices to 0
            if (_v_index == "") _v_index = 0;
            if (_n_index == "") _n_index = 0;
            if (_t_index == "") _t_index = 0;
            
            _v_index = 3*floor(real(_v_index));
            _n_index = 3*floor(real(_n_index));
            _t_index = 2*floor(real(_t_index));
            
            //Some .obj file use negative references to look at data recently defined. This isn't supported!
            if ((_v_index < 0) || (_n_index < 0) || (_t_index < 0))
            {
                ++_negative_references;
                continue;
            }
            
            //Write the position
            _vx = _position_list[| _v_index  ]; //X
            _vy = _position_list[| _v_index+1]; //Y
            _vz = _position_list[| _v_index+2]; //Z
            
            //If we have some invalid data, log the warning, and move on to the next vertex
            //(Incidentally, if the position data is broken then the colour data will be broken too)
            if ((_vx == undefined) || (_vy == undefined) || (_vz == undefined))
            {
                ++_missing_positions;
                continue;
            }
            
            vertex_position_3d(_vbuff, _vx, _vy, _vz);
            
            //Write the normal
            if (_write_normals) 
            {
                if (_n_index >= 0)
                {
                    _nx = _normal_list[| _n_index  ]; //Normal X
                    _ny = _normal_list[| _n_index+1]; //Normal Y
                    _nz = _normal_list[| _n_index+2]; //Normal Z
                
                    //If we have some invalid data, log the warning, then default to (0,0,0)
                    if ((_nx == undefined) || (_ny == undefined) || (_nz == undefined))
                    {
                        ++_missing_normals;
                        _nx = 0;
                        _ny = 0;
                        _nz = 0;
                    }
                }
                
                vertex_normal(_vbuff, _nx, _ny, _nz);
            }
            
            //Write the colour
            _cr = _colour_list[| _v_index  ]*255; //Red
            _cg = _colour_list[| _v_index+1]*255; //Green
            _cb = _colour_list[| _v_index+2]*255; //Blue
            _ca = _colour_list[| _v_index+3];     //Alpha
            vertex_colour(_vbuff, make_colour_rgb(_cr, _cg, _cb), _ca);
            
            //Write the UVs
            if (_write_texcoords)
            {
                if (_t_index >= 0) 
                {
                    _tx = _texture_list[| _t_index  ]; //U
                    _ty = _texture_list[| _t_index+1]; //V
                
                    //If we have some invalid data, log the warning, then default to (0,0)
                    if ((_tx == undefined) || (_ty == undefined))
                    {
                        ++_missing_uvs;
                        _tx = 0;
                        _ty = 0;
                    }
                    else
                    {
                        if (_flip_texcoords) _ty = 1 - _ty;
                    }
                }
                
                vertex_texcoord(_vbuff, _tx, _ty);
            }
        }
        
        //Once we've finished iterating over the triangles, finish our vertex buffer
        vertex_end(_vbuff);
        
        //Clean up memory for meshes
        ds_list_destroy(_mesh_vertex_list);
        _mesh_array[@ eDotObjMesh.VertexList] = undefined;
        
        //Move to the next mesh
        ++_mesh;
    }
    
    //Move to the next group
    ++_g;
}

//Clean up our data structures
ds_list_destroy(_position_list );
ds_list_destroy(_colour_list   );
ds_list_destroy(_normal_list   );
ds_list_destroy(_texture_list  );
ds_list_destroy(_line_data_list);

//Return to the old tell position for the buffer
buffer_seek(_buffer, buffer_seek_start, _old_tell);

//Report errors if we found any
if (DOTOBJ_OUTPUT_WARNINGS)
{
    if (_negative_references > 0) show_debug_message("dotobj_load(): Warning! .obj had negative position references (x" + string(_negative_references) + ")");
    if (_missing_positions   > 0) show_debug_message("dotobj_load(): Warning! .obj referenced missing positions (x"     + string(_missing_positions  ) + ")");
    if (_missing_normals     > 0) show_debug_message("dotobj_load(): Warning! .obj referenced missing normals (x"       + string(_missing_normals    ) + ")");
    if (_missing_uvs         > 0) show_debug_message("dotobj_load(): Warning! .obj referenced missing UVs (x"           + string(_missing_uvs        ) + ")");
}

//If we want to report the load time, do it!
if (DOTOBJ_OUTPUT_LOAD_TIME) show_debug_message("dotobj_load(): lines=" + string(_meta_line) + ", vertex buffers=" + string(_meta_vertex_buffers) + ", triangles=" + string(_meta_triangles) + ". Time to load was " + string((get_timer() - _timer)/1000) + "ms");

//Return our data
return _model_array;