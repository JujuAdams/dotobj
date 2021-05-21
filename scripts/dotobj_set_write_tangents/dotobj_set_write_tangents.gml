/// @param state       Whether to calculate and write tangents into the output vertex buffer (vec4 - x, y, z, and handedness)
/// @param forceCalc   Whether to force the calculation of tangents even if the material has no normal map

function dotobj_set_write_tangents(_state, _force_calc)
{
    global.__dotobj_write_tangents     = _state;
    global.__dotobj_force_tangent_calc = _force_calc;
}