__ImGuiGlobal();
function __ImGuiGlobal()
{
    static _global = undefined;
    if (_global != undefined) return _global;
    
    _global = {};
    with(_global)
    {
        show_debug_message("ImGM: Welcome to ImGM by Kenan Masri!");
        show_debug_message("ImGM: This is a heavily editted version built by Juju Adams");
        
        __currentFrameContext = undefined;
        
        vertex_format_begin();
        vertex_format_add_position();
        vertex_format_add_texcoord();
        vertex_format_add_color();
        __vtxFormat = vertex_format_end();
        
        __vtxFormatStride = vertex_format_get_info(__vtxFormat).stride;
        
        __vtxBuffer = vertex_create_buffer();
        vertex_begin(__vtxBuffer, __vtxFormat);
        vertex_end(__vtxBuffer);
        
        __inputMapping  = __ImGuiCreateKeyboardMapping();
        __cursorMapping = __ImGuiCreateCursorMapping();
        
        __inputRequested = false;
        __inputStore     = undefined;
        
        time_source_start(time_source_create(time_source_global, 1, time_source_units_frames, function()
        {
            if (not instance_exists(__objImGMManager))
            {
                instance_activate_object(__objImGMManager);
                if (instance_exists(__objImGMManager))
                {
                    __ImGMWarning("`__objImGMManager` was deactivated.\nPlease ensure this object instance is never deactivated.");
                }
                else
                {
                    instance_create_depth(0, 0, 0, __objImGMManager);
                }
            }
        },
        [], -1));
    }
    
    return _global;
}