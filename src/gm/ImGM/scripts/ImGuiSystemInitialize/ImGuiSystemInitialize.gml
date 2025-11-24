// Feather disable all

function ImGuiSystemInitialize(_configFlags = ImGuiConfigFlags.None)
{
    static _system = __ImGuiSystem();
    with(_system)
    {
        if (__initialized) return;
        
        var _newState = new ImGuiState(_configFlags);
        if (_newState.__initialized)
        {
            __state = _newState;
            ImGuiSetCurrentContext(_newState.Engine.Context);
            
            __initialized = true;
            
            return true;
        }
        else
        {
            return false;
        }
    }
}