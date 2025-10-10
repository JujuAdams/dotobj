/// @param buffer
/// @param modelDirectory

function __DotobjClassModelWorker(_buffer, _modelDirectory = "")
{
    static _system = __DotobjSystem();
    static _vertexFormatPNCT    = _system.__vertexFormatPNCT;
    static _vertexFormatPNCTTan = _system.__vertexFormatPNCTTan;
    static _materialLibraryMap  = _system.__materialLibraryMap;
    
    __buffer = _buffer;
    __modelDirectory = _modelDirectory;
    
    
    __finished = false;
    __Update = __WorkBufferInitialize;
    
    __timeSource = time_source_create(time_source_global, 1, time_source_units_frames, function()
    {
        var _startTime = current_time;
        while(((current_time - _startTime) < __budget) && (not __finished))
        {
            __Update();
        }
    },
    [], -1);
    
    static GetModel = function()
    {
        return __modelStruct;
    }
    
    static GetFinished = function()
    {
        return __finished;
    }
    
    static Cancel = function()
    {
        __DotobjError("Not yet implemented!");
        
        __End();
    }
    
    static __End = function()
    {
        if (__finished) return;
        
        __finished = true;
        
        if (__timeSource == undefined)
        {
            time_source_stop(__timeSource);
            time_source_destroy(__timeSource);
            __timeSource = undefined;
        }
        
        if (__buffer != undefined)
        {
            buffer_delete(__buffer);
            __buffer = undefined;
        }
        
        if (_mrgbBuffer != undefined)
        {
            buffer_delete(__buffer);
            _mrgbBuffer = undefined;
        }
        
        ds_list_destroy(__lineDataList);
        ds_list_destroy(__positionList);
        ds_list_destroy(__colourList);
        ds_list_destroy(__normalList);
        ds_list_destroy(__textureList);
    }
    
    //Cache values taken from the global system. Developers may decide to change settings for
    //different models and we don't want to get caught out
    __wireframe              = _system.__wireframe; __meshPrimitive = __wireframe? pr_linelist : pr_trianglelist;
    __flipTexcoords          = _system.__flipTexcoordV;
    __reverseTriangles       = _system.__reverseTriangles;
    __writeTangents          = _system.__writeTangents;
    __forceCalculateTangents = _system.__forceTangentCalc;
    __transformOnLoad        = _system.__transformOnLoad;
    
    //Create a model struct to put our unpoacked data into
    //We add a default group and default mesh to the model for use later during parsing
    __modelStruct = new DotobjClassModel();
    __modelStruct.material_library = DOTOBJ_DEFAULT_MATERIAL_LIBRARY;
    
    __groupStruct = __DotobjEnsureGroup(__modelStruct, DOTOBJ_DEFAULT_GROUP, 0);
    __meshStruct  = (new DotobjClassMesh()).AddTo(__groupStruct);
    
    with(__meshStruct)
    {
        material     = DOTOBJ_DEFAULT_MATERIAL_NAME;
        has_tangents = other.__writeTangents;
        primitive    = other.__meshPrimitive;
        other.__meshVertexesArray = vertexes_array;
    }
    
    __bufferSize = buffer_get_size(__buffer);
    __mrgbBuffer = undefined;
    
    __lineStarted       = false;
    __lineDataList      = ds_list_create();
    __valueReadStart    = 0;
    __uniqueMaterials   = {};
    
    __materialLibrary = DOTOBJ_DEFAULT_MATERIAL_LIBRARY;
    
    //Initialize error-tracking variables
    __vec4Error           = false;
    __textureDepthError   = false;
    __smoothingGroupError = false;
    __mapError            = false;
    
    __missingPositions   = 0;
    __missingNormals     = 0;
    __missingUVs         = 0;
    __negativeReferences = 0;
    
    __metaLine          = 1;
    __metaTriangles     = 0;
    __metaVertexBuffers = 0;
    
    //Create some lists to store the .obj file's data
    //We fill in the 0th element because .obj vertices are 1-indexed (!)
    __positionList = ds_list_create(); ds_list_add(__positionList, 0,0,0  );
    __colourList   = ds_list_create(); ds_list_add(__colourList,   1,1,1,1);
    __normalList   = ds_list_create(); ds_list_add(__normalList,   0,0,0  );
    __textureList  = ds_list_create(); ds_list_add(__textureList,  0,0    );
    
    __aabbX1 =  infinity;
    __aabbY1 =  infinity;
    __aabbZ1 =  infinity;
    __aabbX2 = -infinity;
    __aabbY2 = -infinity;
    __aabbZ2 = -infinity;
    
    
    
    
    
    
    static __WorkBufferInitialize = function()
    {
        __modelStruct.sha1 = buffer_sha1(__buffer, 0, __bufferSize);
        buffer_seek(__buffer, buffer_seek_start, 0);
        
        __bytesRemaining = __bufferSize;
    }
    
    static __WorkParseBuffer = function()
    {
        var _modelMaterialsArray = __modelStruct.materials_array;
        
        var _buffer        = __buffer;
        var _meshPrimitive = __meshPrimitive;
        
        var _reverseTriangles = __reverseTriangles;
        var _writeTangents    = __writeTangents;
        var _transformOnLoad  = __transformOnLoad;
        
        var _lineDataList = __lineDataList;
        var _positionList = __positionList;
        var _colourList   = __colourList;
        var _normalList   = __normalList;
        var _textureList  = __textureList;
        
        //Carry over values from previous iterations
        var _lineStarted       = __lineStarted;
        var _valueReadStart    = __valueReadStart;
        var _meshVertexesArray = __meshVertexesArray;
        
        var _aabbX1 = __aabbX1;
        var _aabbY1 = __aabbY1;
        var _aabbZ1 = __aabbZ1;
        var _aabbX2 = __aabbX2;
        var _aabbY2 = __aabbY2;
        var _aabbZ2 = __aabbZ2;
        
        var _metaLine      = __metaLine;
        var _metaTriangles = __metaTriangles;
        
        //Do some work!
        repeat(min(1000, __bytesRemaining))
        {
            //Grab a value
            var _value = buffer_read(_buffer, buffer_u8);
    
            if (not _lineStarted)
            {
                //If we haven't found a valid starting character yet (i.e. a character that has ASCII code > 32)...
                if (_value > 32)
                {
                    //If we find a valid starting character, update the line-start position and start reading the line!
                    _valueReadStart = buffer_tell(_buffer)-1;
                    _lineStarted = true;
                }
            }
            else
            {
                if ((_value == 0) || (_value == 10) || (_value == 13) || (_value == 32))
                {
                    //Put in a null character at the breaking character so we can easily read the value
                    buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0);
            
                    //Jump back to the where the value started, then read it in as a string
                    buffer_seek(_buffer, buffer_seek_start, _valueReadStart);
                    var _string = buffer_read(_buffer, buffer_string);
                    if (_string != "") ds_list_add(_lineDataList, _string);
            
                    //And reset our value read position for the next value
                    _valueReadStart = buffer_tell(_buffer);
            
                    if (_value != 32) //Implicitly  ((_value == 0) || (_value == 10) || (_value == 13))
                    {
                        //If we've reached the end of a line or the end of the buffer, process the line
                
                        switch(_lineDataList[| 0]) //Use the first piece of data we read to determine what kind of line this is
                        {
                            case "v": //Position
                                if (ds_list_size(_lineDataList) == 1+4)
                                {
                                    if (DOTOBJ_OUTPUT_WARNINGS && (not __vec4Error))
                                    {
                                        show_debug_message("DotobjModelLoad(): Warning! 4-element vertex position data is for mathematical curves/surfaces. This is not supported. (ln=" + string(_metaLine) + ")");
                                        __vec4Error = true;
                                    }
                                    break;
                                }
                            
                                var _vx = real(_lineDataList[| 1]);
                                var _vy = real(_lineDataList[| 2]);
                                var _vz = real(_lineDataList[| 3]);
                            
                                //Perform a transformation if needed
                                if (_transformOnLoad)
                                {
                                    var _old_vx = _vx; //Has to be snake_case to work with the macro
                                    var _old_vy = _vy;
                                    var _old_vz = _vz;
                                    DOTOBJ_POSITION_TRANSFORM;
                                }
                                
                                //Update the bounding box (I wish there was a better of doing this)
                                _aabbX1 = min(_aabbX1, _vx);
                                _aabbY1 = min(_aabbY1, _vy);
                                _aabbZ1 = min(_aabbZ1, _vz);
                                _aabbX2 = max(_aabbX2, _vx);
                                _aabbY2 = max(_aabbY2, _vy);
                                _aabbZ2 = max(_aabbZ2, _vz);
                            
                                //Add the position to our global list of positions
                                ds_list_add(_positionList, _vx, _vy, _vz);
                        
                                if (ds_list_size(_lineDataList) == 1+3+3)
                                {
                                    //Three extra pieces of data: this is an RGB value
                                    ds_list_add(_colourList, real(_lineDataList[| 4]), real(_lineDataList[| 5]), real(_lineDataList[| 6]), 1);
                                }
                                else if (ds_list_size(_lineDataList) == 1+3+4)
                                {
                                    //Four extra pieces of data: this is an RGBA value
                                    ds_list_add(_colourList, real(_lineDataList[| 4]), real(_lineDataList[| 5]), real(_lineDataList[| 6]), real(_lineDataList[| 7]));
                                }
                                else
                                {
                                    //If we have insufficient data for this line, presume this vertex is white with 100%
                                    ds_list_add(_colourList, 1, 1, 1, 1);
                                }
                            break;
                    
                            case "vt": //Texture coordinate
                                if (ds_list_size(_lineDataList) == 1+3)
                                {
                                    if (DOTOBJ_OUTPUT_WARNINGS && (not __textureDepthError))
                                    {
                                        switch(_lineDataList[| 3])
                                        {
                                            case "0":
                                            case "0.0":
                                            case "0.00":
                                            case "0.000":
                                            case "0.0000":
                                            case "0.00000":
                                                //Ignore texture depths of exactly 0
                                            break;
                                    
                                            default:
                                                show_debug_message("DotobjModelLoad(): Warning! Texture depth is not supported; W-component of the texture coordinate will be ignored. (ln=" + string(_metaLine) + ")");
                                                __textureDepthError = true;
                                            break;
                                        }
                                    }
                                }
                        
                                //Add our UVs to the global list of UVs
                                ds_list_add(_textureList, real(_lineDataList[| 1]), real(_lineDataList[| 2]));
                            break;
                    
                            case "vn": //Normal
                                //Add our normal to the global list of normals
                            
                                var _nx = real(_lineDataList[| 1]);
                                var _ny = real(_lineDataList[| 2]);
                                var _nz = real(_lineDataList[| 3]);
                            
                                //Perform a transformation if needed
                                if (_transformOnLoad)
                                {
                                    var _old_nx = _nx;
                                    var _old_ny = _ny;
                                    var _old_nz = _nz;
                                    DOTOBJ_NORMAL_TRANSFORM;
                                }
                            
                                ds_list_add(_normalList, _nx, _ny, _nz);
                            break;
                    
                            case "f": //Face definition
                                var _lineDataSize = ds_list_size(_lineDataList);
                                
                                _metaTriangles += _lineDataSize-3;
                                
                                //Add all triangles, vertex-by-vertex, defined by this face to the mesh's vertex list
                                var _f = 0;
                                repeat(_lineDataSize-3)
                                {
                                    if (_reverseTriangles) //TODO - Move if-branch outside the loop
                                    {
                                        array_push(_meshVertexesArray, _lineDataList[| 1], _lineDataList[| 3+_f], _lineDataList[| 2+_f]);
                                    }
                                    else
                                    {
                                        array_push(_meshVertexesArray, _lineDataList[| 1], _lineDataList[| 2+_f], _lineDataList[| 3+_f]);
                                    }
                            
                                    ++_f;
                                }
                            break;
                    
                            case "l": //Line definition
                                if (DOTOBJ_OUTPUT_WARNINGS && (not DOTOBJ_IGNORE_LINES)) show_debug_message("DotobjModelLoad(): Warning! Line primitives are not currently supported. (ln=" + string(_metaLine) + ")");
                            break;
                    
                            case "g": //Group definition
                                //Build the group name from all the line data
                                var _groupName = "";
                                var _i = 1;
                                var _size = ds_list_size(_lineDataList);
                                repeat(_size-1)
                                {
                                    _groupName += _lineDataList[| _i] + ((_i < _size-1)? " " : "");
                                    ++_i;
                                }
                        
                                //Create a new group and give it a blank mesh
                                __groupStruct = __DotobjEnsureGroup(__modelStruct, _groupName, _metaLine);
                                __meshStruct  = (new DotobjClassMesh()).AddTo(__groupStruct);
                            
                                with(__meshStruct)
                                {
                                    material     = DOTOBJ_DEFAULT_MATERIAL_NAME;
                                    has_tangents = _writeTangents;
                                    primitive    = _meshPrimitive;
                                    _meshVertexesArray = vertexes_array;
                                }
                            break;
                    
                            case "o": //Object definition
                                //Build the object name from all the line data
                                var _groupName = "";
                                var _i = 1;
                                var _size = ds_list_size(_lineDataList);
                                repeat(_size-1)
                                {
                                    _groupName += _lineDataList[| _i] + ((_i < _size-1)? " " : "");
                                    ++_i;
                                }
                        
                                if (DOTOBJ_OBJECTS_ARE_GROUPS)
                                {
                                    //If we want to parse objects as groups, create a new group and give it a blank mesh
                                    __groupStruct = __DotobjEnsureGroup(__modelStruct, _groupName, _metaLine);
                                    __meshStruct  = (new DotobjClassMesh()).AddTo(__groupStruct);
                                
                                    with(__meshStruct)
                                    {
                                        material     = DOTOBJ_DEFAULT_MATERIAL_NAME;
                                        has_tangents = _writeTangents;
                                        primitive    = _meshPrimitive;
                                        _meshVertexesArray = vertexes_array;
                                    }
                                }
                                else if (DOTOBJ_OUTPUT_WARNINGS)
                                {
                                    show_debug_message("DotobjModelLoad(): Warning! Object \"" + string(_string) + "\" found. Objects are not supported; use groups instead, or set DOTOBJ_OBJECTS_ARE_GROUPS to <true>. (ln=" + string(_metaLine) + ")");
                                }
                            break;
                    
                            case "s": //Section definition
                                if (DOTOBJ_OUTPUT_WARNINGS && (not __smoothingGroupError))
                                {
                                    show_debug_message("DotobjModelLoad(): Warning! Smoothing groups are not currently supported. (ln=" + string(_metaLine) + ")");
                                    __smoothingGroupError = true;
                                }
                            break;
                    
                            case "#": //Comments
                                if (DOTOBJ_OUTPUT_COMMENTS)
                                {
                                    var _string = "";
                                    var _i = 1;
                                    var _size = ds_list_size(_lineDataList);
                                    repeat(_size-1)
                                    {
                                        _string += _lineDataList[| _i] + ((_i < _size-1)? " " : "");
                                        ++_i;
                                    }
                            
                                    show_debug_message("DotobjModelLoad(): \"" + _string + "\"");
                                }
                            break;
                    
                            case "mtllib":
                                //Build the library name from all the line data
                                __materialLibrary = __modelDirectory;
                                var _i = 1;
                                var _size = ds_list_size(_lineDataList);
                                repeat(_size-1)
                                {
                                    __materialLibrary += _lineDataList[| _i] + ((_i < _size-1)? " " : "");
                                    ++_i;
                                }
                            
                                if (DOTOBJ_OUTPUT_DEBUG) show_debug_message("DotobjModelLoad(): Requires \"" + __materialLibrary + "\"");
                            
                                //Try to remap before storing the material library name
                                __materialLibrary = DotobjAliasPathSubstringsApply(__materialLibrary, true);
                            
                                __modelStruct.material_library = __materialLibrary;
                                DotobjMtlLoadFromFile(__materialLibrary); //TODO - Make this async
                                
                                if (DOTOBJ_OUTPUT_DEBUG) show_debug_message("DotobjModelLoad(): Set material library to \"" + __materialLibrary + "\"");
                            break;
                    
                            case "usemtl":
                                //Build the material name from all the line data
                                var _materialSpecific = "";
                                var _i = 1;
                                var _size = ds_list_size(_lineDataList);
                                repeat(_size-1)
                                {
                                    _materialSpecific += _lineDataList[| _i] + ((_i < _size-1)? " " : "");
                                    ++_i;
                                }
                        
                                //Then build a full material name from that
                                var _materialName = __materialLibrary + "." + _materialSpecific;
                            
                                //If this material is new to us, add it to our materials array
                                if (not variable_struct_exists(__uniqueMaterials, _materialName))
                                {
                                    __uniqueMaterials[$ _materialName] = variable_struct_names_count(__uniqueMaterials);
                                    array_push(_modelMaterialsArray, _materialName);
                                }
                            
                                if ((_meshStruct.material == DOTOBJ_DEFAULT_MATERIAL_NAME) && (array_length(_meshVertexesArray) <= 0))
                                {
                                    //If our mesh's material hasn't been set and the vertex list is empty, set this mesh to use this material
                                    _meshStruct.material = _materialName;
                                }
                                else
                                {
                                    //If our mesh's material has been set or we've added some vertices, create a new mesh to add triangles to
                                    var _meshStruct = (new DotobjClassMesh()).AddTo(__groupStruct);
                                    with(_meshStruct)
                                    {
                                        material     = _materialName;
                                        has_tangents = _writeTangents;
                                        primitive    = _meshPrimitive;
                                        var _meshVertexesArray = vertexes_array;
                                    }
                                }
                            break;
                        
                            case "#MRGB":
                            case "#mrgb":
                                if (__mrgbBuffer == undefined)
                                {
                                    __mrgbBuffer = buffer_create(1024, buffer_grow, 1);
                                }
                                
                                buffer_write(__mrgbBuffer, buffer_text, _lineDataList[| 1]);
                            break;
                    
                            case "maplib":
                            case "usemap":
                                if (DOTOBJ_OUTPUT_WARNINGS && (not __mapError))
                                {
                                    show_debug_message("DotobjModelLoad(): Warning! External texture map files are not currently supported. (ln=" + string(_metaLine) + ")");
                                    __mapError = true;
                                }
                            break;
                    
                            case "shadow_obj":
                            case "trace_obj":
                                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("DotobjModelLoad(): Warning! \"" + string(_lineDataList[| 0]) + "\" is an external .obj reference. This is not supported. (ln=" + string(_metaLine) + ")");
                            break;
                    
                            case "vp":
                            case "cstype":
                            case "deg":
                            case "bmat":
                            case "step":
                            case "curv":
                            case "curv2":
                            case "surf":
                            case "end":
                            case "parm":
                            case "trim":
                            case "hole":
                            case "scrv":
                            case "sp":
                            case "con":
                            case "mg":
                            case "ctech":
                            case "stech":
                            case "bsp":   //Depreciated
                            case "bzp":   //Depreciated
                            case "cdc":   //Depreciated
                            case "cdp":   //Depreciated
                            case "res":   //Depreciated
                                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("DotobjModelLoad(): Warning! \"" + string(_lineDataList[| 0]) + "\" is for mathematical curves/surfaces. This is not supported. (ln=" + string(_metaLine) + ")");
                            break;
                    
                            case "lod":
                                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("DotobjModelLoad(): Warning! In-file LODs are not currently supported. (ln=" + string(_metaLine) + ")");
                            break;
                    
                            case "bevel":
                            case "c_interp":
                            case "d_interp":
                                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("DotobjModelLoad(): Warning! \"" + string(_lineDataList[| 0]) + "\" is a rendering attribute. This is not supported. (ln=" + string(_metaLine) + ")");
                            break;
                    
                            default: //Something else that we don't recognise!
                                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("DotobjModelLoad(): Warning! \"" + string(_lineDataList[| 0]) + "\" is not recognised. (ln=" + string(_metaLine) + ")");
                            break;
                        }
                
                        //Once we're done with the line, clear the data out and start again
                        ds_list_clear(_lineDataList);
                        _lineStarted = false;
                    }
                }
            }
    
            //If we've hit a \n or \r character then increment our line counter
            if ((_value == 10) || (_value == 13)) _metaLine++;
        }
        
        //Carry values across to the next iteration
        __lineStarted       = _lineStarted;
        __valueReadStart    = _valueReadStart;
        __meshVertexesArray = _meshVertexesArray;
        
        __aabbX1 = _aabbX1;
        __aabbY1 = _aabbY1;
        __aabbZ1 = _aabbZ1;
        __aabbX2 = _aabbX2;
        __aabbY2 = _aabbY2;
        __aabbZ2 = _aabbZ2;
        
        __metaLine      = _metaLine;
        __metaTriangles = _metaTriangles;
        
        //Figure out if we're done with the buffer
        __bytesRemaining -= 1000;
        if (__bytesRemaining <= 0)
        {
            //Copy over our bounding box info to the model
            with(__modelStruct.aabb)
            {
                x1 = _aabbX1;
                y1 = _aabbY1;
                z1 = _aabbZ1;
                x2 = _aabbX2;
                y2 = _aabbY2;
                z2 = _aabbZ2;
            }
            
            __Update = __WorkMRGB;
        }
    }
    
    static __WorkMRGB = function()
    {
        
    }
    
    static __WorkInitializeGroup = function()
    {
        
    }
    
    static __WorkTangents = function()
    {
        
    }
    
    static __WorkInitializeMesh = function()
    {
        
    }
    
    static __WorkAddTriangles = function()
    {
        
    }
    
    static __WorkAddLines = function()
    {
        
    }
    
    static __WorkCleanUp = function()
    {
        
    }
}