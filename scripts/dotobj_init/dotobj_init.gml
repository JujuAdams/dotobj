//Create a global map to store all our material definitions
global.__dotobj_material_library = ds_map_create();
global.__dotobj_sprite_map       = ds_map_create();

//Create a default material
var _array = array_create(eDotObjMaterial.__Size, undefined);
_array[@ eDotObjMaterial.Library] = __DOTOBJ_DEFAULT_MATERIAL_LIBRARY;
_array[@ eDotObjMaterial.Name   ] = __DOTOBJ_DEFAULT_MATERIAL_NAME;
global.__dotobj_material_library[? __DOTOBJ_DEFAULT_MATERIAL_NAME] = _array;

#region Internal macros

//Always date your work!
#macro __DOTOBJ_VERSION                    "4.0.0"
#macro __DOTOBJ_DATE                       "2019/9/25"

//Some strings to use for defaults. Change these if you so desire.
#macro __DOTOBJ_DEFAULT_GROUP              "__dotobj_group__"
#macro __DOTOBJ_DEFAULT_MATERIAL_LIBRARY   "__dotobj_library__"
#macro __DOTOBJ_DEFAULT_MATERIAL_SPECIFIC  "__dotobj_material__"
#macro __DOTOBJ_DEFAULT_MATERIAL_NAME      (__DOTOBJ_DEFAULT_MATERIAL_LIBRARY + "." + __DOTOBJ_DEFAULT_MATERIAL_SPECIFIC)

#endregion