/// Sets the colour and alpha of every vertex in a model
/// 
/// @param vertexBuffer
/// @param vertexFormat
/// @param newColour
/// @param newAlpha
/// @param vertexFormatSize{bytes}
/// @param vertexFormatOffset{bytes}
/// @param destroyOldVertexBuffer

var _vbuffer     = argument0;
var _vformat     = argument1;
var _colour      = argument2;
var _alpha       = argument3;
var _vertex_size = argument4;
var _offset      = argument5;
var _destroy_old = argument6;

var _rgba = (clamp(_alpha*255, 0, 255) << 24) | _colour;

var _buffer = buffer_create_from_vertex_buffer(_vbuffer, buffer_fixed, 1);
if (_destroy_old) vertex_delete_buffer(_vbuffer);

var _tell = _offset;
repeat(buffer_get_size(_buffer) div _vertex_size)
{
    buffer_poke(_buffer, _tell, buffer_u32, _rgba);
    _tell += _vertex_size;
}

var _vbuffer = vertex_create_buffer_from_buffer(_buffer, _vformat);
buffer_delete(_buffer);
return _vbuffer;