function DotobjModelLoadAsync(_inBuffer, _modelDirectory = "", _consumeBuffer = false)
{
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
    
    return new __DotobjClassModelWorker(_buffer, _modelDirectory);
}