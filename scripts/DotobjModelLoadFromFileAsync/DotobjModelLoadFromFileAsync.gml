function DotobjModelLoadFromFileAsync(_filename)
{
    return DotobjModelLoadAsync(buffer_load(_filename), filename_dir(_filename), true);
}