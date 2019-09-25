/// Turns an ASCII .obj file, stored in a buffer, into a vertex buffer
/// @jujuadams    contact@jujuadams.com
/// 
/// @param buffer          Buffer to read from
/// @param vertexFormat    Vertex format to use. See below for details on what vertex formats are supported
/// @param writeNormals    Whether to write normals into the vertex buffer. Set this to <false> if your vertex format does not contain normals
/// @param writeUVs        Whether to write texture coordinates into the vertex buffer. Set this to <false> if your vertex format does not contain texture coordinates
/// @param flipUVs         Whether to flip the y-axis (V-component) of the texture coordinates. This is useful to correct for DirectX / OpenGL idiosyncrasies
/// @param reverseTris     Whether to reverse the triangle definition order to be compatible with the culling mode of your choice (clockwise/counter-clockwise)
/// @param [returnArray]   Whether to return an array of vertex buffers. Defaults to <false>, exporting a single vertex buffer
/// 
/// Returns: A vertex buffer, or an array of vertex buffers if "useBuffer" is <true>
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
/// .obj files sometimes contain multiple groups. For some specific applications,
/// it's useful to export each group as a separate vertex buffer. Set the optional
/// "useArray" argument to <true> to return an array of vertex buffers.
/// 
/// This .obj load does *not* support the following features:
/// - Materials
/// - Smoothing groups
/// - External texture map or .obj references
/// - Freeform curve/surface geometry (NURBs/Bezier curves etc.)
/// - Line primitives
/// - Separate in-file LOD

#region Internal macros

#macro __DOTOBJ_VERSION        "3.0.0"
#macro __DOTOBJ_DATE           "2019/9/25"
#macro __DOTOBJ_DEFAULT_GROUP  "__dotobj__default__"

#endregion

if (DOTOBJ_OUTPUT_LOAD_TIME) var _timer = get_timer();

var _buffer            = argument[0];
var _vformat           = argument[1];
var _write_normals     = argument[2];
var _write_texcoords   = argument[3];
var _flip_texcoords    = argument[4];
var _reverse_triangles = argument[5];
var _use_array         = ((argument_count > 6) && (argument[6] != undefined))? argument[6] : false;

//Create some lists to store the .obj file's data
//We fill in the 0th element because .obj vertices are 1-indexed (!)
var _position_list = ds_list_create(); ds_list_add(_position_list, 0,0,0  );
var _colour_list   = ds_list_create(); ds_list_add(_colour_list,   1,1,1,1);
var _normal_list   = ds_list_create(); ds_list_add(_normal_list,   0,0,0  );
var _texture_list  = ds_list_create(); ds_list_add(_texture_list,  0,0    );

//We keep a list of data per line
var _line_data_list = ds_list_create();

//Some .obj files use groups to store multiple individual vertex buffers
var _group_map   = ds_map_create();
var _vertex_list = ds_list_create();
ds_map_add_list(_group_map, __DOTOBJ_DEFAULT_GROUP, _vertex_list);

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
        
        if (_value != 32)
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
            ds_list_add(_line_data_list, buffer_read(_buffer, buffer_string));
            
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
                            if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load(): Warning! 4-element vertex position data is for mathematical curves/surfaces. This is not supported.");
                            break;
                        }
                        
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
                            if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load(): Warning! Texture depth is not supported; W-component of the texture coordinate will be ignored.");
                        }
                        
                        ds_list_add(_texture_list, real(_line_data_list[| 1]), real(_line_data_list[| 2]));
                    break;
                    
                    case "vn": //Normal
                        ds_list_add(_normal_list, real(_line_data_list[| 1]), real(_line_data_list[| 2]), real(_line_data_list[| 3]));
                    break;
                    
                    case "f": //Face definition
                        var _line_data_size = ds_list_size(_line_data_list);
                        
                        //Add all triangles, vertex-by-vertex, defined by this face
                        var _f = 0;
                        repeat(_line_data_size-3)
                        {
                            if (!_reverse_triangles)
                            {
                                ds_list_add(_vertex_list, _line_data_list[| 1], _line_data_list[| 2+_f], _line_data_list[| 3+_f]);
                            }
                            else
                            {
                                ds_list_add(_vertex_list, _line_data_list[| 1], _line_data_list[| 3+_f], _line_data_list[| 2+_f]);
                            }
                            
                            ++_f;
                        }
                    break;
                    
                    case "l": //Line definition
                        if (DOTOBJ_OUTPUT_WARNINGS && !DOTOBJ_IGNORE_LINES) show_debug_message("dotobj_load(): Warning! Line primitives are not currently supported.");
                    break;
                    
                    case "g": //Group definition
                        if (_use_array)
                        {
                            var _string = "";
                            var _i = 1;
                            var _size = ds_list_size(_line_data_list);
                            repeat(_size-1)
                            {
                                _string += _line_data_list[| _i] + ((_i < _size-1)? " " : "");
                                ++_i;
                            }
                            
                            //Create a new vertex list and add it to the group map
                            var _vertex_list = ds_list_create();
                            ds_map_add_list(_group_map, _string, _vertex_list);
                        }
                    break;
                    
                    case "o": //Object definition
                        var _string = "";
                        var _i = 1;
                        var _size = ds_list_size(_line_data_list);
                        repeat(_size-1)
                        {
                            _string += _line_data_list[| _i] + ((_i < _size-1)? " " : "");
                            ++_i;
                        }
                        
                        if (DOTOBJ_OBJECTS_ARE_GROUPS)
                        {
                            if (_use_array)
                            {
                                //Create a new vertex list and add it to the group map
                                var _vertex_list = ds_list_create();
                                ds_map_add_list(_group_map, _string, _vertex_list);
                            }
                        }
                        else
                        {
                            if (DOTOBJ_OUTPUT_WARNINGS)
                            {
                                show_debug_message("dotobj_load(): Warning! Object \"" + string(_string) + "\" found. Objects are not supported; use groups instead, or set DOTOBJ_OBJECTS_ARE_GROUPS to <true>.");
                            }
                        }
                    break;
                    
                    case "s": //Section definition
                        if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load(): Warning! Smoothing groups are not currently supported.");
                    break;
                    
                    case "#": //Ignore comments
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
                    case "usemtl":
                        if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load(): Warning! Materials are not currently supported.");
                    break;
                    
                    case "maplib":
                    case "usemap":
                        if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load(): Warning! External texture map files are not currently supported.");
                    break;
                    
                    case "shadow_obj":
                    case "trace_obj":
                        if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load(): Warning! \"" + string(_line_data_list[| 0]) + "\" is an external .obj reference. This is not supported.");
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
                    case "bsp": //Depreciated
                    case "bzp": //Depreciated
                    case "cdc": //Depreciated
                    case "cdp": //Depreciated
                    case "res": //Depreciated
                        if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load(): Warning! \"" + string(_line_data_list[| 0]) + "\" is for mathematical curves/surfaces. This is not supported.");
                    break;
                    
                    case "lod":
                        if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load(): Warning! In-file LODs are not currently supported.");
                    break;
                    
                    case "bevel":
                    case "c_interp":
                    case "d_interp":
                        if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load(): Warning! \"" + string(_line_data_list[| 0]) + "\" is a rendering attribute. This is not supported.");
                    break;
                    
                    default: //Something else that we don't recognise!
                        if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load(): Warning! \"" + string(_line_data_list[| 0]) + "\" is not recognised.");
                    break;
                }
                
                //Once we're done with the line, clear the data out and start again
                ds_list_clear(_line_data_list);
                _line_started = false;
            }
        }
    }
}

