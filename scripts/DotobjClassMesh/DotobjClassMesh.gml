/// @param group
/// @param name
/// @param hasTangents

function DotobjClassMesh(_group, _name, _has_tangents) constructor
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
    
    static Submit = function()
    {
        //If a mesh failed to create a vertex buffer then it'll hold the value <undefined>
        //We need to check for this to avoid crashes
        if (vertex_buffer != undefined)
        {
            //Find the material for this mesh from the global material library
            var _material_struct = global.__dotobjMaterialLibrary[? material];
            
            //If a material cannot be found, it'll return <undefined>
            //We use a fallback default material if we can't one for this mesh
            if (!is_struct(_material_struct)) _material_struct = global.__dotobjMaterialLibrary[? __DOTOBJ_DEFAULT_MATERIAL_NAME];
            
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
                if (_diffuse_colour == undefined) _diffuse_colour = c_white;
                
                //Hijack the fog system to force the blend colour, and submit the vertex buffer
                gpu_set_fog(true, _diffuse_colour, 0, 0);
                vertex_submit(vertex_buffer, pr_trianglelist, -1);
                gpu_set_fog(false, c_fuchsia, 0, 0);
            }
        }
    }
    
    static SubmitUsingPipe = function(_pipe)
    {
        //If a mesh failed to create a vertex buffer then it'll hold the value <undefined>
        //We need to check for this to avoid crashes
        if (vertex_buffer != undefined)
        {
            //Find the material for this mesh from the global material library
            var _material_struct = global.__dotobjMaterialLibrary[? material];
            
            //If a material cannot be found, it'll return <undefined>
            //We use a fallback default material if we can't one for this mesh
            if (!is_struct(_material_struct)) _material_struct = global.__dotobjMaterialLibrary[? __DOTOBJ_DEFAULT_MATERIAL_NAME];
            
            //Find the texture for the material
            var _diffuse_texture_struct  = _material_struct.diffuse_map;
            var _dissolve_texture_struct = _material_struct.dissolve_map;
            var _specular_texture_struct = _material_struct.specular_map;
            var _normal_texture_struct   = _material_struct.normal_map;
            
            var _diffuse_is_map  = is_struct( _diffuse_texture_struct);
            var _dissolve_is_map = is_struct(_dissolve_texture_struct);
            var _specular_is_map = is_struct(_specular_texture_struct);
            var _normal_is_map   = is_struct(  _normal_texture_struct);
            
            
            
            //Figure out what kind of shader we need
            var _shader_id = 0;
            
            if (_diffuse_is_map)
            {
                //If the texture is a struct then that means it's using a diffuse map
                _shader_id |= __DOTOBJ_SHADER_SUPPORT.DIFFUSE_MAP;
                
                //Get the texture pointer for the diffuse texture
                var _diffuse_texture_pointer = _diffuse_texture_struct.pointer;
            }
            else
            {
                //If the texture *isn't* a struct then that means it's using a flat diffuse colour
                _shader_id |= __DOTOBJ_SHADER_SUPPORT.DIFFUSE_FLAT;
                
                //Get the diffuse colour
                var _diffuse_colour = _material_struct.diffuse;
                    
                //If the diffuse colour is undefined then render the mesh white
                if (_diffuse_colour == undefined) _diffuse_colour = c_white;
            }
            
            if (_dissolve_is_map)
            {
                //If the texture is a struct then that means it's using a diffuse map
                _shader_id |= __DOTOBJ_SHADER_SUPPORT.DISSOLVE_MAP;
                
                //Get the texture pointer for the diffuse texture
                var _dissolve_texture_pointer = _dissolve_texture_struct.pointer;
            }
            else
            {
                //If the texture *isn't* a struct then that means it's using a flat diffuse value
                //Get the dissolve value
                var _dissolve_value = _material_struct.dissolve;
                    
                //If the dissolve value is undefined then render the mesh completely opaque
                if (_dissolve_value == undefined) _dissolve_value = 1.0;
                
                //Only try to use a flat dissolve value shader if the dissolve value is less than 100%
                if (!DOTOBJ_IGNORE_FULL_DISSOLVE && (_dissolve_value < 1.0))
                {
                    _shader_id |= __DOTOBJ_SHADER_SUPPORT.DISSOLVE_FLAT;
                }
            }
            
            
            
            //Grab the necessary shader from the pipe
            var _shader_definition = _pipe.shaders[$ _shader_id];
            
            //If we couldn't find the required shader, use a fallback instead
            if (_shader_definition == undefined) _shader_definition = _pipe.shaders[$ __DOTOBJ_SHADER_SUPPORT.FALLBACK];
            
            //Set the shader ready for uniform setting
            shader_set(_shader_definition.shader);
            
            
            
            //Presume the gm_BaseTexture sampler slot won't be filled
            var _gm_basetexture = -1;
            
            if (_diffuse_is_map)
            {
                var _stage = _shader_definition[$ "diffuseMap"];
                if (_stage == "gm_BaseTexture")
                {
                    _gm_basetexture = _diffuse_texture_pointer;
                }
                else if (_stage != undefined)
                {
                    texture_set_stage(_stage, _diffuse_texture_pointer);
                }
            }
            else
            {
                var _uniform = _shader_definition[$ "diffuseFlat"];
                if (_uniform != undefined)
                {
                    shader_set_uniform_f(_uniform, colour_get_red(_diffuse_colour)/255, colour_get_green(_diffuse_colour)/255, colour_get_blue(_diffuse_colour)/255);
                }
            }
            
            if (_dissolve_is_map)
            {
                var _stage = _shader_definition[$ "dissolveMap"];
                if (_stage == "gm_BaseTexture")
                {
                    _gm_basetexture = _dissolve_texture_pointer;
                }
                else if (_stage != undefined)
                {
                    texture_set_stage(_stage, _dissolve_texture_pointer);
                }
            }
            
            
            
            //Actually submit the vertex buffer!
            vertex_submit(vertex_buffer, pr_trianglelist, _gm_basetexture);
            
            shader_reset();
            
            //if (!is_struct(_diffuse_texture_struct))
            //{
            //    //If the texture *isn't* a struct then that means it's using a flat diffuse colour
            //    //We get the texture pointer for the texture...
            //    var _diffuse_colour = _material_struct.diffuse;
            //        
            //    //If the diffuse colour is undefined then render the mesh in whatever default we've set
            //    if (_diffuse_colour == undefined) _diffuse_colour = c_white;
            //    
            //    //FIXME - Optimise this!
            //    var _shaderDef = _pipe.shaderDiffuseFlat;
            //    var _shader    = _shaderDef.shader;
            //    
            //    shader_set(_shader);
            //    shader_set_uniform_f(_shaderDef.diffuseFlat, colour_get_red(_diffuse_colour)/255, colour_get_green(_diffuse_colour)/255, colour_get_blue(_diffuse_colour)/255);
            //    vertex_submit(vertex_buffer, pr_trianglelist, -1);
            //    shader_reset();
            //}
            //else
            //{
            //    var _shaderDef = _pipe.shaderDiffuseMap;
            //    var _shader    = _shaderDef.shader;
            //    
            //    shader_set(_shader);
            //    
            //    //If the texture is a struct then that means it's using a diffuse map
            //    //We get the texture pointer for the texture...
            //    var _diffuse_texture_pointer = _diffuse_texture_struct.pointer;
            //    
            //    //...then submit the vertex buffer using the texture
            //    vertex_submit(vertex_buffer, pr_trianglelist, _diffuse_texture_pointer);
            //    
            //    shader_reset();
            //}
        }
    }
    
    static Freeze = function()
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