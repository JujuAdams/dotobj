/// @param libraryName
/// @param materialName

function DotobjClassMaterial(_library_name, _material_name) constructor
{
    //Materials are collected together in .mtl files (a.k.a. "material libraries")
    library            = _library_name;  // 0) string
    name               = _material_name; // 1) string
    ambient            = undefined;      // 2) u24 RGB
    diffuse            = undefined;      // 3) u24 RGB
    emissive           = undefined;      // 4) u24 RGB
    specular           = undefined;      // 5) u24 RGB
    specular_exp       = undefined;      // 6) f64
    transparency       = undefined;      // 7) f64
    transmission       = undefined;      // 8) u24 RGB
    illumination_model = undefined;      // 9) u8 index
    dissolve           = undefined;      //10) f64
    sharpness          = undefined;      //11) f64
    optical_density    = undefined;      //12) f64
    ambient_map        = undefined;      //13) Texture struct (see DotobjClassTexture)
    diffuse_map        = undefined;      //14) Texture struct (see DotobjClassTexture)
    emissive_map       = undefined;      //15) Texture struct (see DotobjClassTexture)
    specular_map       = undefined;      //16) Texture struct (see DotobjClassTexture)
    specular_exp_map   = undefined;      //17) Texture struct (see DotobjClassTexture)
    dissolve_map       = undefined;      //18) Texture struct (see DotobjClassTexture)
    decal_map          = undefined;      //19) Texture struct (see DotobjClassTexture)
    displacement_map   = undefined;      //20) Texture struct (see DotobjClassTexture)
    normal_map         = undefined;      //21) Texture struct (see DotobjClassTexture)
    
    var _name = _library_name + "." + _material_name;
    global.__dotobjMaterialLibrary[? _name] = self;

    if (DOTOBJ_OUTPUT_DEBUG) show_debug_message("DotobjClassMaterial(): Created material \"" + string(_name) + "\"");
}





/// @param libraryName
/// @param materialName

function __DotobjEnsureMaterial(_library_name, _material_name)
{
    var _name = _library_name + "." + _material_name;
    if (ds_map_exists(global.__dotobjMaterialLibrary, _name))
    {
        show_debug_message("__DotobjEnsureMaterial(): Warning! Material \"" + string(_name) + "\" already exists");
        return global.__dotobjMaterialLibrary[? _name];
    }
    else
    {
        return new DotobjClassMaterial(_library_name, _material_name);
    }
}