// Feather disable all

function ImGuiSystemEndFrame(state = undefined)
{
    static _system = __ImGuiSystem();
    with(_system)
    {
        if (not __initialized) return;
        
        state ??= __state;
        if (state != __state) state.Use();
        
        __imgui_end_frame();
    }
}