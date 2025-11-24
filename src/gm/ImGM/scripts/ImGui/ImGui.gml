new ImGui();

function ImGui() constructor
{
    __initialized = false;
    
    __state = undefined;
    __window = undefined;
    
    __mainWindowHandle = window_handle();
    __mainWindow = undefined;
    
    __vtxFormat = (function() {
        vertex_format_begin();
        vertex_format_add_position();
        vertex_format_add_texcoord();
        vertex_format_add_color();
        return vertex_format_end();
    })();
    
    __vtxFormatStride = vertex_format_get_info(__vtxFormat).stride;
    
    __vtxBuffer = (function()
    {
        var vtxBuffer = vertex_create_buffer();
        vertex_begin(vtxBuffer, __vtxFormat);
        vertex_end(vtxBuffer);
        return vtxBuffer;
    })();
    
    __inputMapping = __imgui_create_input_mapping();
    __cursorMapping = __imgui_create_cursor_mapping();
    
    __cursorPrev = -1;
    __inputRequested = false;
    __inputStore = undefined;
    
    
    
    static toString = function() {
        return $"<ImGui {string(__window)}>";
    }

    static __Initialize = function(ww_or_state_or_cfg=undefined, ctx=undefined) {
        if ImGui.__initialized return;

        // Setup received parameters
        var ww = undefined,
        _ctx_created = false,
        _cbf_created = true,
        _fbf_created = true,
        _config_override_set = ImGuiConfigFlags.None,
        new_state = undefined;

        if is_instanceof(ww_or_state_or_cfg, ImGuiState) {
            new_state = ww_or_state_or_cfg;

        } else if is_int32(ww_or_state_or_cfg) or is_int64(ww_or_state_or_cfg) or is_real(ww_or_state_or_cfg){
            _config_override_set = ww_or_state_or_cfg;
        } else if is_struct(ww_or_state_or_cfg) {
            ww = ww_or_state_or_cfg;

        }

        if ww == undefined {
            ImGui.__mainWindow ??= new ImGuiBaseMainWindow();
            ww = ImGui.__mainWindow;
        }

        ww ??= ImGui.__mainWindow;
        new_state ??= new ImGuiState();

        if is_int32(ctx) or is_int64(ctx) or is_real(ctx) {
            _config_override_set = ctx;
            ctx = undefined;
        }
        if ctx == undefined {
            if new_state.Engine.Context != pointer_null {
                ctx = new_state.Engine.Context;
            } else {
                ctx = ImGuiCreateContext();
                _ctx_created = true;
            }
        }

        // Setup the state.
        new_state.Engine.Window = ww;
        new_state.Engine.Context = ctx;

        ImGui.__window = ww;

        var inited = new_state.__Initialize(_config_override_set);

        if inited == pointer_null or inited == undefined {
            if _ctx_created ImGuiDestroyContext(__state.Engine.Context);
            if _cbf_created buffer_delete(__state.Renderer.CmdBuffer);
            if _fbf_created buffer_delete(__state.Renderer.FontBuffer);
            __state.Engine.Context = pointer_null;
            __state.Renderer.CmdBuffer = -1;
            __state.Renderer.FontBuffer = -1;
            ImGui.__initialized = false;
            return false;
        }
        ImGui.__initialized = true;
        new_state.Use();
        return true;
    }

    static __Shutdown = function(state=undefined) {
        if !ImGui.__initialized return;
        state ??= __state; if state != __state state.Use();

        if (__imgui_shutdown(__state.Engine.Context)) {
            ImGui.__initialized = false;
            __state.Destroy();
            delete __state;
            return true;
        }
        return false;
    }

    static __NewFrame = function(state=undefined) {
        if !ImGui.__initialized return;
        state ??= __state; if state != __state state.Use();

        var _dwidth = display_get_width(), _dheight = display_get_height(), _focus = false;
        var _wwidth = 0, _wheight = 0;

        _wwidth = __state.Engine.Window.GetWidth();
        _wheight = __state.Engine.Window.GetHeight();
        _focus = __state.Engine.Window.HasFocus();

        // Check surface
        if (!surface_exists(__state.Renderer.Surface)) {
            __state.Renderer.Surface = surface_create(max(1, _wwidth), max(1, _wheight));
        }

        if _wwidth != 0 __state.Display.Width = _wwidth;
        if _wheight != 0 __state.Display.Height = _wheight;
        __state.Engine.Time = delta_time / 1_000_000;
        __state.Engine.Framerate = game_get_speed(gamespeed_fps);

        if ((_wwidth > 0 && _wheight > 0)) {
            for(var i = ImGuiKey.NamedKey_BEGIN; i < ImGuiKey.NamedKey_END; i++) {
                var key = ImGui.__inputMapping[i];
                if (key > -1) __imgui_key(i, keyboard_check_direct(key));
            }
            __imgui_key(ImGuiKey.ImGuiMod_Ctrl, keyboard_check_direct(vk_lcontrol));
            __imgui_key(ImGuiKey.ImGuiMod_Shift, keyboard_check_direct(vk_lshift));
            __imgui_key(ImGuiKey.ImGuiMod_Alt, keyboard_check_direct(vk_lalt));

            if (__imgui_want_text_input(undefined)) {
                if (!__inputRequested) {
                    __inputRequested = true;
                    __inputStore = keyboard_string;
                    keyboard_string = "";
                }
                if (__imgui_input(keyboard_string)) keyboard_string = "";
            } else {
                if (__inputRequested) {
                    keyboard_string = __inputStore;
                    __inputRequested = false;
                }
            }

            var _x = __state.Engine.Window.GetX();
            var _y = __state.Engine.Window.GetY();

            var _do_mouse = (_focus == true);

            if _do_mouse {
                __state.Input.Mouse.X = __state.Engine.Window.MouseGetX();
                __state.Input.Mouse.Y = __state.Engine.Window.MouseGetY();
                for(var i = 0; i < 3; i++) __imgui_mouse(i, __state.Engine.Window.MouseCheckButton(i + 1));
                if (__state.Engine.Window.MouseWheelUp()) __imgui_mouse_wheel(0, 1);
                else if (__state.Engine.Window.MouseWheelDown()) __imgui_mouse_wheel(0, -1);

                var _cursor = __imgui_mouse_cursor();
                if (_cursor != __cursorPrev) {
                    __state.Engine.Window.SetCursor(ImGui.__cursorMapping[_cursor + 1]);
                    __cursorPrev = _cursor;
                }
            }
        }

        var _data = __state.__GetData();
        __imgui_new_frame(_data);

        if (buffer_peek(__state.Renderer.FontBuffer, 0, buffer_bool)) {
            if (sprite_exists(__state.Display.Font)) sprite_delete(__state.Display.Font);
            var font = surface_create(buffer_peek(__state.Renderer.FontBuffer, 1, buffer_u32), buffer_peek(__state.Renderer.FontBuffer, 5, buffer_u32));
            buffer_set_surface(__state.Renderer.FontBuffer, font, 9);
            __state.Display.Font = sprite_create_from_surface(font, 0, 0, surface_get_width(font), surface_get_height(font), false, false, 0, 0);
            surface_free(font);
            __state.Renderer.UpdateFont = false;
        }
    }

    static __EndFrame = function(state=undefined) {
        if !ImGui.__initialized return;
        state ??= __state; if state != __state state.Use();

        __imgui_end_frame();
    }

    static __Render = function(state=undefined) {
        if !ImGui.__initialized return;
        state ??= __state; if state != __state state.Use();

        __imgui_render();
    }

    static __Draw = function(state=undefined, _rescale=true) {
        if !ImGui.__initialized return;
        state ??= __state; if state != __state state.Use();

        if (!surface_exists(__state.Renderer.Surface)) {
            __state.Renderer.Surface = surface_create(max(1, __state.Display.Width), max(1, __state.Display.Height));
        }

        var _w = display_get_gui_width(), _h = display_get_gui_height();
        var _ww = __state.Engine.Window.GetWidth();
        var _wh = __state.Engine.Window.GetHeight();

		if (_rescale) {
	        if (_ww > 0 and _wh > 0) {
				if (_w != _ww && _h != _wh) {
					if (__state.Engine.Window.GetHandle() == __mainWindowHandle) {
						display_set_gui_size(_ww, _wh);
						surface_resize(application_surface, _ww, _wh);
					}
				}
			}
		}

        var _data = __state.__GetData();
        __imgui_draw(_data);

        var cmdBuffer = __state.Renderer.CmdBuffer;
        buffer_seek(cmdBuffer, buffer_seek_start, 0);
        if (buffer_read(cmdBuffer, buffer_bool)) { // data->Valid
                
            //Cache static values for better performance inside the loop
            var vtxBuffer = __vtxBuffer;
            var vtxStride = __vtxFormatStride;
                
            //Keep a copy of the current scissor state for later reset
            var oldScissor = gpu_get_scissor();
                
            surface_set_target(__state.Renderer.Surface);
            gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha); //Pre-multiplied alpha blend mode
            draw_clear_alpha(0, 0);
            var list_count = buffer_read(cmdBuffer, buffer_u32);
            for(var i = 0; i < list_count; i++) {
                var cmd_count = buffer_read(cmdBuffer, buffer_u32);
                for(var j = 0; j < cmd_count; j++) {
                    if (!buffer_read(cmdBuffer, buffer_bool)) { // UserCallback != nullptr
                        var tex_data = buffer_read(cmdBuffer, buffer_u32);
                        var tex_id = -1;
                        switch (tex_data & 0xF) {
                            case ImGuiTextureType.Surface: {
                                tex_id = surface_get_texture(tex_data >> 16);
                                break;
                            }

                            case ImGuiTextureType.Font: {
                                tex_id = sprite_get_texture(__state.Display.Font, 0);
                                break;
                            }

                            case ImGuiTextureType.Sprite: {
                                tex_id = sprite_get_texture(tex_data >> 16, (tex_data >> 4) & 0xFFF);
                                break;
                            }
                        }

                        var clip_x1 = buffer_read(cmdBuffer, buffer_f32);
                        var clip_y1 = buffer_read(cmdBuffer, buffer_f32);
                        var clip_x2 = buffer_read(cmdBuffer, buffer_f32);
                        var clip_y2 = buffer_read(cmdBuffer, buffer_f32);
                        gpu_set_scissor(clip_x1, clip_y1, clip_x2 - clip_x1, clip_y2 - clip_y1);
                            
                        var vtx_count = buffer_read(cmdBuffer, buffer_u32);
                        vertex_update_buffer_from_buffer(vtxBuffer, 0, cmdBuffer, buffer_tell(cmdBuffer), vtxStride*vtx_count);
                        vertex_submit_ext(vtxBuffer, pr_trianglelist, tex_id, 0, vtx_count)
                            
                        buffer_seek(cmdBuffer, buffer_seek_relative, vtxStride*vtx_count);
                    }
                }
            }
            surface_reset_target();
            gpu_set_blendmode(bm_normal);
            gpu_set_scissor(oldScissor);

            if _ww > 0 and _wh > 0 {
                if (__state.Engine.Window[$ "DrawBegin"]) {
                    __state.Engine.Window.DrawBegin();
                }
                if (__state.Engine.Window[$ "DrawClear"]) {
                    __state.Engine.Window.DrawClear();
                }

                draw_surface(__state.Renderer.Surface, 0, 0);

                if (__state.Engine.Window[$ "DrawEnd"]) {
                    __state.Engine.Window.DrawEnd();
                }
            }
        }
    }

    return self;
};