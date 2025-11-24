// Feather disable all

function ImGuiSystemGetSurface()
{
    static _system = __ImGuiSystem();
    with(_system)
    {
        return __state.Renderer.Surface;
    }
}