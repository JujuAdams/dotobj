/// @param state   Whether to reverse the triangle definition order to be compatible with the culling mode of your choice (clockwise/counter-clockwise)

function DotobjSetReverseTriangles(_state)
{
    global.__dotobjReverseTriangles = _state;
}