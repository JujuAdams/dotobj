/// @param name
/// @param line

function DotobjClassGroup(_name, _line) constructor
{
    //Groups collect together meshes. Most groups will only have a single mesh!
    //The DOTOBJ_OBJECTS_ARE_GROUPS macro allows for objects to be read as groups.
    
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
        
        return self;
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
        
        return self;
    }
    
    static Duplicate = function()
    {
        var _new_group = new DotobjClassGroup(name, line);
        
        var _i = 0;
        repeat(array_length(meshes_array))
        {
            meshes_array[_i].Duplicate().AddTo(_new_group);
            ++_i;
        }
        
        return _new_group;
    }
    
    static AddTo = function(_model)
    {
        _model.groups_struct[$ name] = self;
        array_push(_model.groups_array, self);
        
        return self;
    }
    
    static SetMaterialForMeshes = function(_library_name, _material_name)
    {
        var _i = 0;
        repeat(array_length(meshes_array))
        {
            meshes_array[_i].SetMaterial(_library_name, _material_name);
            ++_i;
        }
        
        return self;
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
        return _model.groups_struct[$ _name];
    }
    else
    {
        var _group = new DotobjClassGroup(_name, _line);
        _group.AddTo(_model);
        return _group;
    }
}