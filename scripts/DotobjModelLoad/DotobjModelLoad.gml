/// Turns an ASCII .obj file, stored in a buffer, into a series of vertex buffers stored in a tree-like heirachy.
/// @jujuadams    contact@jujuadams.com
/// 
/// @param buffer   Buffer to read from
/// 
/// Returns: A dotobj model (a struct)
///          This model can be drawn using the submit() method e.g. sponza_model.submit();
/// 
/// 
/// 
/// This script uses a vertex format laid out as follows:
/// - 3D Position
/// - Normal
/// - Colour
/// - Texture Coordinate
/// If a model has missing data, then a suitable default value will be used instead
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

function DotobjModelLoad(_buffer)
{
    if (DOTOBJ_OUTPUT_LOAD_TIME) var _timer = get_timer();

    //Create some variables to track errors
    var _vec4_error            = false;
    var _texture_depth_error   = false;
    var _smoothing_group_error = false;
    var _map_error             = false;
    var _missing_positions     = 0;
    var _missing_normals       = 0;
    var _missing_uvs           = 0;
    var _negative_references   = 0;
    
    var _flip_texcoords           = global.__dotobjFlipTexcoordV;
    var _reverse_triangles        = global.__dotobjReverseTriangles;
    var _write_tangents           = global.__dotobjWriteTangents;
    var _force_calculate_tangents = global.__dotobjForceTangentCalc;


    //Create some lists to store the .obj file's data
    //We fill in the 0th element because .obj vertices are 1-indexed (!)
    var _position_list = ds_list_create(); ds_list_add(_position_list, 0,0,0  );
    var _colour_list   = ds_list_create(); ds_list_add(_colour_list,   1,1,1,1);
    var _normal_list   = ds_list_create(); ds_list_add(_normal_list,   0,0,0  );
    var _texture_list  = ds_list_create(); ds_list_add(_texture_list,  0,0    );

    //Create a model for us to fill
    //We add a default group and default mesh to the model for use later during parsing
    var _model_struct        = new DotobjClassModel();
    var _group_struct        = __DotobjEnsureGroup(_model_struct, __DOTOBJ_DEFAULT_GROUP, 0);
    var _mesh_primitive      = global.__dotobjWireframe? pr_linelist : pr_trianglelist;
    var _mesh_struct         = new DotobjClassMesh(_group_struct, __DOTOBJ_DEFAULT_MATERIAL_NAME, _write_tangents, _mesh_primitive);
    var _mesh_vertexes_array = _mesh_struct.vertexes_array;

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
                                    show_debug_message("DotobjModelLoad(): Warning! 4-element vertex position data is for mathematical curves/surfaces. This is not supported. (ln=" + string(_meta_line) + ")");
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
                                            show_debug_message("DotobjModelLoad(): Warning! Texture depth is not supported; W-component of the texture coordinate will be ignored. (ln=" + string(_meta_line) + ")");
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
                                    array_push(_mesh_vertexes_array, _line_data_list[| 1], _line_data_list[| 2+_f], _line_data_list[| 3+_f]);
                                }
                                else
                                {
                                    array_push(_mesh_vertexes_array, _line_data_list[| 1], _line_data_list[| 3+_f], _line_data_list[| 2+_f]);
                                }
                            
                                ++_f;
                            }
                        break;
                    
                        case "l": //Line definition
                            if (DOTOBJ_OUTPUT_WARNINGS && !DOTOBJ_IGNORE_LINES) show_debug_message("DotobjModelLoad(): Warning! Line primitives are not currently supported. (ln=" + string(_meta_line) + ")");
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
                            var _group_struct        = __DotobjEnsureGroup(_model_struct, _group_name, _meta_line);
                            var _mesh_struct         = new DotobjClassMesh(_group_struct, __DOTOBJ_DEFAULT_MATERIAL_NAME, _write_tangents, _mesh_primitive);
                            var _mesh_vertexes_array = _mesh_struct.vertexes_array;
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
                                var _group_struct        = __DotobjEnsureGroup(_model_struct, _group_name, _meta_line);
                                var _mesh_struct         = new DotobjClassMesh(_group_struct, __DOTOBJ_DEFAULT_MATERIAL_NAME, _write_tangents, _mesh_primitive);
                                var _mesh_vertexes_array = _mesh_struct.vertexes_array;
                            }
                            else if (DOTOBJ_OUTPUT_WARNINGS)
                            {
                                show_debug_message("DotobjModelLoad(): Warning! Object \"" + string(_string) + "\" found. Objects are not supported; use groups instead, or set DOTOBJ_OBJECTS_ARE_GROUPS to <true>. (ln=" + string(_meta_line) + ")");
                            }
                        break;
                    
                        case "s": //Section definition
                            if (DOTOBJ_OUTPUT_WARNINGS && !_smoothing_group_error)
                            {
                                show_debug_message("DotobjModelLoad(): Warning! Smoothing groups are not currently supported. (ln=" + string(_meta_line) + ")");
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
                            
                                show_debug_message("DotobjModelLoad(): \"" + _string + "\"");
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
                            
                            if (DOTOBJ_OUTPUT_DEBUG) show_debug_message("DotobjModelLoad(): Requires \"" + _material_library + "\"");
                            DotobjMaterialLoadFile(_material_library);
                            if (DOTOBJ_OUTPUT_DEBUG) show_debug_message("DotobjModelLoad(): Set material library to \"" + _material_library + "\"");
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
                        
                            if ((_mesh_struct.material == __DOTOBJ_DEFAULT_MATERIAL_NAME) && (array_length(_mesh_vertexes_array) <= 0))
                            {
                                //If our mesh's material hasn't been set and the vertex list is empty, set this mesh to use this material
                                _mesh_struct.material = _material_name;
                            }
                            else
                            {
                                //If our mesh's material has been set or we've added some vertices, create a new mesh to add triangles to
                                var _mesh_struct         = new DotobjClassMesh(_group_struct, _material_name, _write_tangents, _mesh_primitive);
                                var _mesh_vertexes_array = _mesh_struct.vertexes_array;
                            }
                        break;
                    
                        case "maplib":
                        case "usemap":
                            if (DOTOBJ_OUTPUT_WARNINGS && !_map_error)
                            {
                                show_debug_message("DotobjModelLoad(): Warning! External texture map files are not currently supported. (ln=" + string(_meta_line) + ")");
                                _map_error = true;
                            }
                        break;
                    
                        case "shadow_obj":
                        case "trace_obj":
                            if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("DotobjModelLoad(): Warning! \"" + string(_line_data_list[| 0]) + "\" is an external .obj reference. This is not supported. (ln=" + string(_meta_line) + ")");
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
                            if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("DotobjModelLoad(): Warning! \"" + string(_line_data_list[| 0]) + "\" is for mathematical curves/surfaces. This is not supported. (ln=" + string(_meta_line) + ")");
                        break;
                    
                        case "lod":
                            if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("DotobjModelLoad(): Warning! In-file LODs are not currently supported. (ln=" + string(_meta_line) + ")");
                        break;
                    
                        case "bevel":
                        case "c_interp":
                        case "d_interp":
                            if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("DotobjModelLoad(): Warning! \"" + string(_line_data_list[| 0]) + "\" is a rendering attribute. This is not supported. (ln=" + string(_meta_line) + ")");
                        break;
                    
                        default: //Something else that we don't recognise!
                            if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("DotobjModelLoad(): Warning! \"" + string(_line_data_list[| 0]) + "\" is not recognised. (ln=" + string(_meta_line) + ")");
                        break;
                    }
                
                    //Once we're done with the line, clear the data out and start again
                    ds_list_clear(_line_data_list);
                    _line_started = false;
                }
            }
        }
    
        //If we've hit a \n or \r character then increment our line counter
        if ((_value == 10) || (_value == 13)) _meta_line++;
    }
    
    //If we're writing tangents, initialise those lists
    if (_write_tangents)
    {
        var _tangent_list   = ds_list_create();
        var _bitangent_list = ds_list_create();
        
        //Each list should be the same size as the position list - we have one tangent vector and one bitangent vector for every position
        //(Tangents/Bitangents are stored as vec3, like positions, so this all lines up nicely)
        _tangent_list[|   ds_list_size(_position_list)-1] = 0;
        _bitangent_list[| ds_list_size(_position_list)-1] = 0;
    }
    
    //Iterate over all the groups we've found
    //If we're not returning arrays, the group map should only contain one group
    var _groups_array = _model_struct.groups_array;

    var _g = 0;
    repeat(array_length(_groups_array))
    {
        //Find our list of faces for this group
        var _group_struct       = _groups_array[_g];
        var _group_line         = _group_struct.line;
        var _group_name         = _group_struct.name;
        var _group_meshes_array = _group_struct.meshes_array;
    
        var _mesh = 0;
        repeat(array_length(_group_meshes_array))
        {
            var _mesh_struct         = _group_meshes_array[_mesh];
            var _mesh_vertexes_array = _mesh_struct.vertexes_array;
            var _mesh_material       = _mesh_struct.material;
            var _mesh_primitive      = _mesh_struct.primitive; 
            
            if (DOTOBJ_OUTPUT_DEBUG) show_debug_message("DotobjModelLoad(): Group \"" + _group_name + "\" (ln=" + string(_group_line) + ") mesh " + string(_mesh) + " uses material \"" + _mesh_material + "\" and has " + string(array_length(_mesh_vertexes_array)) + " vertexes (" + string(array_length(_mesh_vertexes_array)/3) + " triangles)");
        
            //Check if this mesh is empty
            if (array_length(_mesh_vertexes_array) <= 0)
            {
                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("DotobjModelLoad(): Warning! Group \"" + string(_group_name) + "\" mesh " + string(_mesh) + " has no triangles");
                ++_mesh;
                continue;
            }
        
            //Check if this mesh's material exists
            var _material_struct = global.__dotobjMaterialLibrary[? _mesh_material];
            if (_material_struct == undefined)
            {
                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("DotobjModelLoad(): Warning! Material \"" + _mesh_material + "\" doesn't exist for group \"" + _group_name + "\" (ln=" + string(_group_line) + ") mesh " + string(_mesh) + ", using default material instead");
                _material_struct = global.__dotobjMaterialLibrary[? __DOTOBJ_DEFAULT_MATERIAL_NAME];
            }
            
            //Calculate tangents/bitangents for every point that this group uses
            var _write_null_tangent = false;
            if (_write_tangents)
            {
                var _material_struct = global.__dotobjMaterialLibrary[? _mesh_material];
                if ((_material_struct.normal_map == undefined) && !_force_calculate_tangents)
                {
                    _write_null_tangent = true;
                }
                else
                {
                    //To make tangent/bitangent calculation easier, we're going to unpack our position/texture indexes into a list
                    //Really, we should be building this list as we parse the .obj file, but that's an optimisation for another day...
                    var _unpacked_mesh_vertex_list = ds_list_create();
                    
                    //Iterate over all the vertices
                    var _i = 0;
                    repeat(array_length(_mesh_vertexes_array))
                    {
                        //Get the vertex string, and find the first slash
                        var _vertex_string = _mesh_vertexes_array[_i];
                        _i++;
                        var _slash_count = string_count("/", _vertex_string);
                        
                        if (_slash_count == 0)
                        {
                            //If there are no slashes in the string, then it's a simple vertex position definition
                            //We can't calculate a tangent without texture coordinates, bail
                            if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("DotobjModelLoad(): Warning! Triangle " + string(_i) + " for group \"" + string(_group_name) + "\" has no texture information, tangent cannot be computed");
                            ds_list_add(_unpacked_mesh_vertex_list, undefined, undefined);
                            continue;
                        }
                        else if (_slash_count == 1)
                        {
                            //If there's one slash in the string, then it's a position + texture coordinate definition
                            _v_index = string_copy(  _vertex_string, 1, string_pos("/", _vertex_string)-1);
                            _t_index = string_delete(_vertex_string, 1, string_pos("/", _vertex_string)  );
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
                            }
                            else if (_double_slash_count == 1)
                            {
                                //If we find a single double slash then this is a position + normal defintion
                                //We can't calculate a tangent without texture coordinates, bail
                                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("DotobjModelLoad(): Warning! Triangle " + string(_i) + " for group \"" + string(_group_name) + "\" has no texture information, tangent cannot be computed");
                                ds_list_add(_unpacked_mesh_vertex_list, undefined, undefined);
                                continue;
                            }
                            else
                            {
                                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("DotobjModelLoad(): Warning! Triangle " + string(_i) + " for group \"" + string(_group_name) + "\" has an unsupported number of slashes (" + string(_slash_count) + ")");
                                ds_list_add(_unpacked_mesh_vertex_list, undefined, undefined);
                                continue;
                            }
                        }
                        else
                        {
                            if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("DotobjModelLoad(): Warning! Triangle " + string(_i) + " for group \"" + string(_group_name) + "\" has an unsupported number of slashes (" + string(_slash_count) + ")");
                            ds_list_add(_unpacked_mesh_vertex_list, undefined, undefined);
                            continue;
                        }
                        
                        //Store the position and texture index in our unpacked list
                        ds_list_add(_unpacked_mesh_vertex_list, 3*real(_v_index), 2*real(_t_index));
                    }
                    
                    //Iterate over all the vertices again, this time FOR REAL
                    var _i = 0;
                    repeat(ds_list_size(_unpacked_mesh_vertex_list) div 6) //Triangles are defined as 3 points, and each point has a position and texture index
                    {
                        //Extract our position indexes
                        var _pos_index_1 = _unpacked_mesh_vertex_list[| _i  ];
                        var _pos_index_2 = _unpacked_mesh_vertex_list[| _i+2];
                        var _pos_index_3 = _unpacked_mesh_vertex_list[| _i+4];
                        
                        //Extract our texture indexes
                        var _tex_index_1 = _unpacked_mesh_vertex_list[| _i+1];
                        var _tex_index_2 = _unpacked_mesh_vertex_list[| _i+3];
                        var _tex_index_3 = _unpacked_mesh_vertex_list[| _i+5];
                        
                        //Fetch position/texture data for point 1
                        var _in_x1 = _position_list[| _pos_index_1  ]; //X
                        var _in_y1 = _position_list[| _pos_index_1+1]; //Y
                        var _in_z1 = _position_list[| _pos_index_1+2]; //Z
                        var _in_u1 = _texture_list[|  _tex_index_1  ]; //U
                        var _in_v1 = _texture_list[|  _tex_index_1+1]; //V
                        
                        //Fetch position/texture data for point 2
                        var _in_x2 = _position_list[| _pos_index_2  ]; //X
                        var _in_y2 = _position_list[| _pos_index_2+1]; //Y
                        var _in_z2 = _position_list[| _pos_index_2+2]; //Z
                        var _in_u2 = _texture_list[|  _tex_index_2  ]; //U
                        var _in_v2 = _texture_list[|  _tex_index_2+1]; //V
                        
                        //Fetch position/texture data for point 3
                        var _in_x3 = _position_list[| _pos_index_3  ]; //X
                        var _in_y3 = _position_list[| _pos_index_3+1]; //Y
                        var _in_z3 = _position_list[| _pos_index_3+2]; //Z
                        var _in_u3 = _texture_list[|  _tex_index_3  ]; //U
                        var _in_v3 = _texture_list[|  _tex_index_3+1]; //V
                        
                        //Not sure if this is needed, but it's in here just in case
                        //if (_flip_texcoords)
                        //{
                        //    _in_v1 = 1 - _in_v1;
                        //    _in_v2 = 1 - _in_v2;
                        //    _in_v3 = 1 - _in_v3;
                        //}
                        
                        //Find the position/texture vectors from point 1 to point 2
                        var _x1 = _in_x2 - _in_x1;
                        var _y1 = _in_y2 - _in_y1;
                        var _z1 = _in_z2 - _in_z1;
                        var _u1 = _in_u2 - _in_u1;
                        var _v1 = _in_v2 - _in_v1;
                        
                        //Find the position/texture vectors from point 1 to point 3
                        var _x2 = _in_x3 - _in_x1;
                        var _y2 = _in_y3 - _in_y1;
                        var _z2 = _in_z3 - _in_z1;
                        var _u2 = _in_u3 - _in_u1;
                        var _v2 = _in_v3 - _in_v1;
                        
                        //Uuh... Not sure what this bit does...
                        var _r = _u1*_v2 - _u2*_v1;
                        if (_r != 0)
                        {
                            //Speeeeeeed
                            _r = 1/_r;
                            
                            var _tx = (_v2*_x1 - _v1*_x2) * _r
                            var _ty = (_v2*_y1 - _v1*_y2) * _r
                            var _tz = (_v2*_z1 - _v1*_z2) * _r
                            
                            var _bx = (_u1*_x2 - _u2*_x1) * _r
                            var _by = (_u1*_y2 - _u2*_y1) * _r
                            var _bz = (_u1*_z2 - _u2*_z1) * _r
                            
                            //show_debug_message("t = " + string(_tx) + "," + string(_ty) + "," + string(_tz));
                            //show_debug_message("b = " + string(_bx) + "," + string(_by) + "," + string(_bz));
                            
                            //Update the tangents I guess?
                            _tangent_list[|   _pos_index_1] += _tx;
                            _tangent_list[|   _pos_index_2] += _ty;
                            _tangent_list[|   _pos_index_3] += _tz;
                            
                            //And the bitangents too, why not  
                            _bitangent_list[| _pos_index_1] += _bx;
                            _bitangent_list[| _pos_index_2] += _by;
                            _bitangent_list[| _pos_index_3] += _bz;
                        }
                        //else
                        //{
                        //    //I don't think this warning is meaningful
                        //    //We get (r==0) values when texture coordinates for a triangle are degenerate, and
                        //    // in those situations we probably want to not adjust the position's tangent/bitangent
                        //    if (DOTOBJ_OUTPUT_WARNINGS)
                        //    {
                        //        show_debug_message("DotobjModelLoad(): WARNING! (r == 0), input values follow:");
                        //        show_debug_message("                     " + string(_in_u1) + ", " + string(_in_v1));
                        //        show_debug_message("                     " + string(_in_u2) + ", " + string(_in_v2));
                        //        show_debug_message("                     " + string(_in_u3) + ", " + string(_in_v3));
                        //        show_debug_message("                     -->");
                        //        show_debug_message("                     " + string(_u1) + ", " + string(_v1));
                        //        show_debug_message("                     " + string(_u2) + ", " + string(_v2));
                        //        show_debug_message("                     -->");
                        //        show_debug_message("                     " + string(_u1*_v2) + " - " + string(_u2*_v1));
                        //    }
                        //}
                        
                        //Next triangle!
                        _i += 6;
                    }
                }
            }
            
            //Create a vertex buffer for this mesh
            ++_meta_vertex_buffers;
            var _vbuff = vertex_create_buffer();
            _mesh_struct.vertex_buffer = _vbuff;
            vertex_begin(_vbuff, _write_tangents? global.__dotobjPNCTTanVertexFormat : global.__dotobjPNCTVertexFormat);
            
            //Iterate over all the vertices
            var _i = 0;
            var _line_counter = 0;
            
            var _repeat_count = array_length(_mesh_vertexes_array);
            
            //Add extra repeats for line writing
            if (_mesh_primitive) _repeat_count *= 2;
            
            repeat(_repeat_count)
            {
                //Reset our lookup indexes
                var _v_index = undefined;
                var _t_index = undefined;
                var _n_index = undefined;
                
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
                
                //Do some shenanigans to get lines to write fully
                if (_mesh_primitive)
                {
                    if (_line_counter == 2)
                    {
                        _i--;
                    }
                    else if (_line_counter == 4)
                    {
                        _i--;
                    }
                    else if (_line_counter == 5)
                    {
                        _i -= 3;
                    }
                    else if (_line_counter == 6)
                    {
                        _line_counter = 0;
                        _i += 2;
                    }
                    
                    _line_counter++;
                }
                
                //N.B. This whole vertex decoding thing that uses strings can probably be done earlier by parsing data as it comes out of the buffer
                //     This can definitely be improved in terms of speed!
            
                //Get the vertex string, and count how many slashes it contains
                var _vertex_string = _mesh_vertexes_array[_i];
                _i++;
                
                var _slash_count = string_count("/", _vertex_string);
                if (_slash_count == 0)
                {
                    //If there are no slashes in the string, then it's a simple vertex position definition
                    _v_index = _vertex_string;
                    _t_index = undefined;
                    _n_index = undefined;
                }
                else if (_slash_count == 1)
                {
                    //If there's one slash in the string, then it's a position + texture coordinate definition
                    _v_index = string_copy(  _vertex_string, 1, string_pos("/", _vertex_string)-1);
                    _t_index = string_delete(_vertex_string, 1, string_pos("/", _vertex_string)  );
                    _n_index = undefined;
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
                        //If we find a single double slash then this is a position + normal defintion
                        _vertex_string = string_replace(_vertex_string, "//", "/" );
                        _v_index       = string_copy(   _vertex_string, 1, string_pos("/", _vertex_string)-1);
                        _t_index       = undefined;
                        _n_index       = string_delete( _vertex_string, 1, string_pos("/", _vertex_string)  );
                    }
                    else
                    {
                        if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("DotobjModelLoad(): Warning! Triangle " + string(_i) + " for group \"" + string(_group_name) + "\" has an unsupported number of slashes (" + string(_slash_count) + ")");
                        continue;
                    }
                }
                else
                {
                    if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("DotobjModelLoad(): Warning! Triangle " + string(_i) + " for group \"" + string(_group_name) + "\" has an unsupported number of slashes (" + string(_slash_count) + ")");
                    continue;
                }
                
                if ((_v_index == "") || (_v_index == undefined))
                {
                    ++_missing_positions;
                    continue;
                }
                
                //If we've got any blank strings set the indices to 0
                if ((_n_index == "") || (_n_index == undefined)) _n_index = 0;
                if ((_t_index == "") || (_t_index == undefined)) _t_index = 0;
                
                //Some .obj file use negative references to look at data recently defined. This isn't supported!
                if ((_v_index < 0) || (_n_index < 0) || (_t_index < 0))
                {
                    ++_negative_references;
                    continue;
                }
                
                _v_index = 3*floor(real(_v_index));
                _n_index = 3*floor(real(_n_index));
                _t_index = 2*floor(real(_t_index));
                
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
            
                //Write the colour
                _cr = _colour_list[| _v_index  ]*255; //Red
                _cg = _colour_list[| _v_index+1]*255; //Green
                _cb = _colour_list[| _v_index+2]*255; //Blue
                _ca = _colour_list[| _v_index+3];     //Alpha
                vertex_colour(_vbuff, make_colour_rgb(_cr, _cg, _cb), _ca);
            
                //Write the UVs
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
                
                //Write the tangent, including handedness
                if (_write_tangents)
                {
                    if (_write_null_tangent)
                    {
                        vertex_float4(_vbuff, 0, 0, 0, 0);
                    }
                    else
                    {
                        //Fetch our tangent/bitangent values for this position
                        var _tx = _tangent_list[| _v_index  ];
                        var _ty = _tangent_list[| _v_index+1];
                        var _tz = _tangent_list[| _v_index+2];
                        
                        var _bx = _bitangent_list[| _v_index  ];
                        var _by = _bitangent_list[| _v_index+1];
                        var _bz = _bitangent_list[| _v_index+2];
                        
                        //show_debug_message("in normal     = " + string(_nx) + "," + string(_ny) + "," + string(_nz));
                        //show_debug_message("in tangent    = " + string(_tx) + "," + string(_ty) + "," + string(_tz));
                        //show_debug_message("in bitangent  = " + string(_bx) + "," + string(_by) + "," + string(_bz));
                        
                        //"Gram-Schmidt orthogonalize"... apparently
                        //        dot = normal.tangent
                        //    tangent = tangent - normal*dot
                        //    tangent = normalize(tangent)
                        var _dot = dot_product_3d(_nx, _ny, _nz,   _tx, _ty, _tz);
                        _tx -= _nx * _dot;
                        _ty -= _ny * _dot;
                        _tz -= _nz * _dot;
                        
                        var _length = sqrt(_tx*_tx + _ty*_ty + _tz*_tz);
                        if (_length > 0)
                        {
                            _tx /= _length;
                            _ty /= _length;
                            _tz /= _length;
                        }
                
                        //Figure out the handedness of the bitangent
                        //    cross = n x tan1
                        //      dot = cross . tan2
                        //     hand = (dot < 0)? -1 : 1
                        var _cross_x = _ny*_tz - _nz*_ty;
                        var _cross_y = _nz*_tx - _nx*_tz;
                        var _cross_z = _nx*_ty - _ny*_tx;
                        var _dot = dot_product_3d(_cross_x, _cross_y, _cross_z, _bx, _by, _bz)
                        var _handedness = (_dot < 0)? -1 : 1;
                        
                        //Actually write the data!
                        vertex_float4(_vbuff, _tx, _ty, _tz, _handedness);
                        
                        //show_debug_message("out tangent = " + string(_tx) + "," + string(_ty) + "," + string(_tz) + ", handedness = " + string(_handedness));
                    }
                }
            }
            
            //Once we've finished iterating over the triangles, finish our vertex buffer
            vertex_end(_vbuff);
        
            //Clean up memory for meshes
            _mesh_struct.vertexes_array = undefined;
            
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
    
    if (_write_tangents)
    {
        ds_list_destroy(_tangent_list);
        ds_list_destroy(_bitangent_list);
    }

    //Return to the old tell position for the buffer
    buffer_seek(_buffer, buffer_seek_start, _old_tell);

    //Report errors if we found any
    if (DOTOBJ_OUTPUT_WARNINGS)
    {
        if (_negative_references > 0) show_debug_message("DotobjModelLoad(): Warning! .obj had negative position references (x" + string(_negative_references) + ")");
        if (_missing_positions   > 0) show_debug_message("DotobjModelLoad(): Warning! .obj referenced missing positions (x"     + string(_missing_positions  ) + ")");
        if (_missing_normals     > 0) show_debug_message("DotobjModelLoad(): Warning! .obj referenced missing normals (x"       + string(_missing_normals    ) + ")");
        if (_missing_uvs         > 0) show_debug_message("DotobjModelLoad(): Warning! .obj referenced missing UVs (x"           + string(_missing_uvs        ) + ")");
    }

    //If we want to report the load time, do it!
    if (DOTOBJ_OUTPUT_LOAD_TIME) show_debug_message("DotobjModelLoad(): lines=" + string(_meta_line) + ", groups=" + string(array_length(_groups_array)) + ", vertex buffers=" + string(_meta_vertex_buffers) + ", triangles=" + string(_meta_triangles) + ". Time to load was " + string((get_timer() - _timer)/1000) + "ms");

    //Return our data
    return _model_struct;
}