/// @param libraryName
/// @param materialName

function DotobjMaterialExists(_libraryName, _materialName)
{
    return ds_map_exists(global.__dotobjMaterialLibrary, _libraryName + "." + _materialName);
}