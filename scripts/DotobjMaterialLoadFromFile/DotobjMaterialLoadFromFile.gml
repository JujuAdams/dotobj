/// @param path
/// @param [libraryName="runtime"]
/// @param [materialName=path]

function DotobjMaterialLoadFromFile(_path, _libraryName = "runtime", _materialName = _path)
{
    if (not file_exists(_path))
    {
        __DotobjError("Could not find \"", _path, "\"");
        return;
    }
    
    var _sprite = sprite_add(_path, 0, false, false, 0, 0);
    if (not sprite_exists(_sprite))
    {
        __DotobjError("Failed to create a sprite for \"", _path, "\"");
        return;
    }
    
    if (DotobjMaterialExists(_libraryName, _materialName))
    {
        show_debug_message("DotobjMtlLoadFromBuffer(): \"" + string(_libraryName) + "\" \"" + string(_materialName) + "\" already exists");
        return DotobjMaterialFind(_libraryName, _materialName);
    }
    
    var _texture = DotobjTextureCreate(_sprite, 0);
    var _material = DotobjMaterialCreate(_libraryName, _materialName);
    _material.SetDiffuseMap(_texture);
    
    return _material;
}