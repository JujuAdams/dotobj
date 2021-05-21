/// @param sprite
/// @param index
/// @param filename

function dotobj_class_texture(_sprite, _index, _filename) constructor
{
    filename          = _filename;
    sprite            = _sprite;
    index             = _index;
    pointer           = sprite_get_texture(_sprite, _index);
    blend_u           = undefined;
    blend_v           = undefined;
    bump_multiplier   = undefined;
    sharpness_boost   = undefined;
    colour_correction = undefined;
    channel           = undefined;
    scalar_range      = undefined;
    uv_clamp          = undefined;
    uv_offset         = undefined;
    uv_scale          = undefined;
    turbulence        = undefined;
    resolution        = undefined;
    invert_v          = undefined;
}