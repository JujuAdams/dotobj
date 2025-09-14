// Feather disable all

/// Returns the material struct associated with the material name. If no such material exists, this
/// function returns `undefined`.
/// 
/// @param libraryName
/// @param materialName

function DotobjMaterialFind(_libraryName, _materialName)
{
    static _materialLibraryMap = __DotobjSystem().__materialLibraryMap;
    
    return _materialLibraryMap[? _libraryName + "." + _materialName];
}