// Feather disable all

/// Loads an ASCII .obj file from disk over multiple frames. This function "steals" a small amount
/// of time from the game's normal update loop to process data, eventually leading to a model being
/// fully loaded. You may draw a model whilst it's being loaded if you wish. You can detect whether
/// a model has finished loading by reading the `.loaded` variable in on the model struct. Please
/// see `DotobjModelLoad()` for more information on what you can do with models.
/// 
/// @param filename
/// @param [callback]
/// @param [budget=12ms]

function DotobjModelLoadFromFileAsync(_filename, _callback = undefined, _budget = 12)
{
    return DotobjModelLoadAsync(buffer_load(_filename), __DotobjFilenameDir(_filename), _callback, true, _budget);
}