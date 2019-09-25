/// Transforms coordinates (e.g. positions, normals) in a vertex buffer
/// 
/// This can be used to translate, scale, rotate etc. a vertex buffer.
/// 
/// Please note that if you transform the positions in a vertex buffer then
/// you may also need to transform the normals to match.
/// 
/// @param vertexBuffer
/// @param vertexFormat
/// @param matrix
/// @param vertexFormatSize{bytes}
/// @param vertexFormatOffset{bytes}
/// @param destroyOldVertexBuffer

var _vbuffer     = argument0;
var _vformat     = argument1;
var _matrix      = argument2;
var _vertex_size = argument3;
var _offset      = argument4;
var _destroy_old = argument5;

var _buffer = buffer_create_from_vertex_buffer(_vbuffer, buffer_fixed, 1);
if (_destroy_old) vertex_delete_buffer(_vbuffer);

var _tell = _offset;
repeat(buffer_get_size(_buffer) div _vertex_size)
{
    var _x = buffer_peek(_buffer, _tell    , buffer_f32);
    var _y = buffer_peek(_buffer, _tell + 4, buffer_f32);
    var _z = buffer_peek(_buffer, _tell + 8, buffer_f32);
    
    var _new_position = matrix_transform_vertex(_matrix, _x, _y, _z);
    
    buffer_poke(_buffer, _tell    , buffer_f32, _new_position[0]);
    buffer_poke(_buffer, _tell + 4, buffer_f32, _new_position[1]);
    buffer_poke(_buffer, _tell + 8, buffer_f32, _new_position[2]);
    _tell += _vertex_size;
}

var _vbuffer = vertex_create_buffer_from_buffer(_buffer, _vformat);
buffer_delete(_buffer);
return _vbuffer;