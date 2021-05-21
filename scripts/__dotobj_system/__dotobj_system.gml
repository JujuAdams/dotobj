//Always date your work!
#macro __DOTOBJ_VERSION  "5.1.0"
#macro __DOTOBJ_DATE     "2021/05/21"

//Some strings to use for defaults. Change these if you so desire.
#macro __DOTOBJ_DEFAULT_GROUP              "__dotobj_group__"
#macro __DOTOBJ_DEFAULT_MATERIAL_LIBRARY   "__dotobj_library__"
#macro __DOTOBJ_DEFAULT_MATERIAL_SPECIFIC  "__dotobj_material__"
#macro __DOTOBJ_DEFAULT_MATERIAL_NAME      (__DOTOBJ_DEFAULT_MATERIAL_LIBRARY + "." + __DOTOBJ_DEFAULT_MATERIAL_SPECIFIC)



//Define the vertex formats we want to use
vertex_format_begin();
vertex_format_add_position_3d();                          //              12
vertex_format_add_normal();                               //            + 12
vertex_format_add_colour();                               //            +  4
vertex_format_add_texcoord();                             //            +  8
global.__dotobj_pnct_vertex_format = vertex_format_end(); //vertex size = 36
    
//Define the vertex formats we want to use
vertex_format_begin();
vertex_format_add_position_3d();                                   //        12
vertex_format_add_normal();                                        //      + 12
vertex_format_add_colour();                                        //      +  4
vertex_format_add_texcoord();                                      //      +  8
vertex_format_add_custom(vertex_type_float4, vertex_usage_normal); //      + 16    //I don't think vertex_usage_tangent works...
global.__dotobj_pncttan_vertex_format = vertex_format_end(); //vertex size = 52



//Create a global map to store all our material definitions
global.__dotobj_mtl_file_loaded  = ds_map_create();
global.__dotobj_material_library = ds_map_create();
global.__dotobj_sprite_map       = ds_map_create();
    
//State variables
global.__dotobj_flip_texcoord_v    = false;
global.__dotobj_reverse_triangles  = false;
global.__dotobj_write_tangents     = false;
global.__dotobj_force_tangent_calc = false;
    
//Create a default material
dotobj_ensure_material(__DOTOBJ_DEFAULT_MATERIAL_LIBRARY, __DOTOBJ_DEFAULT_MATERIAL_SPECIFIC);





/// @param filename

function dotobj_add_external_sprite(_filename)
{
    var _sprite = -1;
    
    if (ds_map_exists(global.__dotobj_sprite_map, _filename))
    {
        if (DOTOBJ_OUTPUT_DEBUG) show_debug_message("dotobj_add_external_sprite(): Reusing \"" + string(_filename) + "\"");
        _sprite = global.__dotobj_sprite_map[? _filename];
    }
    
    if (!file_exists(_filename))
    {
        if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_add_external_sprite(): Warning! \"" + string(_filename) + "\" could not be found");
    }
    else
    {
        _sprite = sprite_add(_filename, 1, false, false, 0, 0);
        if (_sprite > 0)
        {
            global.__dotobj_sprite_map[? _filename] = _sprite;
            if (DOTOBJ_OUTPUT_DEBUG) show_debug_message("dotobj_add_external_sprite(): Loaded \"" + string(_filename) + "\" (spr=" + string(_sprite) + ")");
        }
        else
        {
            if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_add_external_sprite(): Warning! Failed to load \"" + string(_filename) + "\"");
        }
    }
    
    return _sprite;
}