//Always date your work!
#macro  __DOTOBJ_VERSION  "5.3.2"
#macro  __DOTOBJ_DATE     "2021/06/30"

//Some strings to use for defaults. Change these if you so desire.
#macro  __DOTOBJ_DEFAULT_GROUP              "__dotobj_group__"
#macro  __DOTOBJ_DEFAULT_MATERIAL_LIBRARY   "__dotobj_library__"
#macro  __DOTOBJ_DEFAULT_MATERIAL_SPECIFIC  "__dotobj_material__"
#macro  __DOTOBJ_DEFAULT_MATERIAL_NAME      (__DOTOBJ_DEFAULT_MATERIAL_LIBRARY + "." + __DOTOBJ_DEFAULT_MATERIAL_SPECIFIC)

//Macro to access the inner material library ds_map
#macro  DOTOBJ_MATERIAL_LIBRARY_MAP  global.__dotobjMaterialLibrary



//Define the vertex formats we want to use
vertex_format_begin();
vertex_format_add_position_3d();                       //              12
vertex_format_add_normal();                            //            + 12
vertex_format_add_colour();                            //            +  4
vertex_format_add_texcoord();                          //            +  8
global.__dotobjPNCTVertexFormat = vertex_format_end(); //vertex size = 36
    
//Define the vertex formats we want to use
vertex_format_begin();
vertex_format_add_position_3d();                                   //        12
vertex_format_add_normal();                                        //      + 12
vertex_format_add_colour();                                        //      +  4
vertex_format_add_texcoord();                                      //      +  8
vertex_format_add_custom(vertex_type_float4, vertex_usage_colour); //      + 16    //I don't think vertex_usage_tangent works...
global.__dotobjPNCTTanVertexFormat = vertex_format_end(); //vertex size = 52



//Create a global map to store all our material definitions
global.__dotobjMtlFileLoaded   = ds_map_create();
global.__dotobjMaterialLibrary = ds_map_create();
global.__dotobjSpriteMap       = ds_map_create();
    
//State variables
global.__dotobjFlipTexcoordV    = false;
global.__dotobjReverseTriangles = false;
global.__dotobjWriteTangents    = false;
global.__dotobjForceTangentCalc = false;
global.__dotobjWireframe        = false;
global.__dotobjTransformOnLoad  = false;
    
//Create a default material
__DotobjEnsureMaterial(__DOTOBJ_DEFAULT_MATERIAL_LIBRARY, __DOTOBJ_DEFAULT_MATERIAL_SPECIFIC);





function __DotobjError()
{
    var _string = "dotobj:\n";
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    show_error(_string + "\n ", true);
    return _string;
}



/// @param filename
function __DotobjAddExternalSprite(_filename)
{
    var _sprite = -1;
    
    if (ds_map_exists(global.__dotobjSpriteMap, _filename))
    {
        if (DOTOBJ_OUTPUT_DEBUG) show_debug_message("__DotobjAddExternalSprite(): Reusing \"" + string(_filename) + "\"");
        _sprite = global.__dotobjSpriteMap[? _filename];
    }
    
    if (!file_exists(_filename))
    {
        if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("__DotobjAddExternalSprite(): Warning! \"" + string(_filename) + "\" could not be found");
    }
    else
    {
        _sprite = sprite_add(_filename, 1, false, false, 0, 0);
        if (_sprite > 0)
        {
            global.__dotobjSpriteMap[? _filename] = _sprite;
            if (DOTOBJ_OUTPUT_DEBUG) show_debug_message("__DotobjAddExternalSprite(): Loaded \"" + string(_filename) + "\" (spr=" + string(_sprite) + ")");
        }
        else
        {
            if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("__DotobjAddExternalSprite(): Warning! Failed to load \"" + string(_filename) + "\"");
        }
    }
    
    return _sprite;
}