// Feather disable all

/// Applies path substring remapping to a path. You may set up remapping rules using the companion
/// function `DotobjAliasPathSubstring()`.
/// 
/// @param path
/// @param [reportRemapping=false]

function DotobjAliasPathSubstringsApply(_path, _reportRemapping = false)
{
    static _aliasPathSubstringMap   = __DotobjSystem().__aliasPathSubstringMap;
    static _aliasPathSubstringArray = __DotobjSystem().__aliasPathSubstringArray;
    
    if (DOTOBJ_OUTPUT_DEBUG && _reportRemapping)
    {
        var _inPath = _path;
    }
    
    var _i = 0;
    repeat(array_length(_aliasPathSubstringArray))
    {
        var _substring = _aliasPathSubstringArray[_i];
        _path = string_replace_all(_path, _substring, _aliasPathSubstringMap[? _substring]);
        ++_i;
    }
    
    if (DOTOBJ_OUTPUT_DEBUG && _reportRemapping && (_inPath != _path))
    {
        show_debug_message("DotobjAliasPathSubstringsApply(): Remapped \"" + string(_inPath) + "\" to \"" + string(_path) + "\"");
    }
    
    return _path;
}