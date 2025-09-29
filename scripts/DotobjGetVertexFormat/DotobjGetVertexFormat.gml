// Feather disable all

/// Returns the vertex format currently being used to construct models.

function DotobjGetVertexFormat()
{
    static _system = __DotobjSystem();
    static _vertexFormatPNCT    = _system.__vertexFormatPNCT;
    static _vertexFormatPNCTTan = _system.__vertexFormatPNCTTan;
    
    return _system.__writeTangents? _vertexFormatPNCTTan : _vertexFormatPNCT;
}