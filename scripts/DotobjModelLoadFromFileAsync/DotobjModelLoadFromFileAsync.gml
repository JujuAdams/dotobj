/// @param filename
/// @param [budget=12]

function DotobjModelLoadFromFileAsync(_filename, _budget = 12)
{
    return DotobjModelLoadAsync(buffer_load(_filename), __DotobjFilenameDir(_filename), true, _budget);
}