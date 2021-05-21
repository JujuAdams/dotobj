function DotobjClassModel() constructor
{
    groups_struct = {};
    groups_array  = [];
    
    static Submit = function()
    {
        //Call the submit() method for all groups (which calls the submit() method for all meshes in those groups)
        var _g = 0;
        repeat(array_length(groups_array))
        {
            groups_array[_g].Submit();
            ++_g;
        }
    }
    
    static Freeze = function()
    {
        //Call the freeze() method for all groups (which calls the freeze() method for all meshes in those groups)
        var _g = 0;
        repeat(array_length(groups_array))
        {
            groups_array[_g].Freeze();
            ++_g;
        }
    }
}