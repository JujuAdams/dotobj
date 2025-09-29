// Feather disable all

/// Whether to import meshes as a wireframe (i.e. use `pr_linelist` rather than `pr_trianglelist`).
///
/// @param state

function DotobjSetWireframe(_state)
{
    static _system = __DotobjSystem();
    
    _system.__wireframe = _state;
}