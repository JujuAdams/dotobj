// Feather disable all

/// Loads an ASCII .obj file from disk and turns it into a vertex buffer. Please see
/// `DotobjModelLoad()` for more information.
/// 
/// @param filename

function DotobjModelLoadFromFile(_filename)
{
    return __DotobjStartWorker(buffer_load(_filename), __DotobjFilenameDir(_filename), true, infinity).__Force().__modelStruct;
}