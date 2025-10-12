// Feather disable all

/// Loads an ASCII .obj file from a buffer over multiple frames. This function "steals" a small
/// amount of time from the game's normal update loop to process data, eventually leading to a
/// model being fully loaded. You may draw a model whilst it's being loaded if you wish. You can
/// detect whether a model has finished loading by reading the `.loaded` variable in on the model
/// struct. Please see `DotobjModelLoad()` for more information on what you can do with models.
/// 
/// @param buffer
/// @param [modelDirectory]
/// @param [callback]
/// @param [consumeBuffer=false]
/// @param [budget=12ms]

function DotobjModelLoadAsync(_inBuffer, _modelDirectory = "", _callback = undefined, _consumeBuffer = false, _budget = 12)
{
    return __DotobjStartWorker(_inBuffer, _modelDirectory, _callback, _consumeBuffer, _budget).__modelStruct;
}