// Feather disable all

function ImGuiSystemFinalize()
{
    static _system = __ImGuiSystem();
    with(_system)
    {
        if (not __initialized) return;
        
        if (__imgui_shutdown(__state.Engine.Context))
        {
            __initialized = false;
            __state.Destroy();
        }
    }
}