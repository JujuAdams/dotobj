function DotobjSpriteAddInternal(_filename, _sprite)
{
    if (ds_map_exists(global.__dotobjSpriteMap, _filename))
    {
        __DotobjError("\"", _filename, "\" has already been added");
    }
    
    show_debug_message("DotobjSpriteAddInternal(): Set \"" + string(_filename) + "\" to internal sprite \"" + sprite_get_name(_sprite) + "\" (" + string(_sprite) + ")");
    global.__dotobjSpriteMap[? _filename] = _sprite;
}