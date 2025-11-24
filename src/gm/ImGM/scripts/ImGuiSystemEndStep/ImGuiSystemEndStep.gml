// Feather disable all

function ImGuiSystemEndStep()
{
    static _system = __ImGuiSystem();
    with(_system)
    {
        if (not __initialized) return;
        
        __imgui_end_frame();
    }
}