function DotobjModelRawSave(_model, _filename)
{
    var _buffer = buffer_create(1024, buffer_grow, 1);
    _model.Serialize(_buffer);
    buffer_save_ext(_buffer, _filename, 0, buffer_tell(_buffer));
    buffer_delete(_buffer);
}