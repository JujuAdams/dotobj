function dotobj_sprite_add_internal(_filename, _sprite)
{
    show_debug_message("dotobj_sprite_add_internal(): Set \"" + string(_filename) + "\" to internal sprite \"" + sprite_get_name(_sprite) + "\" (" + string(_sprite) + ")");
    global.__dotobj_sprite_map[? _filename] = _sprite;
}