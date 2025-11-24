// Feather disable all

function __ImGuiClassState(_configFlags = ImGuiConfigFlags.None) constructor
{
    var _osInfo = os_get_info();
    var _device = _osInfo[? "video_d3d11_device"];
    var _deviceContext = _osInfo[? "video_d3d11_context"];
    ds_map_destroy(_osInfo);
    
    Display = {
        Width: display_get_width(),
        Height: display_get_height(),
        Scale: 1,
        Font: -1,
    };
    
    Input = {
        Mouse: {
            X: 0,
            Y: 0
        }
    };
    
    Engine = {
        D3DDevice: _device,
        D3DDeviceContext: _deviceContext,
        Context: ImGuiCreateContext(),
        Time: 0,
        Framerate: game_get_speed(gamespeed_fps),
    };
    
    Renderer = {
        CmdBuffer: buffer_create(IMGUI_GM_BUFFER_SIZE, buffer_grow, 1),
        FontBuffer: buffer_create(IMGUI_GM_BUFFER_SIZE, buffer_grow, 1),
        Surface: -1,
        UpdateFont: true,
    };
    
    __initialized = false;
    
    var _initializeResult =  __imgui_initialize(window_handle(),
                                                Engine.Context,
                                                {
                                                    D3DDevice: Engine.D3DDevice,
                                                    D3DDeviceContext: Engine.D3DDeviceContext,
                                                    GFlags: 3, //Magic number derived from old enum
                                                    ConfigFlagsOverrideSet: _configFlags,
                                                    ConfigFlagsOverrideClear: ImGuiConfigFlags.None,
                                                });
    
    if ((_initializeResult != pointer_null) && (_initializeResult != undefined))
    {
        __initialized = true;
    }
    else
    {
        __Destroy();
    }
    
    static __Destroy = function()
    {
        if (is_ptr(Engine.Context)) ImGuiDestroyContext(Engine.Context);
        Engine.Context = pointer_null;
        
        if (buffer_exists(Renderer.CmdBuffer)) buffer_delete(Renderer.CmdBuffer);
        Renderer.CmdBuffer = -1;
        
        if (buffer_exists(Renderer.FontBuffer)) buffer_delete(Renderer.FontBuffer);
        Renderer.FontBuffer = -1;
        
        if (surface_exists(Renderer.Surface)) surface_free(Renderer.Surface);
        Renderer.Surface = -1;
        
        __initialized = false;
    }
}