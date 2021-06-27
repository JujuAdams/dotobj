function DotobjClassModel() constructor
{
    sha1             = undefined;
    groups_struct    = {};
    groups_array     = [];
    material_library = "";
    materials_array  = [];
    
    static Submit = function()
    {
        //Call the Submit() method for all groups (which calls the Submit() method for all meshes in those groups)
        var _g = 0;
        repeat(array_length(groups_array))
        {
            groups_array[_g].Submit();
            ++_g;
        }
        
        return self;
    }
    
    static Freeze = function()
    {
        //Call the Freeze() method for all groups (which calls the Freeze() method for all meshes in those groups)
        var _g = 0;
        repeat(array_length(groups_array))
        {
            groups_array[_g].Freeze();
            ++_g;
        }
        
        return self;
    }
    
    static Duplicate = function()
    {
        var _new_model = new DotobjClassModel();
        
        var _i = 0;
        repeat(array_length(groups_array))
        {
            groups_array[_i].Duplicate().AddTo(_new_model);
            ++_i;
        }
        
        return _new_model;
    }
    
    static Serialize = function(_buffer)
    {
        buffer_write(_buffer, buffer_string, "dotobj @jujuadams");
        buffer_write(_buffer, buffer_string, __DOTOBJ_VERSION);
        buffer_write(_buffer, buffer_string, sha1);
        buffer_write(_buffer, buffer_string, material_library);
        
        var _size = array_length(materials_array);
        buffer_write(_buffer, buffer_u16, _size);
        var _i = 0;
        repeat(_size)
        {
            buffer_write(_buffer, buffer_string, materials_array[_i]);
            ++_i;
        }
        
        var _size = array_length(groups_array);
        buffer_write(_buffer, buffer_u16, _size);
        var _i = 0;
        repeat(_size)
        {
            groups_array[_i].Serialize(_buffer);
            ++_i;
        }
        
        return self;
    }
    
    static Deserialize = function(_buffer)
    {
        var _header = buffer_read(_buffer, buffer_string);
        if (_header != "dotobj @jujuadams")
        {
            __DotobjError("File is not a dotobj raw file");
            return undefined;
        }
        
        var _version = buffer_read(_buffer, buffer_string);
        if (_version != __DOTOBJ_VERSION)
        {
            __DotobjError("Version mismatch (file=", _version, ", dotobj=", __DOTOBJ_VERSION, ")");
            return undefined;
        }
        
        sha1 = buffer_read(_buffer, buffer_string);
        
        var _material_library = buffer_read(_buffer, buffer_string);
        if (_material_library != "") DotobjMaterialLoadFile(_material_library);
        
        repeat(buffer_read(_buffer, buffer_u16))
        {
            array_push(materials_array, buffer_read(_buffer, buffer_string));
        }
        
        repeat(buffer_read(_buffer, buffer_u16))
        {
            with(new DotobjClassGroup())
            {
                Deserialize(_buffer);
                AddTo(other);
            }
        }
        
        return self;
    }
    
    static Destroy = function()
    {
        var _g = 0;
        repeat(array_length(groups_array))
        {
            groups_array[_g].Destroy();
            ++_g;
        }
        
        groups_struct = {};
        groups_array  = [];
        
        return undefined;
    }
    
    static SetMaterialForMeshes = function(_library_name, _material_name)
    {
        var _i = 0;
        repeat(array_length(groups_array))
        {
            groups_array[_i].SetMaterialForMeshes(_library_name, _material_name);
            ++_i;
        }
        
        return self;
    }
    
    static GetFirstMesh = function()
    {
        if (array_length(groups_array) <= 0) return undefined;
        
        var _group = groups_array[0];
        if (array_length(_group.meshes_array) <= 0) return undefined;
        
        return _group.meshes_array[0];
    }
    
    static GetMaterials = function()
    {
        var _array = array_create(array_length(materials_array));
        
        var _i = 0;
        repeat(array_length(materials_array))
        {
            _array[@ _i] = global.__dotobjMaterialLibrary[? materials_array[_i]];
            ++_i;
        }
        
        return _array;
    }
}