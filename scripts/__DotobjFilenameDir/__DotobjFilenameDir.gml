/// @param path

function __DotobjFilenameDir(_path)
{
    var _directory = filename_dir(_path);
    return (string_length(_directory) > string_length(_path))? "" : _directory;
}