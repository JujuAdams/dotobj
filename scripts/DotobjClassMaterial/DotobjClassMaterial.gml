/// @param libraryName
/// @param materialName

function DotobjClassMaterial(_library_name, _material_name) constructor
{
    //Materials are collected together in .mtl files (a.k.a. "material libraries")
    library            = _library_name;  //string
    name               = _material_name; //string
    ambient            = undefined;      //u24 RGB
    diffuse            = undefined;      //u24 RGB
    emissive           = undefined;      //u24 RGB
    specular           = undefined;      //u24 RGB
    specular_exp       = undefined;      //f64
    transparency       = undefined;      //f64
    transmission       = undefined;      //u24 RGB
    illumination_model = undefined;      //u8 index
    dissolve           = undefined;      //f64
    sharpness          = undefined;      //f64
    optical_density    = undefined;      //f64
    ambient_map        = undefined;      //Texture struct (see DotobjClassTexture)
    diffuse_map        = undefined;      //Texture struct (see DotobjClassTexture)
    emissive_map       = undefined;      //Texture struct (see DotobjClassTexture)
    specular_map       = undefined;      //Texture struct (see DotobjClassTexture)
    specular_exp_map   = undefined;      //Texture struct (see DotobjClassTexture)
    dissolve_map       = undefined;      //Texture struct (see DotobjClassTexture)
    decal_map          = undefined;      //Texture struct (see DotobjClassTexture)
    displacement_map   = undefined;      //Texture struct (see DotobjClassTexture)
    normal_map         = undefined;      //Texture struct (see DotobjClassTexture)
    
    cache_name = _library_name + "." + _material_name;
    global.__dotobjMaterialLibrary[? cache_name] = self;

    if (DOTOBJ_OUTPUT_DEBUG) show_debug_message("DotobjClassMaterial(): Created material \"" + string(cache_name) + "\"");
    
    static SetDiffuseMap = function(_texture)
    {
        diffuse_map = _texture;
        return self;
    }
    
    static SetNormalMap = function(_texture)
    {
        normal_map = _texture;
        return self;
    }
    
    static Destroy = function()
    {
        if (is_struct(ambient_map     )) ambient_map.Free();
        if (is_struct(diffuse_map     )) diffuse_map.Free();
        if (is_struct(emissive_map    )) emissive_map.Free();
        if (is_struct(specular_map    )) specular_map.Free();
        if (is_struct(specular_exp_map)) specular_exp_map.Free();
        if (is_struct(dissolve_map    )) dissolve_map.Free();
        if (is_struct(decal_map       )) decal_map.Free();
        if (is_struct(displacement_map)) displacement_map.Free();
        if (is_struct(normal_map      )) normal_map.Free();
        
        ambient_map      = undefined;
        diffuse_map      = undefined;
        emissive_map     = undefined;
        specular_map     = undefined;
        specular_exp_map = undefined;
        dissolve_map     = undefined;
        decal_map        = undefined;
        displacement_map = undefined;
        normal_map       = undefined;
        
        ds_map_delete(global.__dotobjMtlFileLoaded, cache_name);
    }
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