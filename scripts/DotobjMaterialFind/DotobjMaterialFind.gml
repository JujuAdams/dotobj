// Feather disable all

/// @param libraryName
/// @param materialName

function DotobjMaterialFind(_libraryName, _materialName)
{
    static _materialLibraryMap = __DotobjSystem().__materialLibraryMap;
    
    return _materialLibraryMap[? _libraryName + "." + _materialName];
}