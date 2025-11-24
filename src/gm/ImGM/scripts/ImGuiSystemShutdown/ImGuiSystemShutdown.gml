// Feather disable all

function ImGuiSystemShutdown(state = undefined)
{
    static _system = __ImGuiSystem();
    with(_system)
    {
        if (not __initialized) return;
        
        state ??= __state;
        if (state != __state) state.Use();
        
        if (__imgui_shutdown(__state.Engine.Context))
        {
            __initialized = false;
            __state.Destroy();
            
            return true;
        }
        
        return false;
    }
}