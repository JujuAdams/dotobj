// Feather disable all

/// @param state       Whether to calculate and write tangents into the output vertex buffer (vec4 - x, y, z, and handedness)
/// @param forceCalc   Whether to force the calculation of tangents even if the material has no normal map

function DotobjSetWriteTangents(_state, _force_calc)
{
    static _system = __DotobjSystem();
    
    _system.__writeTangents    = _state;
    _system.__forceTangentCalc = _force_calc;
}