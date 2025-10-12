/// @param buffer
/// @param modelDirectory
/// @param budget

function __DotobjClassModelWorker(_buffer, _modelDirectory, _budget) constructor
{
    static _system = __DotobjSystem();
    static _vertexFormatPNCT    = _system.__vertexFormatPNCT;
    static _vertexFormatPNCTTan = _system.__vertexFormatPNCTTan;
    static _materialLibraryMap  = _system.__materialLibraryMap;
    
    __createTime = get_timer();
    
    __buffer         = _buffer;
    __modelDirectory = _modelDirectory;
    __budget         = _budget;
    
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
    
    time_source_start(__timeSource);
    
    
    
    static GetFinished = function()
    {
        return __finished;
    }
    
    static Cancel = function()
    {
        __DotobjError("Not yet implemented!");
        
        __End();
    }
    
    static __Force = function()
    {
        while(not __finished)
        {
            __Update();
        }
        
        return self;
    }
    
    static __End = function()
    {
        if (__finished) return;
        
        __finished = true;
        
        //Doesn't matter if we're fully loaded or not!
        __modelStruct.loaded = true;
        
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
        
        if (__mrgbBuffer != undefined)
        {
            buffer_delete(__mrgbBuffer);
            __mrgbBuffer = undefined;
        }
        
        ds_list_destroy(__lineDataList);
        ds_list_destroy(__positionList);
        ds_list_destroy(__colourList);
        ds_list_destroy(__normalList);
        ds_list_destroy(__textureList);
    }
    
    //Cache values taken from the global system. Developers may decide to change settings for
    //different models and we don't want to get caught out
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
        other.__meshVertexesArray = vertexes_array;
    }
    
    __bufferSize = buffer_get_size(__buffer);
    __mrgbBuffer = undefined;
    
    __lineStarted       = false;
    __lineDataList      = ds_list_create();
    __valueReadStart    = 0;
    __uniqueMaterials   = {};
    __writeNullTangents = true;
    
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
    __positionList  = ds_list_create(); ds_list_add(__positionList, 0,0,0  );
    __colourList    = ds_list_create(); ds_list_add(__colourList,   1,1,1,1);
    __normalList    = ds_list_create(); ds_list_add(__normalList,   0,0,0  );
    __textureList   = ds_list_create(); ds_list_add(__textureList,  0,0    );
    __tangentList   = ds_list_create();
    __bitangentList = ds_list_create();
    __unpackedMeshVertexList = ds_list_create();
    
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
        
        __Update = __WorkParseBuffer;
    }
    
    static __WorkParseBuffer = function()
    {
        var _modelMaterialsArray = __modelStruct.materials_array;
        
        var _buffer = __buffer;
        
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
                                        show_debug_message("__DotobjClassModelWorker(): Warning! 4-element vertex position data is for mathematical curves/surfaces. This is not supported. (ln=" + string(_metaLine) + ")");
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
                                                show_debug_message("__DotobjClassModelWorker(): Warning! Texture depth is not supported; W-component of the texture coordinate will be ignored. (ln=" + string(_metaLine) + ")");
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
                                if (DOTOBJ_OUTPUT_WARNINGS && (not DOTOBJ_IGNORE_LINES)) show_debug_message("__DotobjClassModelWorker(): Warning! Line primitives are not currently supported. (ln=" + string(_metaLine) + ")");
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
                                        _meshVertexesArray = vertexes_array;
                                    }
                                }
                                else if (DOTOBJ_OUTPUT_WARNINGS)
                                {
                                    show_debug_message("__DotobjClassModelWorker(): Warning! Object \"" + string(_string) + "\" found. Objects are not supported; use groups instead, or set DOTOBJ_OBJECTS_ARE_GROUPS to <true>. (ln=" + string(_metaLine) + ")");
                                }
                            break;
                    
                            case "s": //Section definition
                                if (DOTOBJ_OUTPUT_WARNINGS && (not __smoothingGroupError))
                                {
                                    show_debug_message("__DotobjClassModelWorker(): Warning! Smoothing groups are not currently supported. (ln=" + string(_metaLine) + ")");
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
                            
                                    show_debug_message("__DotobjClassModelWorker(): \"" + _string + "\"");
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
                            
                                if (DOTOBJ_OUTPUT_DEBUG) show_debug_message("__DotobjClassModelWorker(): Requires \"" + __materialLibrary + "\"");
                            
                                //Try to remap before storing the material library name
                                __materialLibrary = DotobjAliasPathSubstringsApply(__materialLibrary, true);
                            
                                __modelStruct.material_library = __materialLibrary;
                                DotobjMtlLoadFromFile(__materialLibrary); //TODO - Make this async
                                
                                if (DOTOBJ_OUTPUT_DEBUG) show_debug_message("__DotobjClassModelWorker(): Set material library to \"" + __materialLibrary + "\"");
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
                            
                                if ((__meshStruct.material == DOTOBJ_DEFAULT_MATERIAL_NAME) && (array_length(_meshVertexesArray) <= 0))
                                {
                                    //If our mesh's material hasn't been set and the vertex list is empty, set this mesh to use this material
                                    __meshStruct.material = _materialName;
                                }
                                else
                                {
                                    //If our mesh's material has been set or we've added some vertices, create a new mesh to add triangles to
                                    __meshStruct = (new DotobjClassMesh()).AddTo(__groupStruct);
                                    with(__meshStruct)
                                    {
                                        material     = _materialName;
                                        has_tangents = _writeTangents;
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
                                    show_debug_message("__DotobjClassModelWorker(): Warning! External texture map files are not currently supported. (ln=" + string(_metaLine) + ")");
                                    __mapError = true;
                                }
                            break;
                    
                            case "shadow_obj":
                            case "trace_obj":
                                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("__DotobjClassModelWorker(): Warning! \"" + string(_lineDataList[| 0]) + "\" is an external .obj reference. This is not supported. (ln=" + string(_metaLine) + ")");
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
                                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("__DotobjClassModelWorker(): Warning! \"" + string(_lineDataList[| 0]) + "\" is for mathematical curves/surfaces. This is not supported. (ln=" + string(_metaLine) + ")");
                            break;
                    
                            case "lod":
                                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("__DotobjClassModelWorker(): Warning! In-file LODs are not currently supported. (ln=" + string(_metaLine) + ")");
                            break;
                    
                            case "bevel":
                            case "c_interp":
                            case "d_interp":
                                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("__DotobjClassModelWorker(): Warning! \"" + string(_lineDataList[| 0]) + "\" is a rendering attribute. This is not supported. (ln=" + string(_metaLine) + ")");
                            break;
                    
                            default: //Something else that we don't recognise!
                                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("__DotobjClassModelWorker(): Warning! \"" + string(_lineDataList[| 0]) + "\" is not recognised. (ln=" + string(_metaLine) + ")");
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
            
            __Update = (__mrgbBuffer != undefined)? __WorkMRGB : __WorkStartGroups;
        }
    }
    
    static __WorkMRGB = function()
    {
        var _mrgbBuffer = __mrgbBuffer;
        var _colourList = __colourList;
        
        if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("__DotobjClassModelWorker(): Warning! #MRGB implementation does not support mask bytes");
        var _mrgbLength = buffer_tell(_mrgbBuffer)/8;
        
        if (_mrgbLength != floor(_mrgbLength))
        {
            show_debug_message("__DotobjClassModelWorker(): Warning! #MRGB length is not a multiple of 8, vertex colours may be malformed");
        }
        
        buffer_write(_mrgbBuffer, buffer_u8, 0x00);
        buffer_seek(_mrgbBuffer, buffer_seek_start, 8);
        
        var _tell = 0;
        var _i = 4; //Colour list is 1-indexed
        repeat(_mrgbLength)
        {
            var _oldValue = buffer_peek(_mrgbBuffer, _tell + 8, buffer_u8);
            buffer_poke(_mrgbBuffer, _tell + 8, buffer_u8, 0x00);
            var _hexString = buffer_peek(_mrgbBuffer, _tell, buffer_string);
            buffer_poke(_mrgbBuffer, _tell + 8, buffer_u8, _oldValue);
            
            var _value = real("0x" + _hexString);
            _colourList[| _i  ] = ((_value >> 16) & 0xFF) / 255;
            _colourList[| _i+1] = ((_value >>  8) & 0xFF) / 255;
            _colourList[| _i+2] = ( _value        & 0xFF) / 255;
            _colourList[| _i+3] = 1;
            
            _tell += 8;
            _i += 4;
        }
        
        __Update = __WorkStartGroups;
    }
    
    static __WorkStartGroups = function()
    {
        //If we're writing tangents, initialise those lists
        if (__writeTangents)
        {
            //Each list should be the same size as the position list - we have one tangent vector and one bitangent vector for every position
            //(Tangents/Bitangents are stored as vec3, like positions, so this all lines up nicely)
            __tangentList[|   ds_list_size(__positionList)-1] = 0;
            __bitangentList[| ds_list_size(__positionList)-1] = 0;
        }
        
        __meshGroupArray = __modelStruct.groups_array;
        __groupIndex = 0;
        
        __Update = __WorkInitializeGroup;
    }
    
    static __WorkInitializeGroup = function()
    {
        //Iterate over all the groups we've found
        //If we're not returning arrays, the group map should only contain one group
        __groupStruct = __meshGroupArray[__groupIndex];
        
        //Find our list of faces for this group
        __groupLine        = __groupStruct.line;
        __groupName        = __groupStruct.name;
        __groupMeshesArray = __groupStruct.meshes_array;
        
        __meshIndex = 0;
        
        __Update = __WorkInitializeMesh;
    }
    
    static __WorkInitializeMesh = function()
    {
        __meshStruct        = __groupMeshesArray[__meshIndex];
        __meshVertexesArray = __meshStruct.vertexes_array;
        __meshMaterial      = __meshStruct.material;
        
        if (DOTOBJ_OUTPUT_DEBUG) show_debug_message("__DotobjClassModelWorker(): Group \"" + __groupName + "\" (ln=" + string(__groupLine) + ") mesh " + string(__meshIndex) + " uses material \"" + __meshMaterial + "\" and has " + string(array_length(__meshVertexesArray)) + " vertexes (" + string(array_length(__meshVertexesArray)/3) + " triangles)");
        
        //Check if this mesh is empty
        if (array_length(__meshVertexesArray) <= 0)
        {
            if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("__DotobjClassModelWorker(): Warning! Group \"" + string(__groupName) + "\" mesh " + string(__meshIndex) + " has no triangles");
            __Update = __WorkFinishMesh;
            return;
        }
        
        //Check if this mesh's material exists
        var _materialStruct = _materialLibraryMap[? __meshMaterial];
        if (_materialStruct == undefined)
        {
            if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("__DotobjClassModelWorker(): Warning! Material \"" + __meshMaterial + "\" doesn't exist for group \"" + __groupName + "\" (ln=" + string(__groupLine) + ") mesh " + string(__meshIndex) + ", using default material instead");
            _materialStruct = _materialLibraryMap[? DOTOBJ_DEFAULT_MATERIAL_NAME];
        }
        
        __Update = __writeTangents? __WorkInitializeWriteTangents : __WorkCreateVertexBuffer;
    }
    
    static __WorkInitializeWriteTangents = function()
    {
        var _materialStruct = _materialLibraryMap[? __meshMaterial];
        if ((_materialStruct.normal_map == undefined) && (not __forceCalculateTangents))
        {
            __writeNullTangents = true;
            __Update = __WorkCreateVertexBuffer;
        }
        else
        {
            __writeNullTangents = false;
            __Update = __WorkUnpackMeshVertices;
            
            __vertexIndex = 0;
        }
    }
    
    static __WorkUnpackMeshVertices = function()
    {
        var _unpackedMeshVertexList = __unpackedMeshVertexList;
        
        //Iterate over all the vertices
        var _vertexIndex = __vertexIndex;
        repeat(min(1000, array_length(__meshVertexesArray) - __vertexIndex))
        {
            //Get the vertex string, and find the first slash
            var _vertexString = __meshVertexesArray[_vertexIndex];
            _vertexIndex++;
            
            var _slashCount = string_count("/", _vertexString);
                        
            if (_slashCount == 0)
            {
                //If there are no slashes in the string, then it's a simple vertex position definition
                //We can't calculate a tangent without texture coordinates, bail
                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("__DotobjClassModelWorker(): Warning! Triangle " + string(_vertexIndex-1) + " for group \"" + string(__groupName) + "\" has no texture information, tangent cannot be computed");
                ds_list_add(_unpackedMeshVertexList, undefined, undefined);
                continue;
            }
            else if (_slashCount == 1)
            {
                //If there's one slash in the string, then it's a position + texture coordinate definition
                var _vIndex = string_copy(  _vertexString, 1, string_pos("/", _vertexString)-1);
                var _tIndex = string_delete(_vertexString, 1, string_pos("/", _vertexString)  );
            }
            else if (_slashCount == 2)
            {
                //If there're two slashes in the string, then it could be one of two things...
                            
                var _doubleSlashCount = string_count("//", _vertexString);
                if (_doubleSlashCount == 0)
                {
                    //If we find no double slashes then this is a position + UV + normal defintion
                    var _vIndex       = string_copy(  _vertexString, 1, string_pos( "/", _vertexString)-1);
                    var _vertexString = string_delete(_vertexString, 1, string_pos( "/", _vertexString)  );
                    var _tIndex       = string_copy(  _vertexString, 1, string_pos( "/", _vertexString)-1);
                }
                else if (_doubleSlashCount == 1)
                {
                    //If we find a single double slash then this is a position + normal defintion
                    //We can't calculate a tangent without texture coordinates, bail
                    if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("__DotobjClassModelWorker(): Warning! Triangle " + string(_vertexIndex-1) + " for group \"" + string(__groupName) + "\" has no texture information, tangent cannot be computed");
                    ds_list_add(_unpackedMeshVertexList, undefined, undefined);
                    continue;
                }
                else
                {
                    if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("__DotobjClassModelWorker(): Warning! Triangle " + string(_vertexIndex-1) + " for group \"" + string(__groupName) + "\" has an unsupported number of slashes (" + string(_slashCount) + ")");
                    ds_list_add(_unpackedMeshVertexList, undefined, undefined);
                    continue;
                }
            }
            else
            {
                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("__DotobjClassModelWorker(): Warning! Triangle " + string(_vertexIndex-1) + " for group \"" + string(__groupName) + "\" has an unsupported number of slashes (" + string(_slashCount) + ")");
                ds_list_add(_unpackedMeshVertexList, undefined, undefined);
                continue;
            }
                        
            //Store the position and texture index in our unpacked list
            ds_list_add(_unpackedMeshVertexList, 3*real(_vIndex), 2*real(_tIndex));
        }
        
        __vertexIndex = _vertexIndex;
        
        if (_vertexIndex >= array_length(__meshVertexesArray))
        {
            __vertexIndex = 0;
            __Update = __WorkWriteTangents;
        }
    }
    
    static __WorkWriteTangents = function()
    {
        var _positionList  = __positionList;
        var _textureList   = __textureList;
        var _tangentList   = __tangentList;
        var _bitangentList = __bitangentList;
        
        var _unpackedMeshVertexList = __unpackedMeshVertexList;
        
        //Iterate over all the vertices again, this time FOR REAL
        var _vertexIndex = __vertexIndex;
        
        repeat(min(1000, ds_list_size(_unpackedMeshVertexList) - _vertexIndex) div 6) //Triangles are defined as 3 points, and each point has a position and texture index
        {
            //Extract our position indexes
            var _pos_index_1 = _unpackedMeshVertexList[| _vertexIndex  ];
            var _pos_index_2 = _unpackedMeshVertexList[| _vertexIndex+2];
            var _pos_index_3 = _unpackedMeshVertexList[| _vertexIndex+4];
            
            //Extract our texture indexes
            var _tex_index_1 = _unpackedMeshVertexList[| _vertexIndex+1];
            var _tex_index_2 = _unpackedMeshVertexList[| _vertexIndex+3];
            var _tex_index_3 = _unpackedMeshVertexList[| _vertexIndex+5];
            
            //Fetch position/texture data for point 1
            var _in_x1 = _positionList[| _pos_index_1  ]; //X
            var _in_y1 = _positionList[| _pos_index_1+1]; //Y
            var _in_z1 = _positionList[| _pos_index_1+2]; //Z
            var _in_u1 = _textureList[|  _tex_index_1  ]; //U
            var _in_v1 = _textureList[|  _tex_index_1+1]; //V
            
            //Fetch position/texture data for point 2
            var _in_x2 = _positionList[| _pos_index_2  ]; //X
            var _in_y2 = _positionList[| _pos_index_2+1]; //Y
            var _in_z2 = _positionList[| _pos_index_2+2]; //Z
            var _in_u2 = _textureList[|  _tex_index_2  ]; //U
            var _in_v2 = _textureList[|  _tex_index_2+1]; //V
            
            //Fetch position/texture data for point 3
            var _in_x3 = _positionList[| _pos_index_3  ]; //X
            var _in_y3 = _positionList[| _pos_index_3+1]; //Y
            var _in_z3 = _positionList[| _pos_index_3+2]; //Z
            var _in_u3 = _textureList[|  _tex_index_3  ]; //U
            var _in_v3 = _textureList[|  _tex_index_3+1]; //V
            
            //Not sure if this is needed, but it's in here just in case
            //if (_flip_texcoords)
            //{
            //    _in_v1 = 1 - _in_v1;
            //    _in_v2 = 1 - _in_v2;
            //    _in_v3 = 1 - _in_v3;
            //}
            
            //Find the position/texture vectors from point 1 to point 2
            var _x1 = _in_x2 - _in_x1;
            var _y1 = _in_y2 - _in_y1;
            var _z1 = _in_z2 - _in_z1;
            var _u1 = _in_u2 - _in_u1;
            var _v1 = _in_v2 - _in_v1;
            
            //Find the position/texture vectors from point 1 to point 3
            var _x2 = _in_x3 - _in_x1;
            var _y2 = _in_y3 - _in_y1;
            var _z2 = _in_z3 - _in_z1;
            var _u2 = _in_u3 - _in_u1;
            var _v2 = _in_v3 - _in_v1;
            
            //Uuh... Not sure what this bit does...
            var _r = _u1*_v2 - _u2*_v1;
            if (_r != 0)
            {
                //Speeeeeeed
                _r = 1/_r;
                
                var _tx = (_v2*_x1 - _v1*_x2) * _r
                var _ty = (_v2*_y1 - _v1*_y2) * _r
                var _tz = (_v2*_z1 - _v1*_z2) * _r
                
                var _bx = (_u1*_x2 - _u2*_x1) * _r
                var _by = (_u1*_y2 - _u2*_y1) * _r
                var _bz = (_u1*_z2 - _u2*_z1) * _r
                
                //show_debug_message("t = " + string(_tx) + "," + string(_ty) + "," + string(_tz));
                //show_debug_message("b = " + string(_bx) + "," + string(_by) + "," + string(_bz));
                
                //Update the tangents I guess?
                _tangentList[|   _pos_index_1] += _tx;
                _tangentList[|   _pos_index_2] += _ty;
                _tangentList[|   _pos_index_3] += _tz;
                
                //And the bitangents too, why not  
                _bitangentList[| _pos_index_1] += _bx;
                _bitangentList[| _pos_index_2] += _by;
                _bitangentList[| _pos_index_3] += _bz;
            }
            //else
            //{
            //    //I don't think this warning is meaningful
            //    //We get (r==0) values when texture coordinates for a triangle are degenerate, and
            //    // in those situations we probably want to not adjust the position's tangent/bitangent
            //    if (DOTOBJ_OUTPUT_WARNINGS)
            //    {
            //        show_debug_message("__DotobjClassModelWorker(): WARNING! (r == 0), input values follow:");
            //        show_debug_message("                     " + string(_in_u1) + ", " + string(_in_v1));
            //        show_debug_message("                     " + string(_in_u2) + ", " + string(_in_v2));
            //        show_debug_message("                     " + string(_in_u3) + ", " + string(_in_v3));
            //        show_debug_message("                     -->");
            //        show_debug_message("                     " + string(_u1) + ", " + string(_v1));
            //        show_debug_message("                     " + string(_u2) + ", " + string(_v2));
            //        show_debug_message("                     -->");
            //        show_debug_message("                     " + string(_u1*_v2) + " - " + string(_u2*_v1));
            //    }
            //}
            
            //Next triangle!
            _vertexIndex += 6;
        }
        
        __vertexIndex = _vertexIndex;
        
        if (_vertexIndex >= ds_list_size(_unpackedMeshVertexList))
        {
            __Update = __WorkCreateVertexBuffer;
        }
    }
    
    static __WorkCreateVertexBuffer = function()
    {
        //Create a vertex buffer for this mesh
        ++__metaVertexBuffers;
        __vertexBuffer = vertex_create_buffer();
        vertex_begin(__vertexBuffer, __writeTangents? _vertexFormatPNCTTan : _vertexFormatPNCT);
        
        __trianglesRemaining = array_length(__meshVertexesArray);
        __triangleIndex = 0;
        
        __Update = __WorkAddTriangles;
    }
    
    static __WorkAddTriangles = function()
    {
        var _flipTexcoords = __flipTexcoords;
        var _writeTangents = __writeTangents;
        
        var _writeNullTangents = __writeNullTangents;
        
        var _positionList  = __positionList;
        var _colourList    = __colourList;
        var _normalList    = __normalList;
        var _textureList   = __textureList;
        var _tangentList   = __tangentList;
        var _bitangentList = __bitangentList;
        
        var _vertexBuffer      = __vertexBuffer;
        var _meshVertexesArray = __meshVertexesArray;
        
        var _triangleIndex = __triangleIndex;
        
        repeat(min(1000, __trianglesRemaining))
        {
            //Reset our lookup indexes
            var _vIndex = undefined;
            var _cIndex = undefined;
            var _tIndex = undefined;
            var _nIndex = undefined;
            
            //Reset our vertex data
            var _vx = undefined; //X
            var _vy = undefined; //Y
            var _vz = undefined; //Z
            var _cr = 1;         //Red
            var _cg = 1;         //Green
            var _cb = 1;         //Blue
            var _ca = 1;         //Alpha
            var _tx = 0;         //U
            var _ty = 0;         //V
            var _nx = 0;         //Normal X
            var _ny = 0;         //Normal Y
            var _nz = 0;         //Normal Z
            
            //N.B. This whole vertex decoding thing that uses strings can probably be done earlier by parsing data as it comes out of the buffer
            //     This can definitely be improved in terms of speed!
            
            //Get the vertex string, and count how many slashes it contains
            var _vertexString = _meshVertexesArray[_triangleIndex];
            _triangleIndex++;
                
            var _slashCount = string_count("/", _vertexString);
            if (_slashCount == 0)
            {
                //If there are no slashes in the string, then it's a simple vertex position definition
                _vIndex = _vertexString;
                _tIndex = undefined;
                _nIndex = undefined;
            }
            else if (_slashCount == 1)
            {
                //If there's one slash in the string, then it's a position + texture coordinate definition
                _vIndex = string_copy(  _vertexString, 1, string_pos("/", _vertexString)-1);
                _tIndex = string_delete(_vertexString, 1, string_pos("/", _vertexString)  );
                _nIndex = undefined;
            }
            else if (_slashCount == 2)
            {
                //If there're two slashes in the string, then it could be one of two things...
                
                var _doubleSlashCount = string_count("//", _vertexString);
                if (_doubleSlashCount == 0)
                {
                    //If we find no double slashes then this is a position + UV + normal defintion
                    _vIndex       = string_copy(  _vertexString, 1, string_pos( "/", _vertexString)-1);
                    _vertexString = string_delete(_vertexString, 1, string_pos( "/", _vertexString)  );
                    _tIndex       = string_copy(  _vertexString, 1, string_pos( "/", _vertexString)-1);
                    _nIndex       = string_delete(_vertexString, 1, string_pos( "/", _vertexString)  );
                }
                else if (_doubleSlashCount == 1)
                {
                    //If we find a single double slash then this is a position + normal defintion
                    _vertexString = string_replace(_vertexString, "//", "/" );
                    _vIndex       = string_copy(   _vertexString, 1, string_pos("/", _vertexString)-1);
                    _tIndex       = undefined;
                    _nIndex       = string_delete( _vertexString, 1, string_pos("/", _vertexString)  );
                }
                else
                {
                    if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("__DotobjClassModelWorker(): Warning! Triangle " + string(_triangleIndex) + " for group \"" + string(__groupName) + "\" has an unsupported number of slashes (" + string(_slashCount) + ")");
                    continue;
                }
            }
            else
            {
                if (DOTOBJ_OUTPUT_WARNINGS) show_debug_message("__DotobjClassModelWorker(): Warning! Triangle " + string(_triangleIndex) + " for group \"" + string(__groupName) + "\" has an unsupported number of slashes (" + string(_slashCount) + ")");
                continue;
            }
                
            if ((_vIndex == "") || (_vIndex == undefined))
            {
                ++__missingPositions;
                continue;
            }
                
            //If we've got any blank strings set the indices to 0
            if ((_nIndex == "") || (_nIndex == undefined)) _nIndex = 0;
            if ((_tIndex == "") || (_tIndex == undefined)) _tIndex = 0;
                
            //Some .obj file use negative references to look at data recently defined. This isn't supported!
            if ((_vIndex < 0) || (_nIndex < 0) || (_tIndex < 0))
            {
                ++__negativeReferences;
                continue;
            }
                
            _vIndex = 3*floor(real(_vIndex));
            _cIndex = (4/3)*_vIndex;
            _nIndex = 3*floor(real(_nIndex));
            _tIndex = 2*floor(real(_tIndex));
                
            //Write the position
            _vx = _positionList[| _vIndex  ]; //X
            _vy = _positionList[| _vIndex+1]; //Y
            _vz = _positionList[| _vIndex+2]; //Z
                
            //If we have some invalid data, log the warning, and move on to the next vertex
            //(Incidentally, if the position data is broken then the colour data will be broken too)
            if ((_vx == undefined) || (_vy == undefined) || (_vz == undefined))
            {
                ++__missingPositions;
                continue;
            }
                
            vertex_position_3d(_vertexBuffer, _vx, _vy, _vz);
                
            //Write the normal
            if (_nIndex >= 0)
            {
                _nx = _normalList[| _nIndex  ]; //Normal X
                _ny = _normalList[| _nIndex+1]; //Normal Y
                _nz = _normalList[| _nIndex+2]; //Normal Z
                    
                //If we have some invalid data, log the warning, then default to (0,0,0)
                if ((_nx == undefined) || (_ny == undefined) || (_nz == undefined))
                {
                    ++__missingNormals;
                    _nx = 0;
                    _ny = 0;
                    _nz = 0;
                }
            }
                
            vertex_normal(_vertexBuffer, _nx, _ny, _nz);
            
            //Write the colour
            _cr = _colourList[| _cIndex  ]*255; //Red
            _cg = _colourList[| _cIndex+1]*255; //Green
            _cb = _colourList[| _cIndex+2]*255; //Blue
            _ca = _colourList[| _cIndex+3];     //Alpha
            vertex_colour(_vertexBuffer, make_colour_rgb(_cr, _cg, _cb), _ca);
            
            //Write the UVs
            if (_tIndex >= 0) 
            {
                _tx = _textureList[| _tIndex  ]; //U
                _ty = _textureList[| _tIndex+1]; //V
                    
                //If we have some invalid data, log the warning, then default to (0,0)
                if ((_tx == undefined) || (_ty == undefined))
                {
                    ++__missingUVs;
                    _tx = 0;
                    _ty = 0;
                }
                else
                {
                    if (_flipTexcoords) _ty = 1 - _ty;
                }
            }
                
            vertex_texcoord(_vertexBuffer, _tx, _ty);
                
            //Write the tangent, including handedness
            if (_writeTangents)
            {
                if (_writeNullTangents)
                {
                    vertex_float4(_vertexBuffer, 0, 0, 0, 0);
                }
                else
                {
                    //Fetch our tangent/bitangent values for this position
                    var _tx = _tangentList[| _vIndex  ];
                    var _ty = _tangentList[| _vIndex+1];
                    var _tz = _tangentList[| _vIndex+2];
                        
                    var _bx = _bitangentList[| _vIndex  ];
                    var _by = _bitangentList[| _vIndex+1];
                    var _bz = _bitangentList[| _vIndex+2];
                        
                    //show_debug_message("in normal     = " + string(_nx) + "," + string(_ny) + "," + string(_nz));
                    //show_debug_message("in tangent    = " + string(_tx) + "," + string(_ty) + "," + string(_tz));
                    //show_debug_message("in bitangent  = " + string(_bx) + "," + string(_by) + "," + string(_bz));
                        
                    //"Gram-Schmidt orthogonalize"... apparently
                    //        dot = normal.tangent
                    //    tangent = tangent - normal*dot
                    //    tangent = normalize(tangent)
                    var _dot = dot_product_3d(_nx, _ny, _nz,   _tx, _ty, _tz);
                    _tx -= _nx * _dot;
                    _ty -= _ny * _dot;
                    _tz -= _nz * _dot;
                        
                    var _length = sqrt(_tx*_tx + _ty*_ty + _tz*_tz);
                    if (_length > 0)
                    {
                        _tx /= _length;
                        _ty /= _length;
                        _tz /= _length;
                    }
                
                    //Figure out the handedness of the bitangent
                    //    cross = n x tan1
                    //      dot = cross . tan2
                    //     hand = (dot < 0)? -1 : 1
                    var _crossX = _ny*_tz - _nz*_ty;
                    var _crossY = _nz*_tx - _nx*_tz;
                    var _crossZ = _nx*_ty - _ny*_tx;
                    var _dot = dot_product_3d(_crossX, _crossY, _crossZ, _bx, _by, _bz)
                    var _handedness = (_dot < 0)? -1 : 1;
                        
                    //Actually write the data!
                    vertex_float4(_vertexBuffer, _tx, _ty, _tz, _handedness);
                        
                    //show_debug_message("out tangent = " + string(_tx) + "," + string(_ty) + "," + string(_tz) + ", handedness = " + string(_handedness));
                }
            }
        }
        
        __triangleIndex = _triangleIndex;
        
        __trianglesRemaining -= 1000;
        if (__trianglesRemaining <= 0)
        {
            vertex_end(__vertexBuffer);
            __meshStruct.vertex_buffer = __vertexBuffer;
            
            __Update = __WorkFinishMesh;
        }
    }
    
    static __WorkFinishMesh = function()
    {
        ++__meshIndex;
        if (__meshIndex < array_length(__groupMeshesArray))
        {
            __Update = __WorkInitializeMesh;
        }
        else
        {
            ++__groupIndex;
            if (__groupIndex < array_length(__meshGroupArray))
            {
                __Update = __WorkInitializeGroup;
            }
            else
            {
                __Update = __WorkCleanUp;
            }
        }
    }
    
    static __WorkCleanUp = function()
    {
        __End();
        
        //Report errors if we found any
        if (DOTOBJ_OUTPUT_WARNINGS)
        {
            if (__negativeReferences > 0) show_debug_message("__DotobjClassModelWorker(): Warning! .obj had negative position references (x" + string(__negativeReferences) + ")");
            if (__missingPositions   > 0) show_debug_message("__DotobjClassModelWorker(): Warning! .obj referenced missing positions (x"     + string(__missingPositions  ) + ")");
            if (__missingNormals     > 0) show_debug_message("__DotobjClassModelWorker(): Warning! .obj referenced missing normals (x"       + string(__missingNormals    ) + ")");
            if (__missingUVs         > 0) show_debug_message("__DotobjClassModelWorker(): Warning! .obj referenced missing UVs (x"           + string(__missingUVs        ) + ")");
        }
        
        //If we want to report the load time, do it!
        if (DOTOBJ_OUTPUT_LOAD_TIME) show_debug_message("__DotobjClassModelWorker(): lines=" + string(__metaLine) + ", groups=" + string(array_length(__meshGroupArray)) + ", vertex buffers=" + string(__metaVertexBuffers) + ", triangles=" + string(__metaTriangles) + ". Time to load was " + string((get_timer() - __createTime)/1000) + "ms");
        
    }
}