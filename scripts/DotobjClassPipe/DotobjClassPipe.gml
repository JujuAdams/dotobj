enum __DOTOBJ_SHADER_SUPPORT
{
    FALLBACK      =   0,
    
    DIFFUSE_FLAT  =   1,
    DIFFUSE_MAP   =   2,
    
    //a.k.a. "mask"
    DISSOLVE_FLAT =   4,
    DISSOLVE_MAP  =   8,
    
    SPECULAR_FLAT =  16,
    SPECULAR_MAP  =  32,
    
    //a.k.a. "bump"
    NORMAL_MAP    =  64,
    
    EMISSIVE_FLAT = 128,
    EMISSIVE_MAP  = 256,
    
    __MAX = __DOTOBJ_SHADER_SUPPORT.EMISSIVE_MAP,
}

enum __DOTOBJ_SHADER_DATA
{
    SHADER,
    DIFFUSE_FLAT,
    DIFFUSE_MAP,
    DISSOLVE_FLAT,
    DISSOLVE_MAP,
    SPECULAR_FLAT,
    SPECULAR_MAP,
    NORMAL_MAP,
    EMISSIVE_FLAT,
    EMISSIVE_MAP,
    __SIZE
}

function DotobjClassPipe() constructor
{
    var _fallback_shader_data = array_create(__DOTOBJ_SHADER_DATA.__SIZE, -1);
    _fallback_shader_data[@ __DOTOBJ_SHADER_DATA.SHADER     ] = shdDotobjFullbright;
    _fallback_shader_data[@ __DOTOBJ_SHADER_DATA.DIFFUSE_MAP] = "gm_BaseTexture";
    
    shaders = array_create(2*__DOTOBJ_SHADER_SUPPORT.__MAX - 1, _fallback_shader_data);
    
    static AddShader = function()
    {
        var _definition       = argument0;
        var _skipVerification = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : false;
        
        if (!variable_struct_exists(_definition, "shader"))
        {
            __DotobjError("Shader definition doesn't include a \"shader\" member variable\n\n", _definition);
        }
        
        var _id = 0;
        var _shader = _definition.shader;
        
        var _shader_data = array_create(__DOTOBJ_SHADER_DATA.__SIZE, -1);
        _shader_data[@ __DOTOBJ_SHADER_DATA.SHADER] = _shader;
        
        //Diffuse
        if (variable_struct_exists(_definition, "diffuseFlat"))
        {
            var _uniform = shader_get_uniform(_shader, _definition.diffuseFlat);
            if (!_skipVerification && (_uniform < 0)) __DotobjError("Could not resolve \"diffuseFlat\" uniform for shader \"", shader_get_name(_shader), "\", was looking for \"", _definition.diffuseFlat, "\"");
            _shader_data[@ __DOTOBJ_SHADER_DATA.DIFFUSE_FLAT] = _uniform;
            
            _id |= __DOTOBJ_SHADER_SUPPORT.DIFFUSE_FLAT;
        }
        
        if (variable_struct_exists(_definition, "diffuseMap"))
        {
            if (_definition.diffuseMap == "gm_BaseTexture")
            {
                _shader_data[@ __DOTOBJ_SHADER_DATA.DIFFUSE_MAP] = "gm_BaseTexture";
            }
            else
            {
                var _uniform = shader_get_sampler_index(_shader, _definition.diffuseMap);
                if (!_skipVerification && (_uniform < 0)) __DotobjError("Could not resolve \"diffuseMap\" sampler for shader \"", shader_get_name(_shader), "\", was looking for \"", _definition.diffuseMap, "\"");
                _shader_data[@ __DOTOBJ_SHADER_DATA.DIFFUSE_MAP] = _uniform;
            }
            
            _id |= __DOTOBJ_SHADER_SUPPORT.DIFFUSE_MAP;
        }
        
        //Dissolve
        if (variable_struct_exists(_definition, "dissolveFlat"))
        {
            var _uniform = shader_get_uniform(_shader, _definition.dissolveFlat);
            if (!_skipVerification && (_uniform < 0)) __DotobjError("Could not resolve \"dissolveFlat\" uniform for shader \"", shader_get_name(_shader), "\", was looking for \"", _definition.dissolveFlat, "\"");
            _shader_data[@ __DOTOBJ_SHADER_DATA.DISSOLVE_FLAT] = _uniform;
            
            _id |= __DOTOBJ_SHADER_SUPPORT.DISSOLVE_FLAT;
        }
        
        if (variable_struct_exists(_definition, "dissolveMap"))
        {
            if (_definition.dissolveMap == "gm_BaseTexture")
            {
                _shader_data[@ __DOTOBJ_SHADER_DATA.DISSOLVE_MAP] = "gm_BaseTexture";
            }
            else
            {
                var _uniform = shader_get_sampler_index(_shader, _definition.dissolveMap);
                if (!_skipVerification && (_uniform < 0)) __DotobjError("Could not resolve \"dissolveMap\" sampler for shader \"", shader_get_name(_shader), "\", was looking for \"", _definition.dissolveMap, "\"");
                _shader_data[@ __DOTOBJ_SHADER_DATA.DISSOLVE_MAP] = _uniform;
            }
            
            _id |= __DOTOBJ_SHADER_SUPPORT.DISSOLVE_MAP;
        }
        
        //Specular
        if (variable_struct_exists(_definition, "specularFlat"))
        {
            var _uniform = shader_get_uniform(_shader, _definition.specularFlat);
            if (!_skipVerification && (_uniform < 0)) __DotobjError("Could not resolve \"specularFlat\" uniform for shader \"", shader_get_name(_shader), "\", was looking for \"", _definition.specularFlat, "\"");
            _shader_data[@ __DOTOBJ_SHADER_DATA.SPECULAR_FLAT] = _uniform;
            
            _id |= __DOTOBJ_SHADER_SUPPORT.SPECULAR_FLAT;
        }
        
        if (variable_struct_exists(_definition, "specularMap"))
        {
            if (_definition.specularMap == "gm_BaseTexture")
            {
                _shader_data[@ __DOTOBJ_SHADER_DATA.SPECULAR_MAP] = "gm_BaseTexture";
            }
            else
            {
                var _uniform = shader_get_sampler_index(_shader, _definition.specularMap);
                if (!_skipVerification && (_uniform < 0)) __DotobjError("Could not resolve \"specularMap\" sampler for shader \"", shader_get_name(_shader), "\", was looking for \"", _definition.specularMap, "\"");
                _shader_data[@ __DOTOBJ_SHADER_DATA.SPECULAR_MAP] = _uniform;
            }
            
            _id |= __DOTOBJ_SHADER_SUPPORT.SPECULAR_MAP;
        }
        
        //Normal
        if (variable_struct_exists(_definition, "normalMap"))
        {
            if (_definition.normalMap == "gm_BaseTexture")
            {
                _shader_data[@ __DOTOBJ_SHADER_DATA.NORMAL_MAP] = "gm_BaseTexture";
            }
            else
            {
                var _uniform = shader_get_sampler_index(_shader, _definition.normalMap);
                if (!_skipVerification && (_uniform < 0)) __DotobjError("Could not resolve \"normalMap\" sampler for shader \"", shader_get_name(_shader), "\", was looking for \"", _definition.normalMap, "\"");
                _shader_data[@ __DOTOBJ_SHADER_DATA.NORMAL_MAP] = _uniform;
            }
            
            _id |= __DOTOBJ_SHADER_SUPPORT.NORMAL_MAP;
        }
        
        //Emissive
        if (variable_struct_exists(_definition, "emissiveFlat"))
        {
            var _uniform = shader_get_uniform(_shader, _definition.emissiveFlat);
            if (!_skipVerification && (_uniform < 0)) __DotobjError("Could not resolve \"emissiveFlat\" uniform for shader \"", shader_get_name(_shader), "\", was looking for \"", _definition.emissiveFlat, "\"");
            _shader_data[@ __DOTOBJ_SHADER_DATA.EMISSIVE_FLAT] = _uniform;
            
            _id |= __DOTOBJ_SHADER_SUPPORT.EMISSIVE_FLAT;
        }
        
        if (variable_struct_exists(_definition, "emissiveMap"))
        {
            if (_definition.emissiveMap == "gm_BaseTexture")
            {
                _shader_data[@ __DOTOBJ_SHADER_DATA.EMISSIVE_MAP] = "gm_BaseTexture";
            }
            else
            {
                var _uniform = shader_get_sampler_index(_shader, _definition.emissiveMap);
                if (!_skipVerification && (_uniform < 0)) __DotobjError("Could not resolve \"emissiveMap\" sampler for shader \"", shader_get_name(_shader), "\", was looking for \"", _definition.emissiveMap, "\"");
                _shader_data[@ __DOTOBJ_SHADER_DATA.EMISSIVE_MAP] = _uniform;
            }
            
            _id |= __DOTOBJ_SHADER_SUPPORT.EMISSIVE_MAP;
        }
        
        //Check for conflicts
        if (((_id & __DOTOBJ_SHADER_SUPPORT.DIFFUSE_FLAT) > 0) && ((_id & __DOTOBJ_SHADER_SUPPORT.DIFFUSE_MAP) > 0))
        {
            __DotobjError("Cannot bind \"diffuseFlat\" and \"diffuseMap\" in the same shader definition.\nPlease make two separate calls to .AddShader() if your shader supports both rendering configurations.");
        }
        
        if (((_id & __DOTOBJ_SHADER_SUPPORT.DISSOLVE_FLAT) > 0) && ((_id & __DOTOBJ_SHADER_SUPPORT.DISSOLVE_MAP) > 0))
        {
            __DotobjError("Cannot bind \"dissolveFlat\" and \"dissolveMap\" in the same shader definition.\nPlease make two separate calls to .AddShader() if your shader supports both rendering configurations.");
        }
        
        if (((_id & __DOTOBJ_SHADER_SUPPORT.SPECULAR_FLAT) > 0) && ((_id & __DOTOBJ_SHADER_SUPPORT.SPECULAR_MAP) > 0))
        {
            __DotobjError("Cannot bind \"specularFlat\" and \"specularMap\" in the same shader definition.\nPlease make two separate calls to .AddShader() if your shader supports both rendering configurations.");
        }
        
        if (((_id & __DOTOBJ_SHADER_SUPPORT.EMISSIVE_FLAT) > 0) && ((_id & __DOTOBJ_SHADER_SUPPORT.EMISSIVE_MAP) > 0))
        {
            __DotobjError("Cannot bind \"emissiveFlat\" and \"emissiveMap\" in the same shader definition.\nPlease make two separate calls to .AddShader() if your shader supports both rendering configurations.");
        }
        
        shaders[@ _id] = _shader_data;
    }
}