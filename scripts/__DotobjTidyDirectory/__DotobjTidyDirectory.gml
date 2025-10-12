/// @param directory

function __DotobjTidyDirectory(_directory)
{
    var _length = string_length(_directory);
    if ((_length > 0) && (string_char_at(_directory, _length) != "\\"))
    {
        _directory += "\\";
    }
    
    return _directory;
}