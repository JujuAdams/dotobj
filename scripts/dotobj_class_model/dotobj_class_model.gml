function dotobj_class_model() constructor
{
    group_map  = ds_map_create();
    group_list = ds_list_create();
    
    submit = function()
    {
        //Call the submit() method for all groups (which calls the submit() method for all meshes in those groups)
        var _g = 0;
        repeat(ds_list_size(group_list))
        {
            group_map[? group_list[| _g]].submit();
            ++_g;
        }
    }
    
    freeze = function()
    {
        //Call the freeze() method for all groups (which calls the freeze() method for all meshes in those groups)
        var _g = 0;
        repeat(ds_list_size(group_list))
        {
            group_map[? group_list[| _g]].freeze();
            ++_g;
        }
    }
}