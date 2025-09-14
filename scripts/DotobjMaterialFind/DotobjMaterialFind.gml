// Feather disable all

/// @param libraryName
/// @param materialName

function DotobjMaterialFind(_libraryName, _materialName)
{
    return global.__dotobjMaterialLibrary[? _libraryName + "." + _materialName];
}