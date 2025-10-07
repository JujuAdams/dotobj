// Feather disable all

/// Sets up a partial path replacement rule within dotobj. This is helpful to fix absolute paths
/// that might have snuck into external files, such as paths to image files on disk that are found
/// in .mtl files.
/// 
/// This path replacement only applies to paths that are found within .obj and .mtl files that
/// implicitly load resources from disk. Partial path replacement will **not** apply to paths that
/// you manually input into functions. For example, neither `DotobjModelRawLoad()` nor
/// `DotobjModelLoadFile()` input paths will be affected by substring replacement.
/// 
/// You may use `DotobjAliasPathSubstringsApply()` if you'd like to perform path substring
/// remapping manually to strings that you provide yourself.
/// 
/// @param pathSubstring
/// @param newPath

function DotobjAliasPathSubstring(_pathSubstring, _newPath)
{
    static _aliasPathSubstringMap   = __DotobjSystem().__aliasPathSubstringMap;
    static _aliasPathSubstringArray = __DotobjSystem().__aliasPathSubstringArray;
    
    if (not ds_map_exists(_aliasPathSubstringMap, _newPath))
    {
        array_push(_aliasPathSubstringArray, _pathSubstring);
    }
    
    _aliasPathSubstringMap[? _pathSubstring] = _newPath;
}