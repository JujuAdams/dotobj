/// @param sprite
/// @param index
/// @param filename

enum eDotObjTexture
{
    Filename,          //
    Sprite,            //
    Index,             //
    Pointer,           //
    BlendU,            //
    BlendV,            //
    BumpMultiplier,    //
    SharpnessBoost,    //
    ColourCorrection,  //
    Channel,           //
    ScalarRange,       //
    UVClamp,           //
    UVOffset,          //
    UVScale,           //
    Turbulence,        //
    Resolution,        //
    InvertV,           //
    __Size             //
}

var _sprite   = argument[0];
var _index    = argument[1];
var _filename = (argument_count > 2)? argument[2] : undefined;

var _array = array_create(eDotObjTexture.__Size, undefined);
_array[@ eDotObjTexture.Filename] = _filename;
_array[@ eDotObjTexture.Sprite  ] = _sprite;
_array[@ eDotObjTexture.Index   ] = _index;
_array[@ eDotObjTexture.Pointer ] = sprite_get_texture(_sprite, _index);

return _array;