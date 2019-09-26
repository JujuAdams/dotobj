enum eDotObjModel
{
    GroupMap,
    GroupList,
    __Size
}

var _array      = array_create(eDotObjModel.__Size, undefined);
var _group_map  = ds_map_create();
var _group_list = ds_list_create();
_array[@ eDotObjModel.GroupMap ] = _group_map;
_array[@ eDotObjModel.GroupList] = _group_list;

return _array;