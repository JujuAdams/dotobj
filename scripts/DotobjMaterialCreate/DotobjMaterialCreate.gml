// Feather disable all

/// Manually creates a material and returns a material struct. You can use manually created
/// materials to replace materials already defined for a model.
/// 
/// @param libraryName
/// @param materialName

function DotobjMaterialCreate(_library_name, _material_name)
{
    return new DotobjClassMaterial(_library_name, _material_name);
}