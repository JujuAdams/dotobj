// Feather disable all

/// Turns an ASCII .obj file, stored in a buffer, into a series of vertex buffers stored in a tree-
/// like heirarchy. This function returns a dotobj model struct which is constructed from
/// `DotobjClassModel()`.
/// 
/// This function takes two arguments, the first being a buffer that contains the .obj file data.
/// The second argument `modelDirectory` should point to the directory that .mtl files can be found
/// in. This is important for implicit loading of materials. If you choose not to specify a model
/// directory then the Included Files directory will be used (typically the root directory that the
/// application is stored in).
/// 
/// The returned model can be drawn using the `Submit()` method e.g.
/// 
///     sponzaModel.Submit();
/// 
/// N.B.  You must call `.Destroy()` on the model struct when you no longer need to to free up
///       memory.
/// 
/// Model structs have many other methods. Please refer to `DotobjClassModel()` for further
/// information.
/// 
/// Models are created using a vertex format with the following definition:
/// - 3D Position
/// - Normal
/// - Colour
/// - Texture Coordinate
/// If a model has missing data, then a suitable default value will be used instead. The .obj
/// format (http://paulbourke.net/dataformats/obj/) doesn't allow for vertex colours so typically
/// the vertex colour will be white. However, if you use a custom exporter that supports vertex
/// colours (such as MeshLab or MeshMixer) then vertex colours will be respected in the model's
/// vertex buffers.
/// 
/// You may alter how dotobj loads models by calling the "Settings" functions e.g.
/// `DotobjSetFlipTexcoordV()`. Please review these functions, found in the "Settings" folder in
/// the asset browser.
/// 
/// Texture coordinates for .obj models will typically be normalised (0 -> 1). If you would like to
/// remap texture coordinates to atlased texture you will need to do so yourself.
/// 
/// This .obj loader does *not* support the following features:
/// - Smoothing groups
/// - Map libraries
/// - Freeform curve/surface geometry (NURBs/Bezier curves etc.)
/// - Line primitives
/// - Separate in-file LOD
/// 
/// @param buffer
/// @param [modelDirectory]
/// @param [consumeBuffer=false]

function DotobjModelLoad(_buffer, _modelDirectory = "", _consumeBuffer = false)
{
    return __DotobjStartWorker(_buffer, _modelDirectory, _consumeBuffer, infinity).__Force().__modelStruct;
}