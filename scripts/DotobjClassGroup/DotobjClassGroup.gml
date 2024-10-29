/// @param name
/// @param line

function DotobjClassGroup() constructor
{
    //Groups collect together meshes. Most groups will only have a single mesh!
    //The DOTOBJ_OBJECTS_ARE_GROUPS macro allows for objects to be read as groups.
    
    line         = 0;
    name         = undefined;
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
        var _new_group = new DotobjClassGroup();
        with(_new_group)
        {
            name = other.name;
            line = other.line;
        }
        
        var _i = 0;
        repeat(array_length(meshes_array))
        {
            meshes_array[_i].Duplicate().AddTo(_new_group);
            ++_i;
        }
        
        return _new_group;
    }
    
    static Merge = function(_model)
    {
        //Merge an entire model's meshes into the first mesh of this group
        var _m = 0;
        repeat(array_length(meshes_array))
        {
            if (meshes_array[_m].vertex_buffer == undefined) continue;
            if (meshes_array[_m].Merge(_model) == true) return true;
            ++_m;
        }
        return false;
    }
    
    
    static Serialize = function(_buffer)
    {
        buffer_write(_buffer, buffer_string, name);
        buffer_write(_buffer, buffer_u32,    line);
        
        var _size = array_length(meshes_array);
        buffer_write(_buffer, buffer_u16, _size);
        var _i = 0;
        repeat(_size)
        {
            meshes_array[_i].Serialize(_buffer);
            ++_i;
        }
        
        return self;
    }
    
    static Deserialize = function(_buffer)
    {
        name = buffer_read(_buffer, buffer_string);
        line = buffer_read(_buffer, buffer_u32);
        
        repeat(buffer_read(_buffer, buffer_u16))
        {
            with(new DotobjClassMesh())
            {
                Deserialize(_buffer);
                AddTo(other);
            }
        }
        
        return self;
    }
    
    static Destroy = function()
    {
        var _m = 0;
        repeat(array_length(meshes_array))
        {
            meshes_array[_m].Destroy();
            ++_m;
        }
        
        meshes_array = [];
        
        return undefined;
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
        var _group = new DotobjClassGroup();
        with(_group)
        {
            name = _name;
            line = _line;
            
            if (DOTOBJ_OUTPUT_DEBUG) show_debug_message("DotobjClassGroup(): Created group \"" + string(name) + "\"");
            
            AddTo(_model);
        }
        
        return _group;
    }
}