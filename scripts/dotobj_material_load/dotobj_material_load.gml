/// Adds materials from an ASCII .mtl file, stored in a buffer, to the global material library.
/// @jujuadams    contact@jujuadams.com
/// 
/// @param libraryName   Name of the library (usually a filename)
/// @param buffer        Buffer to read from

function dotobj_material_load(_library_name, _buffer)
{
    if (DOTOBJ_OUTPUT_LOAD_TIME) var _timer = get_timer();

    //We keep a list of data per line
    var _line_data_list = ds_list_create();
    
    var _material_struct = undefined;
    var _texture_struct  = undefined;

    var _meta_line = 0;

    //Start at the start of the buffer...
    var _buffer_size = buffer_get_size(_buffer);
    var _old_tell = buffer_tell(_buffer);
    buffer_seek(_buffer, buffer_seek_start, 0);

    //And let's iterate over the entire buffer, byte-by-byte
    var _line_started = false;
    var _value_read_start = 0;
    var _b = 0;
    repeat(_buffer_size + 1)
    {
        //Grab a value
        if (_b < _buffer_size)
        {
            var _value = buffer_read(_buffer, buffer_u8);
            ++_b;
        }
        else
        {
            var _value = 0;
        }
        
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
            if ((_value == 0) || (_value == 10) || (_value == 13) || (_value == 32))
            {
                //Put in a null character at the breaking character so we can easily read the value
                if (_value != 0) buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0);
            
                //Jump back to the where the value started, then read it in as a string
                buffer_seek(_buffer, buffer_seek_start, _value_read_start);
                ds_list_add(_line_data_list, buffer_read(_buffer, buffer_string));
            
                //And reset our value read position for the next value
                _value_read_start = buffer_tell(_buffer);
            
                if (_value != 32)
                {
                    //If we've reached the end of a line or the end of the buffer, process the line
                
                    if (_line_data_list[| 0] == "newmtl")
                    {
                        //Create a new material
                        var _material_name = "";
                        var _i = 1;
                        var _size = ds_list_size(_line_data_list);
                        repeat(_size-1)
                        {
                            _material_name += _line_data_list[| _i] + ((_i < _size-1)? " " : "");
                            ++_i;
                        }
                        
                        var _material_struct = dotobj_ensure_material(_library_name, _material_name);
                    }
                    else if (_line_data_list[| 0] == "#")
                    {
                        //Handle comments
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
                        
                            show_debug_message("dotobj_material_load(): \"" + _string + "\"");
                        }
                    }
                    else if (!is_struct(_material_struct))
                    {
                        if (DOTOBJ_OUTPUT_WARNINGS)
                        {
                            show_debug_message("dotobj_material_load(): Warning! No material has been created (ln=" + string(_meta_line) + ")");
                        }
                    }
                    else switch(_line_data_list[| 0]) //Use the first piece of data we read to determine what kind of line this is
                    {
                        #region Colour and illumination
                    
                        case "Ka": //Ambient reflectivity
                            switch(_line_data_list[| 1])
                            {
                                case "spectral": //Spectral curve file (.rfl)
                                    if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_material_load(): Spectral curves are not supported");
                                break;
                                case "xyz": //Using CIE-XYZ
                                    if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_material_load(): CIE-XYZ colourspace is not currently supported");
                                break;
                                default: //Using RGB
                                    _material_struct.ambient = make_colour_rgb(255*real(_line_data_list[| 1]), 255*real(_line_data_list[| 2]), 255*real(_line_data_list[| 3]));
                                break;
                            }
                        break;
                    
                        case "Kd": //Diffuse reflectivity
                            switch(_line_data_list[| 1])
                            {
                                case "spectral": //Spectral curve file (.rfl)
                                    if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_material_load(): Spectral curves are not supported");
                                break;
                                case "xyz": //Using CIE-XYZ
                                    if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_material_load(): CIE-XYZ colourspace is not currently supported");
                                break;
                                default: //Using RGB
                                    _material_struct.diffuse = make_colour_rgb(255*real(_line_data_list[| 1]), 255*real(_line_data_list[| 2]), 255*real(_line_data_list[| 3]));
                                break;
                            }
                        break;
                    
                        case "Ks": //Specular reflectivity
                            switch(_line_data_list[| 1])
                            {
                                case "spectral": //Spectral curve file (.rfl)
                                    if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_material_load(): Spectral curves are not supported");
                                break;
                                case "xyz": //Using CIE-XYZ
                                    if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_material_load(): CIE-XYZ colourspace is not currently supported");
                                break;
                                default: //Using RGB
                                    _material_struct.specular = make_colour_rgb(255*real(_line_data_list[| 1]), 255*real(_line_data_list[| 2]), 255*real(_line_data_list[| 3]));
                                break;
                            }
                        break;
                    
                        case "Ke": //Emissive
                            switch(_line_data_list[| 1])
                            {
                                case "spectral": //Spectral curve file (.rfl)
                                    if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_material_load(): Spectral curves are not supported");
                                break;
                                case "xyz": //Using CIE-XYZ
                                    if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_material_load(): CIE-XYZ colourspace is not currently supported");
                                break;
                                default: //Using RGB
                                    _material_struct.emissive = make_colour_rgb(255*real(_line_data_list[| 1]), 255*real(_line_data_list[| 2]), 255*real(_line_data_list[| 3]));
                                break;
                            }
                        break;
                    
                        case "Ns": //Specular exponent
                            _material_struct.specular_exp = real(_line_data_list[| 1]);
                        break;
                    
                        case "Tr": //Transparency
                            _material_struct.transparency = real(_line_data_list[| 1]);
                        break;
                    
                        case "Tf": //Transmission filter
                            switch(_line_data_list[| 1])
                            {
                                case "spectral": break; //Spectral curve file (.rfl)
                                case "xyz":      break; //Using CIE-XYZ
                                default:
                                    _material_struct.transmission = make_colour_rgb(255*real(_line_data_list[| 1]), 255*real(_line_data_list[| 2]), 255*real(_line_data_list[| 3]));
                                break; //Using RGB
                            }
                        break;
                    
                        case "illum": //Illumination model
                            switch(_line_data_list[| 1])
                            {
                                case "0": //Colour on, ambient off
                                case "1": //Colour on, ambient on
                                case "2": //Highlight on
                                case "8": //Reflection on, raytrace off
                                case "9": //Glass on, raytrace off
                                case "10": //Cast shadows onto invisible surfaces
                                    _material_struct.illumination_model = real(_line_data_list[| 1]);
                                break;
                            
                                case "3": //Reflection on and Ray trace on
                                case "4": //Transparency: Glass on, Reflection: Ray trace on
                                case "5": //Reflection: Fresnel on and Ray trace on
                                case "6": //Transparency: Refraction on,  Reflection: Fresnel off and Ray trace on
                                case "7": //Transparency: Refraction on,  Reflection: Fresnel on and Ray trace on
                                    if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_material_load(): Illumination model \"" + string(_line_data_list[| 1]) + "\" is not supported as it requires raytracing");
                                break;
                            
                                default:
                                    if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_material_load(): Illumination model \"" + string(_line_data_list[| 1]) + "\" not recognised");
                                break;
                            }
                        break;
                    
                        case "d": //Dissolve
                            if (_line_data_list[| 1] == "-halo") //Dissolve is dependent on the surface orientation relative to the viewer
                            {
                                _material_struct.dissolve = -real(_line_data_list[| 1]);
                            }
                            else
                            {
                                _material_struct.dissolve = real(_line_data_list[| 1]);
                            }
                        break;
                    
                        case "sharpness": //Reflection sharpness
                            _material_struct.sharpness = real(_line_data_list[| 1]);
                        break;
                    
                        case "Ni": //Optical density
                            _material_struct.optical_density = real(_line_data_list[| 1]);
                        break;
                    
                        #endregion
                    
                        #region Texture maps
                    
                        case "map_Ka": //Ambient reflectivity map
                        case "map_Kd": //Diffuse reflectivity map
                        case "map_Ks": //Specular reflectivity map
                        case "map_Ke": //Emissive map
                        case "map_Ns": //Specular exponent map
                        case "map_d": //Dissolve map
                        case "map_decal":
                        case "decal": //Decal map (selectively replace the material color with the texture colour)
                        case "map_disp":
                        case "disp": //Displacement map
                        case "map_bump":
                        case "bump": //"Bump" map (normal map)
                            var _sprite = dotobj_add_external_sprite(_line_data_list[| 1]);
                            _texture_struct = (_sprite >= 0)? new dotobj_class_texture(_sprite, 0, _line_data_list[| 1]) : undefined;
                        
                            switch(_line_data_list[| 0])
                            {
                                case "map_Ka":    _material_struct.ambient_map      = _texture_struct; break;
                                case "map_Kd":    _material_struct.diffuse_map      = _texture_struct; break;
                                case "map_Ks":    _material_struct.specular_map     = _texture_struct; break;
                                case "map_Ke":    _material_struct.emissive_map     = _texture_struct; break;
                                case "map_Ns":    _material_struct.specular_exp_map = _texture_struct; break;
                                case "map_d":     _material_struct.dissolve_map     = _texture_struct; break;
                                case "map_decal":
                                case "decal":     _material_struct.decal_map        = _texture_struct; break;
                                case "map_disp":                                
                                case "disp":      _material_struct.ambient_map      = _texture_struct; break;
                                case "map_bump":                                
                                case "bump":      _material_struct.normal_map       = _texture_struct; break;
                            }
                        break;
                    
                        #endregion
                    
                        #region Texture map options
                    
                        case "-blenu":   //Horizontal texture blending
                        case "-blenv":   //Vertical texture blending
                            if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_material_load(): Warning! Horizontal/vertical texture blending is not supported. (ln=" + string(_meta_line) + ")");
                        break;
                    
                        case "-bm":      //Bump multiplier
                        case "-boost":   //Boosts mipmapped image file sharpness (.mpc / .mps / .mpb)
                        case "-cc":      //Colour correction
                        case "-clamp":   //Clamp UVs to (0,0) -> (1,1)
                        case "-imfchan": //Channel used to create a scalar or bump texture
                        case "-mm":      //Modifies range for scalar textures
                        case "-o":       //Texture coordinate offset
                        case "-s":       //Texture coordinate scaling
                        case "-t":       //Turbulence
                        case "-texres":  //Texture resolution
                            if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_material_load(): Warning! \"" + string(_line_data_list[| 0]) + "\" is not currently supported. (ln=" + string(_meta_line) + ")");
                        break;
                    
                        #endregion
                    
                        #region Reflection map
                    
                        case "refl": //Reflection map
                            if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_material_load(): Warning! Reflection maps are not supported. (ln=" + string(_meta_line) + ")");
                        break;
                    
                        #endregion
                    
                        default: //Something else that we don't recognise!
                            if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_material_load(): Warning! \"" + string(_line_data_list[| 0]) + "\" is not recognised. (ln=" + string(_meta_line) + ")");
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

    //Clean up our data structures
    ds_list_destroy(_line_data_list);

    //Return to the old tell position for the buffer
    buffer_seek(_buffer, buffer_seek_start, _old_tell);

    //If we want to report the load time, do it!
    if (DOTOBJ_OUTPUT_LOAD_TIME) show_debug_message("dotobj_material_load(): Time to load was " + string((get_timer() - _timer)/1000) + "ms");

    //Return our data
    return true;
}