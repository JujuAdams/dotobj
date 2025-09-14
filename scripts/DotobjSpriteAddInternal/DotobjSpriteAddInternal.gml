// Feather disable all

/// @param filename
/// @param sprite

function DotobjSpriteAddInternal(_filename, _sprite)
{
    static _spriteMap = __DotobjSystem().__spriteMap;
    
    if (ds_map_exists(_spriteMap, _filename))
    {
        __DotobjError("\"", _filename, "\" has already been added");
    }
    
    show_debug_message("DotobjSpriteAddInternal(): Set \"" + string(_filename) + "\" to internal sprite \"" + sprite_get_name(_sprite) + "\" (" + string(_sprite) + ")");
    _spriteMap[? _filename] = _sprite;
}