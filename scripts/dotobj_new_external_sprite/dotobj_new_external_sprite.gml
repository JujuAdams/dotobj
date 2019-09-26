/// @param filename

var _filename = argument0;

if (ds_map_exists(global.__dotobj_sprite_map, _filename)) return global.__dotobj_sprite_map[? _filename];

var _sprite = sprite_add(_filename, 1, false, false, 0, 0);
if (_sprite > 0)
{
    global.__dotobj_sprite_map[? _filename] = _sprite;
    show_debug_message("dotobj_new_external_sprite(): Loaded \"" + string(_filename) + "\" (spr=" + string(_sprite) + ")");
}
else
{
    if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_new_external_sprite(): Warning! Failed to load \"" + string(_filename) + "\"");
}

return _sprite;