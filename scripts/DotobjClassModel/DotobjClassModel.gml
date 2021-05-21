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
    }
    
    static SubmitUsingPipe = function(_pipe)
    {
        //Call the SubmitUsingPipe() method for all groups (which calls the SubmitUsingPipe() method for all meshes in those groups)
        var _g = 0;
        repeat(array_length(groups_array))
        {
            groups_array[_g].SubmitUsingPipe(_pipe);
            ++_g;
        }
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
    }
}