/// @param model{array}
/// @param name
/// @param line

//Groups collect together meshes. Most groups will only have a single mesh!
//The DOTOBJ_OBJECTS_ARE_GROUPS macro allows for objects to be read as groups.
enum eDotObjGroup
{
    Line,
    Name,
    MeshList,
    __Size
}

var _model = argument0;
var _name  = argument1;
var _line  = argument2;

var _group_map  = _model[eDotObjModel.GroupMap ];
var _group_list = _model[eDotObjModel.GroupList];
if (ds_map_exists(_group_map, _name))
{
    if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("dotobj_new_group(): Warning! Group \"" + string(_name) + "\" has the same name as another group. (ln=" + string(_line) + ")");
    return _group_map[? _name];
}

var _array       = array_create(eDotObjMesh.__Size, undefined);
var _mesh_list = ds_list_create();
_array[@ eDotObjGroup.Line    ] = _line;
_array[@ eDotObjGroup.Name    ] = _name;
_array[@ eDotObjGroup.MeshList] = _mesh_list;

_group_map[? _name] = _array;
ds_list_add(_group_list, _name);

if (DOTOBJ_OUTPUT_DEBUG) show_debug_message("dotobj_new_group(): Created group \"" + string(_name) + "\"");

return _array;