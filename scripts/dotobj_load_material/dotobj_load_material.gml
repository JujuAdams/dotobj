/// Adds materials from an ASCII .mtl file, stored in a buffer, to a ds_map
/// @jujuadams    contact@jujuadams.com
/// 
/// @param map      ds_map to add materials to
/// @param buffer   Buffer to read from

if (DOTOBJ_OUTPUT_LOAD_TIME) var _timer = get_timer();

var _root_map = argument0;
var _buffer   = argument1;

//We keep a list of data per line
var _map            = -1;
var _line_data_list = ds_list_create();

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
            ds_list_add(_line_data_list, buffer_read(_buffer, buffer_string));
            
            //And reset our value read position for the next value
            _value_read_start = buffer_tell(_buffer);
            
            if (_value != 32)
            {
                //If we've reached the end of a line or the end of the buffer, process the line
                
                switch(_line_data_list[| 0]) //Use the first piece of data we read to determine what kind of line this is
                {
                    #region Colour and illumination
                    
                    case "Ka": //Ambient reflectivity
                        switch(_line_data_list[| 1])
                        {
                            case "spectral": //Spectral curve file (.rfl)
                                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load_material(): Spectral curves are not supported.");
                            break;
                            case "xyz": //Using CIE-XYZ
                                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load_material(): CIE-XYZ colourspace is not yet supported.");
                            break;
                            default: //Using RGB
                            break;
                        }
                    break;
                    
                    case "Kd": //Diffuse reflectivity
                        switch(_line_data_list[| 1])
                        {
                            case "spectral": //Spectral curve file (.rfl)
                                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load_material(): Spectral curves are not supported.");
                            break;
                            case "xyz": //Using CIE-XYZ
                                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load_material(): CIE-XYZ colourspace is not yet supported.");
                            break;
                            default: //Using RGB
                            break;
                        }
                    break;
                    
                    case "Ks": //Specular reflectivity
                        switch(_line_data_list[| 1])
                        {
                            case "spectral": //Spectral curve file (.rfl)
                                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load_material(): Spectral curves are not supported.");
                            break;
                            case "xyz": //Using CIE-XYZ
                                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load_material(): CIE-XYZ colourspace is not yet supported.");
                            break;
                            default: //Using RGB
                            break;
                        }
                    break;
                    
                    case "Ke": //Emissive
                        switch(_line_data_list[| 1])
                        {
                            case "spectral": //Spectral curve file (.rfl)
                                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load_material(): Spectral curves are not supported.");
                            break;
                            case "xyz": //Using CIE-XYZ
                                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load_material(): CIE-XYZ colourspace is not yet supported.");
                            break;
                            default: //Using RGB
                            break;
                        }
                    break;
                    
                    case "Ns": //Specular exponent
                    break;
                    
                    case "Tr": //Transparency
                    break;
                    
                    case "Tf": //Transmission filter
                        switch(_line_data_list[| 1])
                        {
                            case "spectral": break; //Spectral curve file (.rfl)
                            case "xyz":      break; //Using CIE-XYZ
                            default:         break; //Using RGB
                        }
                    break;
                    
                    case "illum": //Illumination model
                        switch(_line_data_list[| 1])
                        {
                            case "0": //Colour on, ambient off
                            break;
                            
                            case "1": //Colour on, ambient on
                            break;
                            
                            case "2": //Highlight on
                            break;
                            
                            case "3": //Reflection on and Ray trace on
                            case "4": //Transparency: Glass on, Reflection: Ray trace on
                            case "5": //Reflection: Fresnel on and Ray trace on
                            case "6": //Transparency: Refraction on,  Reflection: Fresnel off and Ray trace on
                            case "7": //Transparency: Refraction on,  Reflection: Fresnel on and Ray trace on
                                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load_material(): Illumination model \"" + string(_line_data_list[| 1]) + "\" is not supported as it requires raytracing.");
                            break;
                            
                            case "8": //Reflection on, raytrace off
                            break;
                            
                            case "9": //Glass on, raytrace off
                            break;
                            
                            case "10": //Cast shadows onto invisible surfaces
                            break;
                            
                            default:
                                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load_material(): Illumination model \"" + string(_line_data_list[| 1]) + "\" not recognised.");
                            break;
                        }
                    break;
                    
                    case "d": //Dissolve
                        if (_line_data_list[| 1] == "-halo") //Dissolve is dependent on the surface orientation relative to the viewer
                        {
                            
                        }
                        else
                        {
                            
                        }
                    break;
                    
                    case "sharpness": //Reflection sharpness
                    break;
                    
                    case "Ni": //Optical density
                    break;
                    
                    #endregion
                    
                    #region Texture maps
                    
                    case "map_Ka": //Ambient reflectivity map
                    break;
                    
                    case "map_Kd": //Diffuse reflectivity map
                    break;
                    
                    case "map_Ks": //Specular reflectivity map
                    break;
                    
                    case "map_Ke": //Emissive map
                    break;
                    
                    case "map_Ns": //Specular exponent map
                    break;
                    
                    case "map_d": //Dissolve map
                    break;
                    
                    case "map_decal":
                    case "decal": //Decal map (selectively replace the material color with the texture colour)
                    break;
                    
                    case "map_disp":
                    case "disp": //Displacement map
                    break;
                    
                    case "map_bump":
                    case "bump": //"Bump" map (normal map)
                    break;
                    
                    #endregion
                    
                    #region Texture map options
                    
                    case "-blenu": //Horizontal texture blending
                    break;
                    
                    case "-blenv": //Horizontal texture blending
                    break;
                    
                    case "-bm": //Bump multiplier
                    break;
                    
                    case "-boost": //Boosts mipmapped image file sharpness (.mpc / .mps / .mpb)
                    break;
                    
                    case "-cc": //Colour correction
                    break;
                    
                    case "-clamp": //Clamp UVs to (0,0) -> (1,1)
                    break;
                    
                    case "-imfchan": //Channel used to create a scalar or bump texture
                    break;
                    
                    case "-mm": //Modifies range for scalar textures
                    break;
                    
                    case "-o": //Texture coordinate offset
                    break;
                    
                    case "-s": //Texture coordinate scaling
                    break;
                    
                    case "-t": //Turbulence
                    break;
                    
                    case "-texres": //Texture resolution
                    break;
                    
                    #endregion
                    
                    #region Reflection map
                    
                    case "refl": //Reflection map
                    break;
                    
                    #endregion
                    
                    case "newmtl":
                        var _string = "";
                        var _i = 1;
                        var _size = ds_list_size(_line_data_list);
                        repeat(_size-1)
                        {
                            _string += _line_data_list[| _i] + ((_i < _size-1)? " " : "");
                            ++_i;
                        }
                        
                        _map = ds_map_create();
                        ds_map_add_map(_root_map, _string, _map);
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
                            
                            show_debug_message("dotobj_load_material(): \"" + _string + "\"");
                        }
                    break;
                    
                    default: //Something else that we don't recognise!
                        if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_load_material(): Warning! \"" + string(_line_data_list[| 0]) + "\" is not recognised.");
                    break;
                }
                
                //Once we're done with the line, clear the data out and start again
                ds_list_clear(_line_data_list);
                _line_started = false;
            }
        }
    }
}

//Clean up our data structures
ds_list_destroy(_line_data_list);

//Return to the old tell position for the buffer
buffer_seek(_buffer, buffer_seek_start, _old_tell);

//If we want to report the load time, do it!
if (DOTOBJ_OUTPUT_LOAD_TIME) show_debug_message("dotobj_load_material(): Time to load was " + string((get_timer() - _timer)/1000) + "ms");

//Return our data
return true;