// Feather disable all

/**
 * @function ImGuiState
 * @constructor
 * @context ImGM
 * @desc Creates a GM-side context and variables holder for use with ImGui
 * Internally-managed.
 *
 */
function ImGuiState() constructor
{
    enum StateUpdateFlags {
        None = 0,
        DisplaySize = 1 << 0,
        DisplayScale = 1 << 1,
        MousePos = 1 << 21,
        Framerate = 1 << 3,
        Time = 1 << 4,
        CmdBuffer = 1 << 5,
        FontBuffer = 1 << 6,
        UpdateFont = 1 << 7,

        Display = StateUpdateFlags.DisplaySize | StateUpdateFlags.DisplayScale,
        Input = StateUpdateFlags.MousePos,
        Engine = StateUpdateFlags.Framerate | StateUpdateFlags.Time,
        Renderer = StateUpdateFlags.CmdBuffer | StateUpdateFlags.FontBuffer | StateUpdateFlags.UpdateFont,

        All = StateUpdateFlags.Display | StateUpdateFlags.Input | StateUpdateFlags.Engine | StateUpdateFlags.Renderer,
    }

    var _os_info = os_get_info();

    __initialized = false;

    Display = {
        Width: 0,
        Height: 0,
        Scale: 1,
    };
    Input = {
        Mouse: {
            X: 0,
            Y: 0
        }
    };
    Engine = {
        D3DDevice: _os_info[? "video_d3d11_device"],
        D3DDeviceContext: _os_info[? "video_d3d11_context"],
        Context: pointer_null,
        Window: undefined,
        Time: 0,
        Framerate: game_get_speed(gamespeed_fps),
    };
    Renderer = {
        CmdBuffer: -1,
        FontBuffer: -1,
        Surface: -1,
        UpdateFont: true,
    };

    ds_map_destroy(_os_info);

    static __Initialize = function(wnd_or_config_flags_1=ImGuiConfigFlags.None, config_flags_2=ImGuiConfigFlags.None) {
        if __initialized return;

        if self.Engine.Context == pointer_null {
            self.Engine.Context = ImGuiCreateContext();
        }

        var window = self.Engine.Window;
        var config_flags_set = wnd_or_config_flags_1;
        var config_flags_clear = config_flags_2;

        if is_struct(wnd_or_config_flags_1) {
            window = wnd_or_config_flags_1;
            config_flags_set = config_flags_2;
            config_flags_clear = ImGuiConfigFlags.None;
        }

        self.Display.Width = display_get_width();
        self.Display.Height = display_get_height();
        self.Display.Font = -1;
        self.Renderer.Surface = -1;
        self.Renderer.CmdBuffer = buffer_exists(self.Renderer.CmdBuffer) ? self.Renderer.CmdBuffer : buffer_create(IMGUI_GM_BUFFER_SIZE, buffer_grow, 1);
        self.Renderer.FontBuffer = buffer_exists(self.Renderer.FontBuffer) ? self.Renderer.FontBuffer :  buffer_create(IMGUI_GM_BUFFER_SIZE, buffer_grow, 1);
        self.Renderer.UpdateFont = true;

        self.Use();

        var context = self.Engine.Context;

        var info = {
            D3DDevice: self.Engine.D3DDevice,
            D3DDeviceContext: self.Engine.D3DDeviceContext,
            GFlags: 3, //Magic number derived from old enum
            ConfigFlagsOverrideSet: config_flags_set,
            ConfigFlagsOverrideClear: config_flags_clear,
        };

        var hwnd = undefined;
        if is_struct(window) {
            hwnd = window.GetHandle();
        }

        if hwnd == undefined {
            show_error("Cannot initialize ImGuiState without a window handle. Make sure your window class or struct has the \"GetHandle\" function.", true);
        }

        self.Engine.Window = window;

        var inited = __imgui_initialize(hwnd, context, info); // -> context

        __initialized = true;
        return inited;
    }
    static Initialize = __Initialize;

    static __Use = function(flags=StateUpdateFlags.None)
    {
        static _system = __ImGuiSystem();
        
        _system.__state = self;
        ImGuiSetCurrentContext(self.Engine.Context);
        var _data = self.GetData();
        if flags != StateUpdateFlags.None {
            __imgui_update_state_from_struct(_data, flags);
        }
    }
    
    static Use = __Use;

    static __GetData = function() {
        return {
            Display: self.Display,
            Input: self.Input,
            Engine: self.Engine,
            Renderer: self.Renderer,
        }
    }
    static GetData = __GetData;

    static __Destroy = function()
    {
        if is_ptr(Engine.Context) ImGuiDestroyContext(Engine.Context);
        Engine.Context = pointer_null;
        
        if buffer_exists(Renderer.CmdBuffer) buffer_delete(Renderer.CmdBuffer);
        Renderer.CmdBuffer = -1;
        
        if buffer_exists(Renderer.FontBuffer) buffer_delete(Renderer.FontBuffer);
        Renderer.FontBuffer = -1;
        
        if surface_exists(Renderer.Surface) surface_free(Renderer.Surface);
        Renderer.Surface = -1;
        
        Engine.Window.__imgui_state = undefined;
        __initialized = false;
    }
    
    static Destroy = __Destroy;
}