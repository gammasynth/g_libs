# Registry System - Export Build Fix

## Problem
The Registry system loads folders/files from `res://` paths using `DirAccess`, which works in the editor but fails in exported builds. This is because exported Godot games pack the `res://` directory into a PCK (Godot package) file, making it inaccessible to `DirAccess` directory enumeration.

## Root Cause
In [folder_util.gd](g_libs/g_file/class/folder_util.gd), the functions:
- `get_all_directories_from_directory()`
- `get_all_filepaths_from_directory()`

...both use `DirAccess.open()` to enumerate directories and files. While this works perfectly in the Godot editor where the file system is directly accessible, it fails in exported builds where files are packed into a PCK archive.

## Solution
Added export-safe fallback mechanisms for `res://` paths:

1. **Path Detection**: Both functions now check if the path starts with `res://`
2. **Dual Strategy**:
   - **Editor**: Uses `DirAccess` (fast, works perfectly)
   - **Exported Builds**: Falls back to `ResourceLoader.list_resources()` (slightly slower but works everywhere)

### Modified Functions

#### `get_all_directories_from_directory()`
- Added check for `res://` paths
- Routes to new `_get_all_directories_from_directory_res()` helper
- Extracts unique directory names from resource paths
- Maintains all original functionality (full_path, recursive, blacklist support)

#### `get_all_filepaths_from_directory()`
- Added check for `res://` paths
- Routes to new `_get_all_filepaths_from_directory_res()` helper
- Uses `ResourceLoader.list_resources()` as fallback
- Maintains all original functionality (whitelist_extension, full_path, blacklist support)

## Implementation Details

### Export-Safe Directory Listing
```gdscript
_get_all_directories_from_directory_res()
```
- Tries `DirAccess` first (editor/dev builds)
- Falls back to `ResourceLoader.list_resources()` if needed
- Parses resource paths to extract directory structure
- Avoids duplicates using a dictionary
- Supports recursive directory traversal

### Export-Safe File Listing
```gdscript
_get_all_filepaths_from_directory_res()
```
- Tries `DirAccess` first (editor/dev builds)
- Falls back to `ResourceLoader.list_resources()` as fallback
- Filters only files directly in the target directory (not subdirectories)
- Respects whitelist extensions and blacklist filters
- Maintains compatibility with full_path option

## Affected Registry Components
This fix automatically improves:
- `RegistryStack._setup_main_registry_subregistries()` - Dynamic registry discovery
- `RegistryBase.collect_unloaded_directory_data()` - File collection for loading
- `LiveDatabase.check_folder_for_folder()` - Folder scanning utilities
- `RegistryModdable.get_modded_directories_for_registry()` - Mod folder detection

## Testing
To verify the fix works:

1. **Editor Test**: Verify registry still loads all content correctly in the editor
2. **Export Test**: Build an exported version and confirm:
   - Registries are properly discovered
   - All registry files load successfully
   - No console errors about missing directories

## Backward Compatibility
✅ Fully backward compatible
- Non-`res://` paths (like `user://`) continue using `DirAccess`
- All function signatures remain unchanged
- No breaking changes to existing code

## Performance Notes
- **Editor**: No performance impact (still uses `DirAccess`)
- **Exported**: Slight overhead from `ResourceLoader.list_resources()` (acceptable - only runs during startup)

## Related Files Modified
- [g_file/class/folder_util.gd](g_file/class/folder_util.gd) - Main implementation
