// Feather disable all

/// Remaps an image path found in .mtl material libraries to a GameMaker native sprite. This is
/// helpful if you want to keep textures stored internally for easier memory handling.
/// 
/// Please note that remapping set up with this function will be applied after rules set up by
/// `DotobjAliasPathSubstring()` when loading resources using references found in .mtl files.
/// 
/// @param remapPath
/// @param sprite

function DotobjAliasImagePathToSprite(_remapPath, _sprite)
{
    static _aliasImagePathToSpriteMap = __DotobjSystem().__aliasImagePathToSpriteMap;
    
    if (ds_map_exists(_aliasImagePathToSpriteMap, _remapPath))
    {
        __DotobjError("\"", _remapPath, "\" has already been added");
    }
    
    show_debug_message("DotobjAliasImagePathToSprite(): Set \"" + string(_remapPath) + "\" to internal sprite \"" + sprite_get_name(_sprite) + "\" (" + string(_sprite) + ")");
    _aliasImagePathToSpriteMap[? _remapPath] = _sprite;
}