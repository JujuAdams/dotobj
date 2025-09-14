// Feather disable all

/// The transformation is defined by DOTOBJ_POSITION_TRANSFORM and DOTOBJ_NORMAL_TRANSFORM in __DotobjConfig()
/// 
/// @param state   Whether to transform vertex positions and normals on load

function DotobjSetTransformOnLoad(_state)
{
    global.__dotobjTransformOnLoad = _state;
}