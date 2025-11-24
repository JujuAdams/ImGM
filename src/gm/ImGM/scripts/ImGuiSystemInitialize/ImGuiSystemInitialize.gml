// Feather disable all

function ImGuiSystemInitialize(_configFlags = ImGuiConfigFlags.None)
{
    static _system = __ImGuiSystem();
    with(_system)
    {
        if (__initialized) return;
        
        var new_state = new ImGuiState();
        new_state.Engine.Window = new ImGuiBaseMainWindow();
        new_state.Engine.Context = ImGuiCreateContext();
        
        var inited = new_state.__Initialize(_configFlags);
        
        if ((inited == pointer_null) || (inited == undefined))
        {
            ImGuiDestroyContext(__state.Engine.Context);
            __state.Engine.Context = pointer_null;
            
            buffer_delete(__state.Renderer.CmdBuffer);
            __state.Renderer.CmdBuffer = -1;
            
            buffer_delete(__state.Renderer.FontBuffer);
            __state.Renderer.FontBuffer = -1;
            
            __initialized = false;
            return false;
        }
        else
        {
            new_state.Use();
            
            __initialized = true;
            return true;
        }
    }
}