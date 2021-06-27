/// @param sprite
/// @param index
/// @param external

function DotobjClassTexture(_sprite, _index, _external) constructor
{
    filename          = undefined;
    sprite            = _sprite;
    index             = _index;
    external          = _external;
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
    
    static Free = function()
    {
        if (external && (sprite != undefined)) sprite_delete(sprite);
        sprite  = undefined;
        pointer = undefined;
    }
}