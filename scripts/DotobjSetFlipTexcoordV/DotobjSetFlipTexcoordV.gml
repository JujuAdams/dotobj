// Feather disable all

/// Whether to flip the y-axis (V-component) of the texture coordinates. This is useful to correct
/// for DirectX / OpenGL idiosyncrasies.
/// 
/// @param state

function DotobjSetFlipTexcoordV(_state)
{
    static _system = __DotobjSystem();
    
    _system.__flipTexcoordV = _state;
}