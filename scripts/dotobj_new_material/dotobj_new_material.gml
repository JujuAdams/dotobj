/// @param libraryName
/// @param materialName

//Materials are collected together in .mtl files (a.k.a. "material libraries").
enum eDotObjMaterial
{
    Library,           // 0) string
    Name,              // 1) string
    Ambient,           // 2) u24 RGB
    Diffuse,           // 3) u24 RGB
    Emissive,          // 4) u24 RGB
    Specular,          // 5) u24 RGB
    SpecularExp,       // 6) f64
    Transparency,      // 7) f64
    Transmission,      // 8) u24 RGB
    IlluminationModel, // 9) u8 index
    Dissolve,          //10) f64
    Sharpness,         //11) f64
    OpticalDensity,    //12) f64
    AmbientMap,        //13) Texture array (see eDotObjTexture)
    DiffuseMap,        //14) Texture array (see eDotObjTexture)
    EmissiveMap,       //15) Texture array (see eDotObjTexture)
    SpecularMap,       //16) Texture array (see eDotObjTexture)
    SpecularExpMap,    //17) Texture array (see eDotObjTexture)
    DissolveMap,       //18) Texture array (see eDotObjTexture)
    DecalMap,          //19) Texture array (see eDotObjTexture)
    DisplacementMap,   //20) Texture array (see eDotObjTexture)
    NormalMap,         //21) Texture array (see eDotObjTexture)
    __Size
}

var _library_name  = argument0;
var _material_name = argument1;

var _name = _library_name + "." + _material_name;
if (ds_map_exists(global.__dotobj_material_library, _name))
{
    show_debug_message("dotobj_new_material(): Warning! Material \"" + string(_name) + "\" already exists");
    return global.__dotobj_material_library[? _name];
}

var _array = array_create(eDotObjMaterial.__Size, undefined);
_array[@ eDotObjMaterial.Library] = _library_name;
_array[@ eDotObjMaterial.Name   ] = _material_name;

global.__dotobj_material_library[? _name] = _array;

if (DOTOBJ_OUTPUT_DEBUG) show_debug_message("dotobj_new_material(): Created material \"" + string(_name) + "\"");

return _array;