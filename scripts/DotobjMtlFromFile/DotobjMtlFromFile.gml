// Feather disable all

/// Adds materials from an ASCII .mtl file to the global material library.
/// 
/// @param filename   File to read from

function DotobjMtlFromFile(_filename)
{
    static _mtlFileLoadedMap = __DotobjSystem().__mtlFileLoadedMap;
    
    if (ds_map_exists(_mtlFileLoadedMap, _filename))
    {
        show_debug_message("DotobjMtlFromFile(): \"" + _filename + "\" already loaded");
        return _mtlFileLoadedMap[? _filename];
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
            
            _mtlFileLoadedMap[? _filename] = _result;
            
            return _result;
        }
    }
}