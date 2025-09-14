// Feather disable all

/// @param state  Whether to import meshes as a wireframe (i.e. use pr_linelist rather than pr_trianglelist)

function DotobjSetWireframe(_state)
{
    global.__dotobjWireframe = _state;
}