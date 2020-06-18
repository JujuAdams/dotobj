function dotobj_init()
{
	//Create a global map to store all our material definitions
	global.__dotobj_material_library = ds_map_create();
	global.__dotobj_sprite_map       = ds_map_create();

	//Create a default material
    dotobj_ensure_material(__DOTOBJ_DEFAULT_MATERIAL_LIBRARY, __DOTOBJ_DEFAULT_MATERIAL_SPECIFIC);

    #region Internal macros

	//Always date your work!
    #macro __DOTOBJ_VERSION  "5.0.0"
    #macro __DOTOBJ_DATE     "2020/06/18"

	//Some strings to use for defaults. Change these if you so desire.
    #macro __DOTOBJ_DEFAULT_GROUP              "__dotobj_group__"
    #macro __DOTOBJ_DEFAULT_MATERIAL_LIBRARY   "__dotobj_library__"
    #macro __DOTOBJ_DEFAULT_MATERIAL_SPECIFIC  "__dotobj_material__"
    #macro __DOTOBJ_DEFAULT_MATERIAL_NAME      (__DOTOBJ_DEFAULT_MATERIAL_LIBRARY + "." + __DOTOBJ_DEFAULT_MATERIAL_SPECIFIC)

    #endregion
}



function dotobj_class_model() constructor
{
	group_map  = ds_map_create();
	group_list = ds_list_create();
    
    submit = function()
    {
    	var _g = 0;
    	repeat(ds_list_size(group_list))
    	{
    	    group_map[? group_list[| _g]].submit();
    	    ++_g;
    	}
    }
}



/// @param model
/// @param name
/// @param line
function dotobj_class_group(_model, _name, _line) constructor
{
	//Groups collect together meshes. Most groups will only have a single mesh!
	//The DOTOBJ_OBJECTS_ARE_GROUPS macro allows for objects to be read as groups.

	var _group_map  = _model.group_map;
	var _group_list = _model.group_list;
    
    line      = _line;
    name      = _name;
    mesh_list = ds_list_create();
    
    submit = function()
    {
    	var _m = 0;
    	repeat(ds_list_size(mesh_list))
    	{
             mesh_list[| _m].submit();
    	    ++_m;
    	}
    }
    
	_group_map[? _name] = self;
	ds_list_add(_group_list, _name);
    
	if (DOTOBJ_OUTPUT_DEBUG) show_debug_message("dotobj_class_group(): Created group \"" + string(_name) + "\"");
}



/// @param model
/// @param name
/// @param line
function dotobj_ensure_group(_model, _name, _line)
{
	if (ds_map_exists(_model.group_map, _name))
	{
	    if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_ensure_group(): Warning! Group \"" + string(_name) + "\" has the same name as another group. (ln=" + string(_line) + ")");
	    return _model.group_map[? _name];
	}
    else
    {
        return new dotobj_class_group(_model, _name, _line);
    }
}



/// @param group{array}
/// @param name
function dotobj_class_mesh(_group, _name) constructor
{
	//Meshes are children of groups. Meshes contain a single vertex buffer that drawn via
	//used with vertex_submit(). A mesh has an associated vertex list (really a list of
	//triangles, one vertex at a time), and an associated material. Material definitions
	//come from the .mtl library files. Material libraries (.mtl) must be loaded before
	//any .obj file that uses them.
    
    group_name    = _group.name;
    vertex_list   = ds_list_create();
    vertex_buffer = undefined;
    material      = _name;
    
    submit = function()
    {
    	//If a mesh failed to create a vertex buffer then it'll hold the value <undefined>
    	//We need to check for this to avoid crashes
    	if (vertex_buffer != undefined)
    	{
    	    //Find the material for this mesh from the global material library
    	    var _material_struct = global.__dotobj_material_library[? material];
            
    	    //If a material cannot be found, it'll return <undefined>
    	    //Again, we need to check for this to avoid crashes
    	    if (!is_struct(_material_struct)) _material_struct = global.__dotobj_material_library[? __DOTOBJ_DEFAULT_MATERIAL_NAME];
            
    	    //Find the texture for the material
    	    var _diffuse_texture_struct = _material_struct.diffuse_map;
            
    	    if (is_struct(_diffuse_texture_struct))
    	    {
    	        //If the texture is an array then that means it's using a diffuse map
    	        //We get the texture pointer for the texture...
    	        var _diffuse_texture_pointer = _diffuse_texture_struct.pointer;
                    
    	        //...then submit the vertex buffer using the texture
    	        vertex_submit(vertex_buffer, pr_trianglelist, _diffuse_texture_pointer);
    	    }
    	    else
    	    {
    	        //If the texture *isn't* an array then that means it's using a flat diffuse colour
    	        //We get the texture pointer for the texture...
    	        var _diffuse_colour = _material_struct.diffuse;
                    
    	        //If the diffuse colour is undefined then render the mesh in whatever default we've set
    	        if (_diffuse_colour == undefined) _diffuse_colour = DOTOBJ_DEFAULT_DIFFUSE_RGB;
                
    	        //Hijack the fog system to force the blend colour, and submit the vertex buffer
    	        gpu_set_fog(true, _diffuse_colour, 0, 0);
    	        vertex_submit(vertex_buffer, pr_trianglelist, -1);
    	        gpu_set_fog(false, c_fuchsia, 0, 0);
    	    }
    	}
    }

	ds_list_add(_group.mesh_list, self);
}



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
	ambient_map        = undefined;      //13) Texture array (see dotobj_class_texture)
	diffuse_map        = undefined;      //14) Texture array (see dotobj_class_texture)
	emissive_map       = undefined;      //15) Texture array (see dotobj_class_texture)
	specular_map       = undefined;      //16) Texture array (see dotobj_class_texture)
	specular_exp_map   = undefined;      //17) Texture array (see dotobj_class_texture)
	dissolve_map       = undefined;      //18) Texture array (see dotobj_class_texture)
	decal_map          = undefined;      //19) Texture array (see dotobj_class_texture)
	displacement_map   = undefined;      //20) Texture array (see dotobj_class_texture)
	normal_map         = undefined;      //21) Texture array (see dotobj_class_texture)
    
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



/// @param sprite
/// @param index
/// @param filename
function dotobj_class_texture(_sprite, _index, _filename) constructor
{
	filename          = _filename;
	sprite            = _sprite;
	index             = _index;
	pointer           = sprite_get_texture(_sprite, _index);
	blend_u           = undefined;
	blend_v           = undefined;
	bump_multiplier   = undefined;
	sharpness_boost   = undefined;
	colour_correction = undefined;
	channel           = undefined;
	scalar_range      = undefined;
	uv_clamp          = undefined;
	uv_offset         = undefined;
	uv_scale          = undefined;
	turbulence        = undefined;
	resolution        = undefined;
	invert_v          = undefined;
}



/// @param filename
function dotobj_add_external_sprite(_filename)
{
	if (ds_map_exists(global.__dotobj_sprite_map, _filename)) return global.__dotobj_sprite_map[? _filename];

	var _sprite = sprite_add(_filename, 1, false, false, 0, 0);
	if (_sprite > 0)
	{
	    global.__dotobj_sprite_map[? _filename] = _sprite;
	    show_debug_message("dotobj_add_external_sprite(): Loaded \"" + string(_filename) + "\" (spr=" + string(_sprite) + ")");
	}
	else
	{
	    if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_add_external_sprite(): Warning! Failed to load \"" + string(_filename) + "\"");
	}

	return _sprite;
}