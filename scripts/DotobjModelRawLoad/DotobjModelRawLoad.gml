function DotobjModelRawLoad(_filename)
{
    var _compressedBuffer = buffer_load(_filename);
    var _buffer = buffer_decompress(_compressedBuffer);
    
    var _model = (new DotobjClassModel()).Deserialize(_buffer);
    
    buffer_delete(_buffer);
    buffer_delete(_compressedBuffer);
    
    return _model;
}