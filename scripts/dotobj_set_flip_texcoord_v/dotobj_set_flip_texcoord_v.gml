/// @param state   Whether to flip the y-axis (V-component) of the texture coordinates. This is useful to correct for DirectX / OpenGL idiosyncrasies

function dotobj_set_flip_texcoord_v(_state)
{
    global.__dotobj_flip_texcoord_v = _state;
}