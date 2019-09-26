/// @param model{array}

var _model_array = argument0;

//Get the group data structures
//The group list contains all the keys that are in the map
//This means we can iterate over the list instead of the map, which is much faster
var _group_map  = _model_array[eDotObjModel.GroupMap ];
var _group_list = _model_array[eDotObjModel.GroupList];

var _g = 0;
repeat(ds_list_size(_group_list))
{
    var _group_name      = _group_list[| _g];
    
    //Get the group for this iteration, and fetch its list of child meshes
    var _group_array     = _group_map[? _group_name];
    var _group_mesh_list = _group_array[eDotObjGroup.MeshList];
    
    var _m = 0;
    repeat(ds_list_size(_group_mesh_list))
    {
        //Get our mesh, and get its material and vertex buffer
        var _mesh_array    = _group_mesh_list[| _m];
        var _vertex_buffer = _mesh_array[eDotObjMesh.VertexBuffer];
        var _mesh_material = _mesh_array[eDotObjMesh.Material];
        
        //If a mesh failed to create a vertex buffer then it'll hold the value <undefined>
        //We need to check for this to avoid crashes
        if (_vertex_buffer != undefined)
        {
            //Find the material for this mesh from the global material library
            var _material_array = global.__dotobj_material_library[? _mesh_material];
            
            //If a material cannot be found, it'll return <undefined>
            //Again, we need to check for this to avoid crashes
            if (is_array(_material_array))
            {
                //Find the texture for the material
                var _diffuse_texture_array = _material_array[eDotObjMaterial.DiffuseMap];
                
                if (is_array(_diffuse_texture_array))
                {
                    //If the texture is an array then that means it's using a diffuse map
                    //We get the texture pointer for the texture...
                    var _diffuse_texture_pointer = _diffuse_texture_array[eDotObjTexture.Pointer];
                    
                    //...then submit the vertex buffer using the texture
                    vertex_submit(_vertex_buffer, pr_trianglelist, _diffuse_texture_pointer);
                }
                else
                {
                    //If the texture *isn't* an array then that means it's using a flat diffuse colour
                    //We get the texture pointer for the texture...
                    var _diffuse_colour = _material_array[eDotObjMaterial.Diffuse];
                    
                    //If the diffuse colour is undefined then render the mesh in whatever default we've set
                    if (_diffuse_colour == undefined) _diffuse_colour = DOTOBJ_DEFAULT_DIFFUSE_RGB;
                    
                    //Hijack the fog system to force the blend colour, and submit the vertex buffer
                    gpu_set_fog(true, _diffuse_colour, 0, 0);
                    vertex_submit(_vertex_buffer, pr_trianglelist, -1);
                    gpu_set_fog(false, c_fuchsia, 0, 0);
                }
            }
        }
        
        //Next mesh for this group please
        ++_m;
    }
    
    //Next group
    ++_g;
}