// Feather disable all

/// Creates a material and returns a material struct.
/// 
/// @param libraryName
/// @param materialName

function DotobjMaterialCreate(_library_name, _material_name)
{
    return new DotobjClassMaterial(_library_name, _material_name);
}