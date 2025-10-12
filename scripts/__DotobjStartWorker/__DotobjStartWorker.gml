/// @param buffer
/// @param modelDirectory
/// @param callback
/// @param consumeBuffer
/// @param budget

function __DotobjStartWorker(_inBuffer, _modelDirectory, _callback, _consumeBuffer, _budget)
{
    _modelDirectory = __DotobjTidyDirectory(_modelDirectory);
    
    if (_consumeBuffer)
    {
        var _buffer = _inBuffer;
        buffer_resize(_buffer, buffer_get_size(_inBuffer)+1);
    }
    else
    {
        var _buffer = buffer_create(buffer_get_size(_inBuffer)+1, buffer_fixed, 1);
        buffer_copy(_inBuffer, 0, buffer_get_size(_inBuffer), _buffer, 0);
    }
    
    return new __DotobjClassModelWorker(_buffer, _modelDirectory, _callback, _budget);
}