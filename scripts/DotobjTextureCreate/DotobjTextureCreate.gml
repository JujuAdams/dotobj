// Feather disable all

/// Creates a texture from a sprite reference and returns a texture struct.
/// 
/// @param sprite
/// @param index

function DotobjTextureCreate(_sprite, _index)
{
    return new DotobjClassTexture(_sprite, _index, false);
}