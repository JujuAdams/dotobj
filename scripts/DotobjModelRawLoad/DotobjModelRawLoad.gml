function DotobjModelRawLoad(_filename)
{
    var _buffer = buffer_load(_filename);
    var _model = (new DotobjClassModel()).Deserialize(_buffer);
    buffer_delete(_buffer);
    
    return _model;
}