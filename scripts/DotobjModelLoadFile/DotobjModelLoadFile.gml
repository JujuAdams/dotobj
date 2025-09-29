// Feather disable all

/// Loads an ASCII .obj file from disk and turns it into a vertex buffer. Please see
/// `DotobjModelLoad()` for more information.
/// 
/// @param filename

function DotobjModelLoadFile(_filename)
{
    var _buffer = buffer_load(_filename);
    var _result = DotobjModelLoad(_buffer, filename_dir(_filename));
    buffer_delete(_buffer);

    return _result;
}