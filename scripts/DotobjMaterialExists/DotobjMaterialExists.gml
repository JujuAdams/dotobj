// Feather disable all

/// Returns if a material exists with the specified library name and material name.
/// 
/// @param libraryName
/// @param materialName

function DotobjMaterialExists(_libraryName, _materialName)
{
    static _materialLibraryMap = __DotobjSystem().__materialLibraryMap;
    
    return ds_map_exists(_materialLibraryMap, _libraryName + "." + _materialName);
}