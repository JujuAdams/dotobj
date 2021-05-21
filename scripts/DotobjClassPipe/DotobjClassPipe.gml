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
    
    __MAX = __DOTOBJ_SHADER_SUPPORT.NORMAL_MAP,
}

function DotobjClassPipe() constructor
{
    shaders = {};
    AddShader({ shader: shdDotobjFullbright }, true);
    
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
        
        //Diffuse
        if (variable_struct_exists(_definition, "diffuseFlat"))
        {
            var _uniform = shader_get_uniform(_shader, _definition.diffuseFlat);
            if (!_skipVerification && (_uniform < 0)) __DotobjError("Could not resolve \"diffuseFlat\" uniform for shader \"", shader_get_name(_shader), "\", was looking for \"", _definition.diffuseFlat, "\"");
            
            _definition.diffuseFlat = _uniform;
            _id |= __DOTOBJ_SHADER_SUPPORT.DIFFUSE_FLAT;
        }
        
        if (variable_struct_exists(_definition, "diffuseMap"))
        {
            if (_definition.diffuseMap != "gm_BaseTexture")
            { 
                var _uniform = shader_get_sampler_index(_shader, _definition.diffuseMap);
                if (!_skipVerification && (_uniform < 0)) __DotobjError("Could not resolve \"diffuseMap\" sampler for shader \"", shader_get_name(_shader), "\", was looking for \"", _definition.diffuseMap, "\"");
                _definition.diffuseMap = _uniform;
            }
            
            _id |= __DOTOBJ_SHADER_SUPPORT.DIFFUSE_MAP;
        }
        
        //Dissolve
        if (variable_struct_exists(_definition, "dissolveFlat"))
        {
            var _uniform = shader_get_uniform(_shader, _definition.dissolveFlat);
            if (!_skipVerification && (_uniform < 0)) __DotobjError("Could not resolve \"dissolveFlat\" uniform for shader \"", shader_get_name(_shader), "\", was looking for \"", _definition.dissolveFlat, "\"");
            
            _definition.dissolveFlat = _uniform;
            _id |= __DOTOBJ_SHADER_SUPPORT.DISSOLVE_FLAT;
        }
        
        if (variable_struct_exists(_definition, "dissolveMap"))
        {
            if (_definition.dissolveMap != "gm_BaseTexture")
            {
                var _uniform = shader_get_sampler_index(_shader, _definition.dissolveMap);
                if (!_skipVerification && (_uniform < 0)) __DotobjError("Could not resolve \"dissolveMap\" sampler for shader \"", shader_get_name(_shader), "\", was looking for \"", _definition.dissolveMap, "\"");
                _definition.dissolveMap = _uniform;
            }
            
            _id |= __DOTOBJ_SHADER_SUPPORT.DISSOLVE_MAP;
        }
        
        //Specular
        if (variable_struct_exists(_definition, "specularFlat"))
        {
            var _uniform = shader_get_uniform(_shader, _definition.specularFlat);
            if (!_skipVerification && (_uniform < 0)) __DotobjError("Could not resolve \"specularFlat\" uniform for shader \"", shader_get_name(_shader), "\", was looking for \"", _definition.specularFlat, "\"");
            
            _definition.specularFlat = _uniform;
            _id |= __DOTOBJ_SHADER_SUPPORT.SPECULAR_FLAT;
        }
        
        if (variable_struct_exists(_definition, "specularMap"))
        {
            if (_definition.specularMap != "gm_BaseTexture")
            {
                var _uniform = shader_get_sampler_index(_shader, _definition.specularMap);
                if (!_skipVerification && (_uniform < 0)) __DotobjError("Could not resolve \"specularMap\" sampler for shader \"", shader_get_name(_shader), "\", was looking for \"", _definition.specularMap, "\"");
                _definition.specularMap = _uniform;
            }
            
            _id |= __DOTOBJ_SHADER_SUPPORT.SPECULAR_MAP;
        }
        
        //Normal
        if (variable_struct_exists(_definition, "normalMap"))
        {
            if (_definition.normalMap != "gm_BaseTexture")
            {
                var _uniform = shader_get_sampler_index(_shader, _definition.normalMap);
                if (!_skipVerification && (_uniform < 0)) __DotobjError("Could not resolve \"normalMap\" sampler for shader \"", shader_get_name(_shader), "\", was looking for \"", _definition.normalMap, "\"");
                _definition.normalMap = _uniform;
            }
            
            _id |= __DOTOBJ_SHADER_SUPPORT.NORMAL_MAP;
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
        
        shaders[$ _id] = _definition;
    }
}