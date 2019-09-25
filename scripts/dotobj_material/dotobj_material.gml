/// Tries to find a material in a library.
/// 
/// @param map
/// @param materialName
/// @param [materialLibrary]
/// 
/// Returns: The material array, or <undefined> if the material could not be found

var _map = argument[0];

if (argument_count == 2)
{
    return _map[? string(argument[1])];
}
else if (argument_count == 3)
{
    return _map[? string(argument[2]) + "." + string(argument[1])];
}
else
{
    return undefined;
}