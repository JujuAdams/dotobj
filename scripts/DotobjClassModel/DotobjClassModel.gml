function DotobjClassModel() constructor
{
    groups_struct = {};
    groups_array  = [];
    
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
}