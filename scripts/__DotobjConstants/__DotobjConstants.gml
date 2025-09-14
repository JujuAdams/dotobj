// Feather disable all

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// You're welcome to use any of the following macros in your game but ... //
//                                                                        //
//                       DO NOT EDIT THIS SCRIPT                          //
//                       Bad things might happen.                         //
//                                                                        //
//        Customisation options can be found in `__DotobjConfig()`.       //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

//Always date your work!
#macro __DOTOBJ_VERSION  "6.0.0 (alpha)"
#macro __DOTOBJ_DATE     "2025-01-17"

//Some strings to use for defaults. Change these if you so desire.
#macro __DOTOBJ_DEFAULT_GROUP              "__dotobj_group__"
#macro __DOTOBJ_DEFAULT_MATERIAL_LIBRARY   "__dotobj_library__"
#macro __DOTOBJ_DEFAULT_MATERIAL_SPECIFIC  "__dotobj_material__"
#macro __DOTOBJ_DEFAULT_MATERIAL_NAME      (__DOTOBJ_DEFAULT_MATERIAL_LIBRARY + "." + __DOTOBJ_DEFAULT_MATERIAL_SPECIFIC)

//Macro to access the inner material library ds_map
#macro DOTOBJ_MATERIAL_LIBRARY_MAP  global.__dotobjMaterialLibrary