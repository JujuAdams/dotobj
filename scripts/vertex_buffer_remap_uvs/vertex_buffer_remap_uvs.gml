/// Remaps the UVs of a vertex buffer into another UV-space (to match a sprite etc.)
/// 
/// This script assumes the UV coordinates in the vertex buffer are normalised,
/// that is in the range (0,0) -> (1,1).
/// 
/// @param vertexBuffer
/// @param vertexFormat
/// @param newTextureUVs
/// @param vertexFormatSize{bytes}
/// @param vertexFormatOffset{bytes}
/// @param destroyOldVertexBuffer

var _vbuffer     = argument0;
var _vformat     = argument1;
var _uvs         = argument2;
var _vertex_size = argument3;
var _offset      = argument4;
var _destroy_old = argument5;

var _uv_l = _uvs[0];
var _uv_t = _uvs[1];
var _uv_r = _uvs[2];
var _uv_b = _uvs[3];

var _buffer = buffer_create_from_vertex_buffer(_vbuffer, buffer_fixed, 1);
if (_destroy_old) vertex_delete_buffer(_vbuffer);

var _tell = _offset;
repeat(buffer_get_size(_buffer) div _vertex_size)
{
    buffer_poke(_buffer, _tell    , buffer_f32, lerp(_uv_l, _uv_r, buffer_peek(_buffer, _tell    , buffer_f32)));
    buffer_poke(_buffer, _tell + 4, buffer_f32, lerp(_uv_t, _uv_b, buffer_peek(_buffer, _tell + 4, buffer_f32)));
    _tell += _vertex_size;
}

var _vbuffer = vertex_create_buffer_from_buffer(_buffer, _vformat);
buffer_delete(_buffer);
return _vbuffer;