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
        //Call the submit() method for meshes
        var _m = 0;
        repeat(ds_list_size(mesh_list))
        {
             mesh_list[| _m].submit();
            ++_m;
        }
    }
    
    freeze = function()
    {
        //Call the freeze() method for meshes
        var _m = 0;
        repeat(ds_list_size(mesh_list))
        {
             mesh_list[| _m].freeze();
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