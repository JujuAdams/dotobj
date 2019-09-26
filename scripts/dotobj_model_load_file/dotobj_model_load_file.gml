/// Loads an ASCII .obj file from disk and turns it into a vertex buffer
/// @jujuadams
/// 
/// .obj format documentation can be found here:
/// http://paulbourke.net/dataformats/obj/
/// 
/// This script expects the vertex format to be setup as follows:
/// - 3D Position
/// - Normal
/// - Colour
/// - Texture Coordinate
/// If your preferred vertex format does not have normals or texture coordinates,
/// use the "writeNormals" and/or "writeTexcoords" to toggle writing that data.
/// 
/// The .obj format does not natively support vertex colours; vertex colours will
/// default to white and 100% alpha. If you use a custom exporter that supports
/// vertex colours (such as MeshLab or MeshMixer) then vertex colours will be
/// respected in the final vertex buffer.
/// 
/// Texture coordinates for a .obj model will typically be normalised and in the
/// range (0,0) -> (1,1). Please use another script to remap texture coordinates
/// to GameMaker's atlased UV space.
/// 
/// .obj files sometimes contain multiple groups. For some specific applications,
/// it's useful to export each group as a separate vertex buffer. Set the optional
/// "useArray" argument to <true> to return an array of vertex buffers.
/// 
/// @param filename        File to read from
/// @param vertexFormat    Vertex format to use. See above for details on what vertex formats are supported
/// @param writeNormals    Whether to write normals into the vertex buffer. Set this to <false> if your vertex format does not contain normals
/// @param writeUVs        Whether to write texture coordinates into the vertex buffer. Set this to <false> if your vertex format does not contain texture coordinates
/// @param flipUVs         Whether to flip the y-axis (V-component) of the texture coordinates. This is useful to correct for DirectX / OpenGL idiosyncrasies
/// @param reverseTris     Whether to reverse the triangle definition order to be compatible with the culling mode of your choice (clockwise/counter-clockwise)
/// 
/// Returns: A vertex buffer, or an array of vertex buffers if "useBuffer" is <true>

var _filename          = argument[0];
var _vformat           = argument[1];
var _write_normals     = argument[2];
var _write_texcoords   = argument[3];
var _flip_texcoords    = argument[4];
var _reverse_triangles = argument[5];

var _buffer = buffer_load(_filename);
var _result = dotobj_model_load(_buffer, _vformat, _write_normals, _write_texcoords, _flip_texcoords, _reverse_triangles);
buffer_delete(_buffer);

return _result;