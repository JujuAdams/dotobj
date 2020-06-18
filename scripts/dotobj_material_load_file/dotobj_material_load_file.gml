/// Adds materials from an ASCII .mtl file to the global material library.
/// @jujuadams    contact@jujuadams.com
/// 
/// @param filename   File to read from

function dotobj_material_load_file(_filename)
{
    if (ds_map_exists(global.__dotobj_mtl_file_loaded, _filename))
    {
        show_debug_message("dotobj_material_load_file(): \"" + _filename + "\" already loaded");
        return global.__dotobj_mtl_file_loaded[? _filename];
    }
    else
    {
        show_debug_message("dotobj_material_load_file(): Loading \"" + _filename + "\"");
        
        if (!file_exists(_filename))
        {
            show_debug_message("dotobj_material_load_file(): \"" + _filename + "\" could not be found");
        }
        else
        {
            var _buffer = buffer_load(_filename);
            var _result = dotobj_material_load(_filename, _buffer);
            buffer_delete(_buffer);
            
            global.__dotobj_mtl_file_loaded[? _filename] = _result;
            
            return _result;
        }
    }
}