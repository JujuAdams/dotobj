function DotobjSpriteAddInternal(_filename, _sprite)
{
    show_debug_message("DotobjSpriteAddInternal(): Set \"" + string(_filename) + "\" to internal sprite \"" + sprite_get_name(_sprite) + "\" (" + string(_sprite) + ")");
    global.__dotobjSpriteMap[? _filename] = _sprite;
}