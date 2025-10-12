/// @param buffer
/// @param [modelDirectory]
/// @param [callback]
/// @param [consumeBuffer=false]
/// @param [budget=12]

function DotobjModelLoadAsync(_inBuffer, _modelDirectory = "", _callback = undefined, _consumeBuffer = false, _budget = 12)
{
    return __DotobjStartWorker(_inBuffer, _modelDirectory, _callback, _consumeBuffer, _budget).__modelStruct;
}