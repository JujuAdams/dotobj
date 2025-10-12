/// @param buffer
/// @param [modelDirectory]
/// @param [consumeBuffer=false]
/// @param [budget=12]

function DotobjModelLoadAsync(_inBuffer, _modelDirectory = "", _consumeBuffer = false, _budget = 12)
{
    return __DotobjStartWorker(_inBuffer, _modelDirectory, _consumeBuffer, _budget).__modelStruct;
}