function dotobj_class_model() constructor
{
    group_map  = {};
    group_list = [];
    
    static submit = function()
    {
        //Call the submit() method for all groups (which calls the submit() method for all meshes in those groups)
        var _g = 0;
        repeat(array_length(group_list))
        {
            group_list[_g].submit();
            ++_g;
        }
    }
    
    static freeze = function()
    {
        //Call the freeze() method for all groups (which calls the freeze() method for all meshes in those groups)
        var _g = 0;
        repeat(array_length(group_list))
        {
            group_list[_g].freeze();
            ++_g;
        }
    }
}