// Feather disable all

/// Creates a texture from a sprite reference and returns a texture struct. You can use this
/// texture struct with custom material definitions e.g. for reskinning characters.
/// 
/// @param sprite
/// @param index

function DotobjTextureCreate(_sprite, _index)
{
    return new DotobjClassTexture(_sprite, _index, false);
}