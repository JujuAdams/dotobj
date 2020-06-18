/// Adds materials from an ASCII .mtl file to the global material library.
/// @jujuadams    contact@jujuadams.com
/// 
/// @param filename   File to read from

function dotobj_material_load_file(_filename)
{
	var _buffer = buffer_load(_filename);
	var _result = dotobj_material_load(_filename, _buffer);
	buffer_delete(_buffer);

	return _result;
}