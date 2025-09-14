// Feather disable all

/// Tries to load a model, using a cache if possible.
/// 
/// N.B. This function will only cache models on desktop platforms. On all other platforms, this
///      function will always fall back on loading the target .obj file.
/// 
/// param path

function DotobjTryCache(_path)
{
    if (DOTOBJ_USE_CACHE)
    {
        var _sha1 = sha1_file(_path);
        var _cacheFilename = "dotobj" + _sha1 + ".dat";
        
        if (file_exists(_cacheFilename))
        {
            try
            {
                return DotobjModelRawLoad(_cacheFilename);
            }
            catch(_error)
            {
                show_debug_message(_error);
            }
        }
    }
    
    var _model = DotobjModelLoadFile(_path);
    
    if (DOTOBJ_USE_CACHE)
    {
        DotobjModelRawSave(_model, _cacheFilename);
    }
    
    return _model;
}