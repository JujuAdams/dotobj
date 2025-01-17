/// Adds materials from an ASCII .mtl file to the global material library.
/// @jujuadams    contact@jujuadams.com
/// 
/// @param filename   File to read from

function DotobjMtlFromFile(_filename)
{
    if (ds_map_exists(global.__dotobjMtlFileLoaded, _filename))
    {
        show_debug_message("DotobjMtlFromFile(): \"" + _filename + "\" already loaded");
        return global.__dotobjMtlFileLoaded[? _filename];
    }
    else
    {
        show_debug_message("DotobjMtlFromFile(): Loading \"" + _filename + "\"");
        
        if (!file_exists(_filename))
        {
            show_debug_message("DotobjMtlFromFile(): \"" + _filename + "\" could not be found");
        }
        else
        {
            var _buffer = buffer_load(_filename);
            var _result = DotobjMtlLoadFromBuffer(_filename, _buffer, filename_dir(_filename));
            buffer_delete(_buffer);
            
            global.__dotobjMtlFileLoaded[? _filename] = _result;
            
            return _result;
        }
    }
}