/// @param state       Whether to calculate and write tangents into the output vertex buffer (vec4 - x, y, z, and handedness)
/// @param forceCalc   Whether to force the calculation of tangents even if the material has no normal map

function DotobjSetWriteTangents(_state, _force_calc)
{
    global.__dotobjWriteTangents    = _state;
    global.__dotobjForceTangentCalc = _force_calc;
}