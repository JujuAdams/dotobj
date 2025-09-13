/// @param materialName
/// @param hasTangents
/// @param primitive

function DotobjClassMesh() constructor
{
    //Meshes are children of groups. Meshes contain a single vertex buffer that drawn via
    //used with vertex_submit(). A mesh has an associated vertex list (really a list of
    //triangles, one vertex at a time), and an associated material. Material definitions
    //come from the .mtl library files. Material libraries (.mtl) must be loaded before
    //any .obj file that uses them.
    
    group_name     = undefined;
    vertexes_array = [];
    vertex_buffer  = undefined;
    frozen         = false;
    material       = __DOTOBJ_DEFAULT_MATERIAL_NAME;
    has_tangents   = false;
    primitive      = pr_trianglelist;
    
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
                vertex_submit(vertex_buffer, primitive, _diffuse_texture_pointer);
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
                vertex_submit(vertex_buffer, primitive, -1);
                gpu_set_fog(false, c_fuchsia, 0, 0);
            }
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
    
    static Duplicate = function()
    {
        var _new_mesh = new DotobjClassMesh();
        with(_new_mesh)
        {
            material      = other.material;
            has_tangents  = other.has_tangents;
            primitive     = other.primitive;
            vertex_buffer = other.vertex_buffer;
            frozen        = other.frozen;
        }
        
        return _new_mesh;
    }
    
    static Serialize = function(_buffer)
    {
        buffer_write(_buffer, buffer_string, material);
        buffer_write(_buffer, buffer_bool,   has_tangents);
        buffer_write(_buffer, buffer_u8,     primitive);
        
        if (vertex_buffer == undefined)
        {
            buffer_write(_buffer, buffer_u32, 0);
        }
        else
        {
            var _vbuff = buffer_create_from_vertex_buffer(vertex_buffer, buffer_fixed, 1);
            var _vbuff_size = buffer_get_size(_vbuff);
            buffer_write(_buffer, buffer_u32, _vbuff_size);
            
            buffer_resize(_buffer, buffer_get_size(_buffer) + _vbuff_size);
            buffer_copy(_vbuff, 0, _vbuff_size, _buffer, buffer_tell(_buffer));
            buffer_seek(_buffer, buffer_seek_relative, _vbuff_size);
            
            buffer_delete(_vbuff);
        }
        
        return self;
    }
    
    static Deserialize = function(_buffer)
    {
        material     = buffer_read(_buffer, buffer_string);
        has_tangents = buffer_read(_buffer, buffer_bool);
        primitive    = buffer_read(_buffer, buffer_u8);
        
        var _vbuff_size = buffer_read(_buffer, buffer_u32);
        if (_vbuff_size == 0)
        {
            vertex_buffer = undefined;
        }
        else
        {
            var _vbuff = buffer_create(_vbuff_size, buffer_fixed, 1);
            buffer_copy(_buffer, buffer_tell(_buffer), _vbuff_size, _vbuff, 0);
            buffer_seek(_buffer, buffer_seek_relative, _vbuff_size);
            
            vertex_buffer = vertex_create_buffer_from_buffer(_vbuff, has_tangents? global.__dotobjPNCTTanVertexFormat : global.__dotobjPNCTVertexFormat);
            
            buffer_delete(_vbuff);
        }
        
        return self;
    }
    
    static Destroy = function()
    {
        if (vertex_buffer != undefined)
        {
            vertex_delete_buffer(vertex_buffer);
            vertex_buffer = undefined;
        }
        
        return undefined;
    }
    
    static AddTo = function(_group)
    {
        group_name = _group.name;
        array_push(_group.meshes_array, self);
        
        return self;
    }
    
    static SetMaterial = function(_library_name, _material_name)
    {
        material = string(_library_name) + "." + string(_material_name);
        
        return self;
    }
    
    static __FillVertexBufferArray = function(_array)
    {
        if (vertex_buffer != undefined)
        {
            array_push(_array, vertex_buffer);
        }
    }
}