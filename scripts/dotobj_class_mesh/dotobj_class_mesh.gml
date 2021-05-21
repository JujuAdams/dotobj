/// @param group
/// @param name
/// @param hasTangents

function dotobj_class_mesh(_group, _name, _has_tangents) constructor
{
    //Meshes are children of groups. Meshes contain a single vertex buffer that drawn via
    //used with vertex_submit(). A mesh has an associated vertex list (really a list of
    //triangles, one vertex at a time), and an associated material. Material definitions
    //come from the .mtl library files. Material libraries (.mtl) must be loaded before
    //any .obj file that uses them.
    
    group_name     = _group.name;
    vertexes_array = [];
    vertex_buffer  = undefined;
    frozen         = false;
    material       = _name;
    has_tangents   = _has_tangents;
    
    array_push(_group.meshes_array, self);
    
    static submit = function()
    {
        //If a mesh failed to create a vertex buffer then it'll hold the value <undefined>
        //We need to check for this to avoid crashes
        if (vertex_buffer != undefined)
        {
            //Find the material for this mesh from the global material library
            var _material_struct = global.__dotobj_material_library[? material];
            
            //If a material cannot be found, it'll return <undefined>
            //We use a fallback default material if we can't one for this mesh
            if (!is_struct(_material_struct)) _material_struct = global.__dotobj_material_library[? __DOTOBJ_DEFAULT_MATERIAL_NAME];
            
            //Find the texture for the material
            var _diffuse_texture_struct = _material_struct.diffuse_map;
            
            if (is_struct(_diffuse_texture_struct))
            {
                //If the texture is a struct then that means it's using a diffuse map
                //We get the texture pointer for the texture...
                var _diffuse_texture_pointer = _diffuse_texture_struct.pointer;
                    
                //...then submit the vertex buffer using the texture
                vertex_submit(vertex_buffer, pr_trianglelist, _diffuse_texture_pointer);
            }
            else
            {
                //If the texture *isn't* a struct then that means it's using a flat diffuse colour
                //We get the texture pointer for the texture...
                var _diffuse_colour = _material_struct.diffuse;
                    
                //If the diffuse colour is undefined then render the mesh in whatever default we've set
                if (_diffuse_colour == undefined) _diffuse_colour = DOTOBJ_DEFAULT_VERTEX_COLOR;
                
                //Hijack the fog system to force the blend colour, and submit the vertex buffer
                gpu_set_fog(true, _diffuse_colour, 0, 0);
                vertex_submit(vertex_buffer, pr_trianglelist, -1);
                gpu_set_fog(false, c_fuchsia, 0, 0);
            }
        }
    }
    
    static freeze = function()
    {
        //If a mesh failed to create a vertex buffer then it'll hold the value <undefined>
        //We need to check for this to avoid crashes
        if (vertex_buffer != undefined)
        {
            if (!frozen)
            {
                frozen = true;
                vertex_freeze(vertex_buffer);
            }
        }
    }
}