//Create an array to store our final vertex buffers
var _array = [];

//Create some variables to track errors
var _missing_positions = 0;
var _missing_normals   = 0;
var _missing_uvs       = 0;

//Iterate over all the groups we've found
//If we're not returning arrays, the group map should only contain one group
var _key = ds_map_find_first(_group_map);
repeat(ds_map_size(_group_map))
{
    //Find our list of faces for this group
    _vertex_list = _group_map[? _key];
    if (ds_list_size(_vertex_list) <= 0)
    {
        if ((_key != __DOTOBJ_DEFAULT_GROUP) || (ds_map_size(_group_map) <= 1))
        {
            if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load(): Warning! Group \"" + string(_key) + "\" has no faces.");
        }
        continue;
    }
    
    //Create a vertex buffer for this group
    var _vbuff = vertex_create_buffer();
    vertex_begin(_vbuff, _vformat);
    
    //Iterate over all the vertices for this group
    var _i = 0;
    repeat(ds_list_size(_vertex_list))
    {
        //N.B. This whole vertex decoding thing that uses strings can probably be done earlier by parsing data as it comes out of the buffer
        //     This can definitely be improved in terms of speed!
        
        //Get the vertex string, and count how many slashes it contains
        var _vertex_string = _vertex_list[| _i++];
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
                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load(): Warning! Face " + string(_i) + " for group \"" + string(_key) + "\" has an unsupported number of slashes (" + string(_slash_count) + ")");
                continue;
            }
        }
        else
        {
            if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load(): Warning! Face " + string(_i) + " for group \"" + string(_key) + "\" has an unsupported number of slashes (" + string(_slash_count) + ")");
            continue;
        }
        
        _v_index = 3*floor(real(_v_index));
        _n_index = 2*floor(real(_n_index));
        _t_index = 2*floor(real(_t_index));
        
        //Some .obj file use negative references to look at data recently defined. This isn't supported!
        if ((_v_index < 0) || (_n_index < 0) || (_t_index < 0))
        {
            if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load(): Negative references are not supported.");
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
    
    //Once we've finished iterating over the faces, finish our vertex buffer
    vertex_end(_vbuff);
    
    //Add this vertex buffer to our array
    _array[@ array_length_1d(_array)] = _vbuff;
    
    //Move to the next group
    _key = ds_map_find_next(_group_map, _key);
}

//Clean up our data structures
ds_list_destroy(_position_list );
ds_list_destroy(_colour_list   );
ds_list_destroy(_normal_list   );
ds_list_destroy(_texture_list  );
ds_list_destroy(_line_data_list);
ds_map_destroy( _group_map     );

//Return to the old tell position for the buffer
buffer_seek(_buffer, buffer_seek_start, _old_tell);

//Report errors if we found any
if (DOTOBJ_OUTPUT_WARNINGS)
{
    if (_missing_positions > 0) show_debug_message("dotobj_load(): Warning! .obj referenced missing positions (x" + string(_missing_positions) + ")");
    if (_missing_normals   > 0) show_debug_message("dotobj_load(): Warning! .obj referenced missing normals (x"   + string(_missing_normals  ) + ")");
    if (_missing_uvs       > 0) show_debug_message("dotobj_load(): Warning! .obj referenced missing UVs (x"       + string(_missing_uvs      ) + ")");
}

//If we want to report the load time, do it!
if (DOTOBJ_OUTPUT_LOAD_TIME) show_debug_message("dotobj_load(): Time to load was " + string((get_timer() - _timer)/1000) + "ms");

//Return our data
return _use_array? _array : _array[0];