// Feather disable all

/// Manually adds materials from an ASCII .mtl material library file on disk to the global material
/// library. If your .obj models reference .mtl files themselves then they will be loaded
/// automatically and you will not need to call this function.
/// 
/// @param path

function DotobjMtlLoadFromFile(_path)
{
    static _mtlFileLoadedMap = __DotobjSystem().__mtlFileLoadedMap;
    
    if (ds_map_exists(_mtlFileLoadedMap, _path))
    {
        show_debug_message("DotobjMtlLoadFromFile(): \"" + _path + "\" already loaded");
        return _mtlFileLoadedMap[? _path];
    }
    else
    {
        show_debug_message("DotobjMtlLoadFromFile(): Loading \"" + _path + "\"");
        
        if (!file_exists(_path))
        {
            show_debug_message("DotobjMtlLoadFromFile(): \"" + _path + "\" could not be found");
        }
        else
        {
            var _buffer = buffer_load(_path);
            var _result = DotobjMtlLoadFromBuffer(_path, _buffer, filename_dir(_path));
            buffer_delete(_buffer);
            
            _mtlFileLoadedMap[? _path] = _result;
            
            return _result;
        }
    }
}