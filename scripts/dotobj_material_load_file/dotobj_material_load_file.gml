/// Adds materials from an ASCII .mtl file to a ds_map
/// @jujuadams    contact@jujuadams.com
/// 
/// @param filename   File to read from

var _filename = argument0;

var _buffer = buffer_load(_filename);
var _result = dotobj_material_load(_filename, _buffer);
buffer_delete(_buffer);

return _result;