// Feather disable all

/// @param filename

function __DotobjAddExternalSprite(_filename)
{
    var _sprite = -1;
    
    if (ds_map_exists(global.__dotobjSpriteMap, _filename))
    {
        _sprite = global.__dotobjSpriteMap[? _filename];
        if (DOTOBJ_OUTPUT_DEBUG) show_debug_message("__DotobjAddExternalSprite(): Reusing \"" + string(_filename) + "\" (spr=" + string(_sprite) + ")");
        
        if (sprite_exists(_sprite))
        {
            return _sprite;
        }
        else
        {
            if (DOTOBJ_OUTPUT_DEBUG) show_debug_message("__DotobjAddExternalSprite(): Sprite " + string(_sprite) + " does not exist, trying to reload");
        }
    }
    
    if (!file_exists(_filename))
    {
        if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("__DotobjAddExternalSprite(): Warning! \"" + string(_filename) + "\" could not be found");
    }
    else
    {
        _sprite = sprite_add(_filename, 1, false, false, 0, 0);
        if (_sprite > 0)
        {
            global.__dotobjSpriteMap[? _filename] = _sprite;
            if (DOTOBJ_OUTPUT_DEBUG) show_debug_message("__DotobjAddExternalSprite(): Loaded \"" + string(_filename) + "\" (spr=" + string(_sprite) + ")");
        }
        else
        {
            if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("__DotobjAddExternalSprite(): Warning! Failed to load \"" + string(_filename) + "\"");
        }
    }
    
    return _sprite;
}