// Feather disable all

/// param objFilename

function DotobjTryCache(_filename)
{
    var _sha1 = sha1_file(_filename);
    var _cacheFilename = "dotobj" + _sha1 + ".dat";
    
    if (file_exists(_cacheFilename))
    {
        return DotobjModelRawLoad(_cacheFilename);
    }
    else
    {
        var _model = DotobjModelLoadFile(_filename);
        DotobjModelRawSave(_model, _cacheFilename);
        return _model;
    }
}