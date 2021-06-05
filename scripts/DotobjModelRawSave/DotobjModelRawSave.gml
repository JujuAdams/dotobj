function DotobjModelRawSave(_model, _filename)
{
    var _buffer = buffer_create(1024, buffer_grow, 1);
    _model.Serialize(_buffer);
    
    var _compressedBuffer = buffer_compress(_buffer, 0, buffer_tell(_buffer));
    buffer_save(_compressedBuffer, _filename);
    
    buffer_delete(_buffer);
    buffer_delete(_compressedBuffer);
}