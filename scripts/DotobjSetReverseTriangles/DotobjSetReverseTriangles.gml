// Feather disable all

/// @param state   Whether to reverse the triangle definition order to be compatible with the culling mode of your choice (clockwise/counter-clockwise)

function DotobjSetReverseTriangles(_state)
{
    static _system = __DotobjSystem();
    
    _system.__reverseTriangles = _state;
}