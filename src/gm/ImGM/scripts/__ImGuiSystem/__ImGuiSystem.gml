__ImGuiSystem();
function __ImGuiSystem()
{
    static _system = undefined;
    if (_system != undefined) return _system;
    
    _system = {};
    with(_system)
    {
        show_debug_message("ImGui: Welcome to ImGM by Kenan Masri!");
        show_debug_message("ImGui: This is a heavily editted version built by Juju Adams");
        
        __initialized = false;
        __state = undefined;
        
        vertex_format_begin();
        vertex_format_add_position();
        vertex_format_add_texcoord();
        vertex_format_add_color();
        __vtxFormat = vertex_format_end();
        
        __vtxFormatStride = vertex_format_get_info(__vtxFormat).stride;
        
        __vtxBuffer = vertex_create_buffer();
        vertex_begin(__vtxBuffer, __vtxFormat);
        vertex_end(__vtxBuffer);
        
        __inputMapping  = __imgui_create_input_mapping();
        __cursorMapping = __imgui_create_cursor_mapping();
        
        __cursorPrev = -1;
        __inputRequested = false;
        __inputStore = undefined;
    }
    
    return _system;
}