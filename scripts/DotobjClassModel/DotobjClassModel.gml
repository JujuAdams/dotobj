// Feather disable all

/// The main constructor ("class") that acts as the root for .obj models. The model struct has the
/// following public methods:
/// 
/// `.Destroy()`
///     Free memory associated with the model. You should call this when you no longer need the
///     model in memory. Please note this does not free materials.
/// 
/// `.Submit()`
///     Submit all vertex buffers in the model. No shaders are applied giving you the option to
///     customize drawing as you see fit.
/// 
/// `.GetAABB()`
///     Returns a struct containing the axis-aligned bounding box for the model.
/// 
/// `.Freeze()`
///     Freezes all vertex buffers. This will speed up rendering.
/// 
/// `.Duplicate()`
///     Returns a duplicate of the model. Model duplicates will be unfrozen.
/// 
/// `.Serialize(buffer)`
///     Writes the model into a buffer using a fast to load propriatary format. This is the same
///     format that `DotobjModelRawSave()` uses. Please note that frozen models cannot be
///     serialized.
/// 
/// `.Deserialize(buffer)`
///     Replaces model data with binary data loaded from a buffer. The binary data should have
///     been written using the `.Serialize()` method above.
/// 
/// `.SetMaterialForMeshes(libraryName, materialName)`
///     Overwrites all materials for all meshes to the indicated material.
/// 
/// `.GetFirstMesh()`
///     Returns the first mesh in the model.
/// 
/// `.GetMaterials()`
///     Returns an array of all materials used by this model.
/// 
/// `.GetVertexBufferArray()`
///     Returns an array of all vertex buffers used by this model.

function DotobjClassModel() constructor
{
    aabb = {
        x1 : 0,
        y1 : 0,
        z1 : 0,
        x2 : 0,
        y2 : 0,
        z2 : 0,
    };
    
    sha1             = undefined;
    groups_struct    = {};
    groups_array     = [];
    material_library = "";
    materials_array  = [];
    loaded           = false;
    
    static GetLoaded = function()
    {
        return loaded;
    }
    
    static GetAABB = function()
    {
        return aabb;
    }
    
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
    
    static ConvertToWireframe = function()
    {
        //Call the ConvertToWireframe() method for all groups (which calls the ConvertToWireframe() method for all meshes in those groups)
        var _g = 0;
        repeat(array_length(groups_array))
        {
            groups_array[_g].ConvertToWireframe();
            ++_g;
        }
        
        return self;
    }
    
    static Duplicate = function()
    {
        if (not loaded)
        {
            __DotobjError("Cannot duplicate a model that has not finished loading");
        }
        
        var _new_model = new DotobjClassModel();
        
        var _i = 0;
        repeat(array_length(groups_array))
        {
            groups_array[_i].Duplicate().AddTo(_new_model);
            ++_i;
        }
        
        _new_model.loaded = true;
        return _new_model;
    }
    
    static Serialize = function(_buffer)
    {
        if (not loaded)
        {
            __DotobjError("Cannot serialize a model that has not finished loading");
        }
        
        buffer_write(_buffer, buffer_string, "dotobj juju adams");
        buffer_write(_buffer, buffer_string, DOTOBJ_SERIALIZE_VERSION);
        buffer_write(_buffer, buffer_string, sha1);
        buffer_write(_buffer, buffer_string, material_library);
        
        buffer_write(_buffer, buffer_f64, aabb.x1);
        buffer_write(_buffer, buffer_f64, aabb.y1);
        buffer_write(_buffer, buffer_f64, aabb.z1);
        buffer_write(_buffer, buffer_f64, aabb.x2);
        buffer_write(_buffer, buffer_f64, aabb.y2);
        buffer_write(_buffer, buffer_f64, aabb.z2);
        
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
        if (_header != "dotobj juju adams")
        {
            __DotobjError("File is not a dotobj raw file");
            return undefined;
        }
        
        var _version = buffer_read(_buffer, buffer_string);
        if (_version != DOTOBJ_SERIALIZE_VERSION)
        {
            __DotobjError("Version mismatch (file=", _version, ", dotobj=", DOTOBJ_VERSION, ")");
            return undefined;
        }
        
        sha1 = buffer_read(_buffer, buffer_string);
        
        var _material_library = buffer_read(_buffer, buffer_string);
        if (_material_library != "") DotobjMtlLoadFromFile(_material_library);
        
        aabb.x1 = buffer_read(_buffer, buffer_f64);
        aabb.y1 = buffer_read(_buffer, buffer_f64);
        aabb.z1 = buffer_read(_buffer, buffer_f64);
        aabb.x2 = buffer_read(_buffer, buffer_f64);
        aabb.y2 = buffer_read(_buffer, buffer_f64);
        aabb.z2 = buffer_read(_buffer, buffer_f64);
        
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
        
        loaded = true;
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
        if (not loaded)
        {
            __DotobjTrace("Warning! It is not recommended to call `.SetMaterialForMeshes()` on a model that has not finished loading");
        }
        
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
        static _materialLibraryMap = __DotobjSystem().__materialLibraryMap;
        
        var _array = [];
        
        var _i = 0;
        repeat(array_length(materials_array))
        {
            var _material = _materialLibraryMap[? materials_array[_i]];
            if (is_struct(_material)) array_push(_array, _material);
            ++_i;
        }
        
        return _array;
    }
    
    static GetVertexBufferArray = function()
    {
        var _array = [];
        
        var _i = 0;
        repeat(array_length(groups_array))
        {
            groups_array[_i].__FillVertexBufferArray(_array);
            ++_i;
        }
        
        return _array;
    }
}