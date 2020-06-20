/// @param state   Whether to reverse the triangle definition order to be compatible with the culling mode of your choice (clockwise/counter-clockwise)

function dotobj_set_reverse_triangles(_state)
{
    global.__dotobj_reverse_triangles = _state;
}