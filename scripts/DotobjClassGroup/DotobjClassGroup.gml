/// @param model
/// @param name
/// @param line

function DotobjClassGroup(_model, _name, _line) constructor
{
    //Groups collect together meshes. Most groups will only have a single mesh!
    //The DOTOBJ_OBJECTS_ARE_GROUPS macro allows for objects to be read as groups.
    _model.groups_struct[$ _name] = self;
    array_push(_model.groups_array, self);
    
    line         = _line;
    name         = _name;
    meshes_array = [];
    
    static Submit = function()
    {
        //Call the Submit() method for meshes
        var _m = 0;
        repeat(array_length(meshes_array))
        {
            meshes_array[_m].Submit();
            ++_m;
        }
    }
    
    static SubmitUsingPipe = function(_pipe)
    {
        //Call the SubmitUsingPipe() method for meshes
        var _m = 0;
        repeat(array_length(meshes_array))
        {
             meshes_array[_m].SubmitUsingPipe(_pipe);
            ++_m;
        }
    }
    
    static Freeze = function()
    {
        //Call the Freeze() method for meshes
        var _m = 0;
        repeat(array_length(meshes_array))
        {
             meshes_array[_m].Freeze();
            ++_m;
        }
    }
    
    if (DOTOBJ_OUTPUT_DEBUG) show_debug_message("DotobjClassGroup(): Created group \"" + string(_name) + "\"");
}





/// @param model
/// @param name
/// @param line

function __DotobjEnsureGroup(_model, _name, _line)
{
    if (variable_struct_exists(_model.groups_struct, _name))
    {
        if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("__DotobjEnsureGroup(): Warning! Group \"" + string(_name) + "\" has the same name as another group. (ln=" + string(_line) + ")");
        return _model.groups_struct[? _name];
    }
    else
    {
        return new DotobjClassGroup(_model, _name, _line);
    }
}