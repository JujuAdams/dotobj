/// @param state   Whether to flip the y-axis (V-component) of the texture coordinates. This is useful to correct for DirectX / OpenGL idiosyncrasies

function DotobjSetFlipTexcoordV(_state)
{
    global.__dotobjFlipTexcoordV = _state;
}