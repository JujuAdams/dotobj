// Feather disable all

/// Remaps an image path to a sprite reference in the game application.
/// 
/// @param remapPath
/// @param sprite

function DotobjSpriteAddInternal(_remapPath, _sprite)
{
    static _spriteMap = __DotobjSystem().__spriteMap;
    
    if (ds_map_exists(_spriteMap, _remapPath))
    {
        __DotobjError("\"", _remapPath, "\" has already been added");
    }
    
    show_debug_message("DotobjSpriteAddInternal(): Set \"" + string(_remapPath) + "\" to internal sprite \"" + sprite_get_name(_sprite) + "\" (" + string(_sprite) + ")");
    _spriteMap[? _remapPath] = _sprite;
}