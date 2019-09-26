/// @param model{array}

var _model_array = argument0;

var _group_map  = _model_array[eDotObjModel.GroupMap ];
var _group_list = _model_array[eDotObjModel.GroupList];

var _g = 0;
repeat(ds_list_size(_group_list))
{
    var _group_name      = _group_list[| _g];
    var _group_array     = _group_map[? _group_name];
    var _group_mesh_list = _group_array[eDotObjGroup.MeshList];
    
    var _m = 0;
    repeat(ds_list_size(_group_mesh_list))
    {
        var _mesh_array = _group_mesh_list[| _m];
        
        var _vertex_buffer = _mesh_array[eDotObjMesh.VertexBuffer];
        if (_vertex_buffer != undefined)
        {
            var _mesh_material = _mesh_array[eDotObjMesh.Material];
            var _material_array = global.__dotobj_material_library[? _mesh_material];
            if (_material_array != undefined)
            {
                var _diffuse_texture_array = _material_array[eDotObjMaterial.DiffuseMap];
                if (_diffuse_texture_array != undefined)
                {
                    var _diffuse_texture_pointer = _diffuse_texture_array[eDotObjTexture.Pointer];
                    vertex_submit(_vertex_buffer, pr_trianglelist, _diffuse_texture_pointer);
                }
                else
                {
                    var _diffuse_colour = _material_array[eDotObjMaterial.Diffuse];
                    if (_diffuse_colour == undefined) _diffuse_colour = c_white;
                    gpu_set_fog(true, _diffuse_colour, 0, 0);
                    vertex_submit(_vertex_buffer, pr_trianglelist, -1);
                    gpu_set_fog(false, c_fuchsia, 0, 0);
                }
            }
        }
        
        ++_m;
    }
    
    ++_g;
}