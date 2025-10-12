/// @param filename
/// @param [callback]
/// @param [budget=12]

function DotobjModelLoadFromFileAsync(_filename, _callback = undefined, _budget = 12)
{
    return DotobjModelLoadAsync(buffer_load(_filename), __DotobjFilenameDir(_filename), _callback, true, _budget);
}