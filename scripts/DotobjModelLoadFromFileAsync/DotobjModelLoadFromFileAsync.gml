/// @param file

function DotobjModelLoadFromFileAsync(_filename)
{
    return DotobjModelLoadAsync(buffer_load(_filename), __DotobjFilenameDir(_filename), true);
}