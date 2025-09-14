// Feather disable all

/// @param path

function DotobjModelRawLoad(_path)
{
    var _compressedBuffer = buffer_load(_path);
    var _buffer = buffer_decompress(_compressedBuffer);
    
    var _model = (new DotobjClassModel()).Deserialize(_buffer);
    
    buffer_delete(_buffer);
    buffer_delete(_compressedBuffer);
    
    return _model;
}