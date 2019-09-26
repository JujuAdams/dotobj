/// @param group{array}
/// @param name

//Meshes are children of groups. Meshes contain a single vertex buffer that drawn via
//used with vertex_submit(). A mesh has an associated vertex list (really a list of
//triangles, one vertex at a time), and an associated material. Material definitions
//come from the .mtl library files. Material libraries (.mtl) must be loaded before
//any .obj file that uses them.
enum eDotObjMesh
{
    GroupName,     //string
    VertexList,    //list
    VertexBuffer,  //vertex buffer
    Material,      //string
    __Size
}

var _group = argument0;
var _name  = argument1;

var _array       = array_create(eDotObjMesh.__Size, undefined);
var _vertex_list = ds_list_create();
_array[@ eDotObjMesh.GroupName   ] = _group[@ eDotObjGroup.Name];
_array[@ eDotObjMesh.VertexList  ] = _vertex_list;
_array[@ eDotObjMesh.VertexBuffer] = undefined;
_array[@ eDotObjMesh.Material    ] = _name;

ds_list_add(_group[@ eDotObjGroup.MeshList], _array);

return _array;