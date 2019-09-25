/// Adds materials from an ASCII .mtl file to a ds_map
/// @jujuadams    contact@jujuadams.com
/// 
/// @param map        ds_map to add materials to
/// @param filename   File to read from

var _root_map = argument0;
var _filename = argument1;

var _buffer = buffer_load(_filename);
var _result = dotobj_load_material(_root_map, _filename, _buffer);
buffer_delete(_buffer);

return _result;