/// @param libraryName
/// @param materialName

function dotobj_class_material(_library_name, _material_name) constructor
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
    ambient_map        = undefined;      //13) Texture struct (see dotobj_class_texture)
    diffuse_map        = undefined;      //14) Texture struct (see dotobj_class_texture)
    emissive_map       = undefined;      //15) Texture struct (see dotobj_class_texture)
    specular_map       = undefined;      //16) Texture struct (see dotobj_class_texture)
    specular_exp_map   = undefined;      //17) Texture struct (see dotobj_class_texture)
    dissolve_map       = undefined;      //18) Texture struct (see dotobj_class_texture)
    decal_map          = undefined;      //19) Texture struct (see dotobj_class_texture)
    displacement_map   = undefined;      //20) Texture struct (see dotobj_class_texture)
    normal_map         = undefined;      //21) Texture struct (see dotobj_class_texture)
    
    var _name = _library_name + "." + _material_name;
    global.__dotobj_material_library[? _name] = self;

    if (DOTOBJ_OUTPUT_DEBUG) show_debug_message("dotobj_class_material(): Created material \"" + string(_name) + "\"");
}





/// @param libraryName
/// @param materialName

function dotobj_ensure_material(_library_name, _material_name)
{
    var _name = _library_name + "." + _material_name;
    if (ds_map_exists(global.__dotobj_material_library, _name))
    {
        show_debug_message("dotobj_ensure_material(): Warning! Material \"" + string(_name) + "\" already exists");
        return global.__dotobj_material_library[? _name];
    }
    else
    {
        return new dotobj_class_material(_library_name, _material_name);
    }
}