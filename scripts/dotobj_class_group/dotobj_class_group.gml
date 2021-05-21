/// @param model
/// @param name
/// @param line

function dotobj_class_group(_model, _name, _line) constructor
{
    //Groups collect together meshes. Most groups will only have a single mesh!
    //The DOTOBJ_OBJECTS_ARE_GROUPS macro allows for objects to be read as groups.
    _model.group_map[$ _name] = self;
    array_push(_model.group_list, self);
    
    line      = _line;
    name      = _name;
    mesh_list = [];
    
    static submit = function()
    {
        //Call the submit() method for meshes
        var _m = 0;
        repeat(array_length(mesh_list))
        {
             mesh_list[_m].submit();
            ++_m;
        }
    }
    
    static freeze = function()
    {
        //Call the freeze() method for meshes
        var _m = 0;
        repeat(array_length(mesh_list))
        {
             mesh_list[_m].freeze();
            ++_m;
        }
    }
    
    if (DOTOBJ_OUTPUT_DEBUG) show_debug_message("dotobj_class_group(): Created group \"" + string(_name) + "\"");
}





/// @param model
/// @param name
/// @param line

function dotobj_ensure_group(_model, _name, _line)
{
    if (variable_struct_exists(_model.group_map, _name))
    {
        if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_ensure_group(): Warning! Group \"" + string(_name) + "\" has the same name as another group. (ln=" + string(_line) + ")");
        return _model.group_map[? _name];
    }
    else
    {
        return new dotobj_class_group(_model, _name, _line);
    }
}