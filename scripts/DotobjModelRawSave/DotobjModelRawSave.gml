// Feather disable all

/// Saves a model in a quick-to-load propriatery format. Models saved with this function should be
/// loaded by `DotobjModelRawLoad()`.
/// 
/// @param model
/// @param path

function DotobjModelRawSave(_model, _path)
{
    var _buffer = buffer_create(1024, buffer_grow, 1);
    _model.Serialize(_buffer);
    
    var _compressedBuffer = buffer_compress(_buffer, 0, buffer_tell(_buffer));
    buffer_save(_compressedBuffer, _path);
    
    buffer_delete(_buffer);
    buffer_delete(_compressedBuffer);
}