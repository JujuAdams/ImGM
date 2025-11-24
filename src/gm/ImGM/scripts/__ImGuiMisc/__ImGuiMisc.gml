#region ImGM Macros

/// Current ImGM extension version
#macro IMGM_VERSION (extension_get_version("__ImGMExtension"))

/// Initial size of grow buffers (draw and font)
#macro IMGUI_GM_BUFFER_SIZE             1024 * 8

#endregion

/// @section Enums
/// Manually-updated section for specific enums

/**
 * @enum ImGuiReturnMask
 * @context ImGM
 * @desc You can use this in various GML wrapper functions as an argument to specify the return value type.
 * Or to mask the return value, if you use `ImGuiReturnMask.Both`.
 * Defaults to ImGuiReturnMask.Return
 *
 * @example
 *
 * // Mostly used like this
 * var ret = ImGui.Begin("ImGM Example", is_open, ImGuiWindowFlags.None, ImGuiReturnMask.Both);
 * is_open = ret & ImGuiReturnMask.Pointer;
 * if (ret & ImGuiReturnMask.Return) { inner ImGui code... }
 *
 */
enum ImGuiReturnMask {
    None = 0,            // Should be unused
    Return = 1 << 0,
    Pointer = 1 << 1,
    Both = ImGuiReturnMask.Return | ImGuiReturnMask.Pointer
}

/**
 * @enum ImGuiTextureType
 * @desc This is used internally by the GM Renderer for drawing
 *
 */
enum ImGuiTextureType {
    Raw = 0,
    Sprite = 1 << 0,
    Surface = 1 << 1,
    Font = 1 << 2
}

/**
 * @enum ImGuiKey
 * @context ImGM
 * @desc ImGuiKey with some modifications from imgui.h
 *
 */
enum ImGuiKey {
    // Keyboard
    None = 0,
    Tab = 512,             // == NamedKey_BEGIN
    LeftArrow,
    RightArrow,
    UpArrow,
    DownArrow,
    PageUp,
    PageDown,
    Home,
    End,
    Insert,
    Delete,
    Backspace,
    Space,
    Enter,
    Escape,
    LeftCtrl, LeftShift, LeftAlt, LeftSuper,
    RightCtrl, RightShift, RightAlt, RightSuper,
    Menu,
    ImGuiKey_0, ImGuiKey_1, ImGuiKey_2, ImGuiKey_3, ImGuiKey_4, ImGuiKey_5, ImGuiKey_6, ImGuiKey_7, ImGuiKey_8, ImGuiKey_9,
    A, B, C, D, E, F, G, H, I, J,
    K, L, M, N, O, P, Q, R, S, T,
    U, V, W, X, Y, Z,
    F1, F2, F3, F4, F5, F6,
    F7, F8, F9, F10, F11, F12,
    Apostrophe,        // '
    Comma,             // ,
    Minus,             // -
    Period,            // .
    Slash,             // /
    Semicolon,         // ;
    Equal,             // =
    LeftBracket,       // [
    Backslash,         // \ (this text inhibit multiline comment caused by backslash)
    RightBracket,      // ]
    GraveAccent,       // `
    CapsLock,
    ScrollLock,
    NumLock,
    PrintScreen,
    Pause,
    Keypad0, Keypad1, Keypad2, Keypad3, Keypad4,
    Keypad5, Keypad6, Keypad7, Keypad8, Keypad9,
    KeypadDecimal,
    KeypadDivide,
    KeypadMultiply,
    KeypadSubtract,
    KeypadAdd,
    KeypadEnter,
    KeypadEqual,

    // Gamepad (some of those are analog values, 0.0f to 1.0f)                          // NAVIGATION ACTION
    // (download controller mapping PNG/PSD at http://dearimgui.org/controls_sheets)
    GamepadStart,          // Menu (Xbox)      + (Switch)   Start/Options (PS)
    GamepadBack,           // View (Xbox)      - (Switch)   Share (PS)
    GamepadFaceLeft,       // X (Xbox)         Y (Switch)   Square (PS)        // Tap: Toggle Menu. Hold: Windowing mode (Focus/Move/Resize windows)
    GamepadFaceRight,      // B (Xbox)         A (Switch)   Circle (PS)        // Cancel / Close / Exit
    GamepadFaceUp,         // Y (Xbox)         X (Switch)   Triangle (PS)      // Text Input / On-screen Keyboard
    GamepadFaceDown,       // A (Xbox)         B (Switch)   Cross (PS)         // Activate / Open / Toggle / Tweak
    GamepadDpadLeft,       // D-pad Left                                       // Move / Tweak / Resize Window (in Windowing mode)
    GamepadDpadRight,      // D-pad Right                                      // Move / Tweak / Resize Window (in Windowing mode)
    GamepadDpadUp,         // D-pad Up                                         // Move / Tweak / Resize Window (in Windowing mode)
    GamepadDpadDown,       // D-pad Down                                       // Move / Tweak / Resize Window (in Windowing mode)
    GamepadL1,             // L Bumper (Xbox)  L (Switch)   L1 (PS)            // Tweak Slower / Focus Previous (in Windowing mode)
    GamepadR1,             // R Bumper (Xbox)  R (Switch)   R1 (PS)            // Tweak Faster / Focus Next (in Windowing mode)
    GamepadL2,             // L Trig. (Xbox)   ZL (Switch)  L2 (PS) [Analog]
    GamepadR2,             // R Trig. (Xbox)   ZR (Switch)  R2 (PS) [Analog]
    GamepadL3,             // L Stick (Xbox)   L3 (Switch)  L3 (PS)
    GamepadR3,             // R Stick (Xbox)   R3 (Switch)  R3 (PS)
    GamepadLStickLeft,     // [Analog]                                         // Move Window (in Windowing mode)
    GamepadLStickRight,    // [Analog]                                         // Move Window (in Windowing mode)
    GamepadLStickUp,       // [Analog]                                         // Move Window (in Windowing mode)
    GamepadLStickDown,     // [Analog]                                         // Move Window (in Windowing mode)
    GamepadRStickLeft,     // [Analog]
    GamepadRStickRight,    // [Analog]
    GamepadRStickUp,       // [Analog]
    GamepadRStickDown,     // [Analog]

    // Aliases: Mouse Buttons (auto-submitted from AddMouseButtonEvent() calls)
    // - This is mirroring the data also written to io.MouseDown[], io.MouseWheel, in a format allowing them to be accessed via standard key API.
    MouseLeft, MouseRight, MouseMiddle, MouseX1, MouseX2, MouseWheelX, MouseWheelY,

    // [Internal] Reserved for mod storage
    ReservedForModCtrl, ReservedForModShift, ReservedForModAlt, ReservedForModSuper,
    COUNT,

    // Keyboard Modifiers (explicitly submitted by backend via AddKeyEvent() calls)
    // - This is mirroring the data also written to io.KeyCtrl, io.KeyShift, io.KeyAlt, io.KeySuper, in a format allowing
    //   them to be accessed via standard key API, allowing calls such as IsKeyPressed(), IsKeyReleased(), querying duration etc.
    // - Code polling every key (e.g. an interface to detect a key press for input mapping) might want to ignore those
    //   and prefer using the real keys (e.g. LeftCtrl, RightCtrl instead of ImGuiMod_Ctrl).
    // - In theory the value of keyboard modifiers should be roughly equivalent to a logical or of the equivalent left/right keys.
    //   In practice: it's complicated; mods are often provided from different sources. Keyboard layout, IME, sticky keys and
    //   backends tend to interfere and break that equivalence. The safer decision is to relay that ambiguity down to the end-user...
    ImGuiMod_None                   = 0,
    ImGuiMod_Ctrl                   = 1 << 12, // Ctrl
    ImGuiMod_Shift                  = 1 << 13, // Shift
    ImGuiMod_Alt                    = 1 << 14, // Option/Menu
    ImGuiMod_Super                  = 1 << 15, // Cmd/Super/Windows
    ImGuiMod_Shortcut               = 1 << 11, // Alias for Ctrl (non-macOS) _or_ Super (macOS).
    ImGuiMod_Mask_                  = 0xF800,  // 5-bits

    // [Internal] Prior to 1.87 we required user to fill io.KeysDown[512] using their own native index + the io.KeyMap[] array.
    // We are ditching this method but keeping a legacy path for user code doing e.g. IsKeyPressed(MY_NATIVE_KEY_CODE)
    NamedKey_BEGIN         = 512,
    NamedKey_END           = ImGuiKey.COUNT,
    NamedKey_COUNT         = ImGuiKey.NamedKey_END - ImGuiKey.NamedKey_BEGIN,
    KeysData_SIZE          = ImGuiKey.COUNT,                   // Size of KeysData[]: hold legacy 0..512 keycodes + named keys
    KeysData_OFFSET        = 0,                                // First key stored in io.KeysData[0]. Accesses to io.KeysData[] must use (key - KeysData_OFFSET).
};

/// @endsection

/// @section Helpers

/**
 * @function __imgui_create_cursor_mapping
 * @context ImGM
 * @desc Initialize the mapping array for GM cursors <-> ImGui cursors
 *
 */
function __imgui_create_cursor_mapping() {
    var arr = array_create(ImGuiMouseCursor.NotAllowed + 1, cr_none);
    arr[ImGuiMouseCursor.None + 1] = cr_none;
    arr[ImGuiMouseCursor.Arrow + 1] = cr_default;
    arr[ImGuiMouseCursor.TextInput + 1] = cr_beam;
    arr[ImGuiMouseCursor.ResizeAll + 1] = cr_size_all;
    arr[ImGuiMouseCursor.ResizeNS + 1] = cr_size_ns;
    arr[ImGuiMouseCursor.ResizeEW + 1] = cr_size_we;
    arr[ImGuiMouseCursor.ResizeNESW + 1] = cr_size_nesw;
    arr[ImGuiMouseCursor.ResizeNWSE + 1] = cr_size_nwse;
    arr[ImGuiMouseCursor.Hand + 1] = cr_handpoint;
    arr[ImGuiMouseCursor.NotAllowed + 1] = cr_default;
    return arr;
}

/**
 * @function __imgui_create_input_mapping
 * @context ImGM
 * @desc Initialize the mapping array for GM virtual keys <-> ImGui keys
 *
 */
function __imgui_create_input_mapping() {
    var arr = array_create(ImGuiKey.KeysData_SIZE, -1);
    arr[ImGuiKey.None] = vk_nokey;
    arr[ImGuiKey.Enter] = vk_enter;
    arr[ImGuiKey.Escape] = vk_escape;
    arr[ImGuiKey.Space] = vk_space;
    arr[ImGuiKey.Backspace] = vk_backspace;
    arr[ImGuiKey.Tab] = vk_tab;
    arr[ImGuiKey.Pause] = vk_pause;
    arr[ImGuiKey.LeftArrow] = vk_left;
    arr[ImGuiKey.RightArrow] = vk_right;
    arr[ImGuiKey.UpArrow] = vk_up;
    arr[ImGuiKey.DownArrow] = vk_down;
    arr[ImGuiKey.Home] = vk_home;
    arr[ImGuiKey.End] = vk_end;
    arr[ImGuiKey.Delete] = vk_delete;
    arr[ImGuiKey.Insert] = vk_insert;
    arr[ImGuiKey.PageUp] = vk_pageup;
    arr[ImGuiKey.PageDown] = vk_pagedown;
    arr[ImGuiKey.F1] = vk_f1;
    arr[ImGuiKey.F2] = vk_f2;
    arr[ImGuiKey.F3] = vk_f3;
    arr[ImGuiKey.F4] = vk_f4;
    arr[ImGuiKey.F5] = vk_f5;
    arr[ImGuiKey.F6] = vk_f6;
    arr[ImGuiKey.F7] = vk_f7;
    arr[ImGuiKey.F8] = vk_f8;
    arr[ImGuiKey.F9] = vk_f9;
    arr[ImGuiKey.F10] = vk_f10;
    arr[ImGuiKey.F11] = vk_f11;
    arr[ImGuiKey.F12] = vk_f12;
    arr[ImGuiKey.Keypad0] = vk_numpad0;
    arr[ImGuiKey.Keypad1] = vk_numpad1;
    arr[ImGuiKey.Keypad2] = vk_numpad2;
    arr[ImGuiKey.Keypad3] = vk_numpad3;
    arr[ImGuiKey.Keypad4] = vk_numpad4;
    arr[ImGuiKey.Keypad5] = vk_numpad5;
    arr[ImGuiKey.Keypad6] = vk_numpad6;
    arr[ImGuiKey.Keypad7] = vk_numpad7;
    arr[ImGuiKey.Keypad8] = vk_numpad8;
    arr[ImGuiKey.Keypad9] = vk_numpad9;
    arr[ImGuiKey.KeypadDivide] = vk_divide;
    arr[ImGuiKey.KeypadMultiply] = vk_multiply;
    arr[ImGuiKey.KeypadSubtract] = vk_subtract;
    arr[ImGuiKey.KeypadAdd] = vk_add;
    arr[ImGuiKey.KeypadDecimal] = vk_decimal;
    arr[ImGuiKey.LeftShift] = vk_lshift;
    arr[ImGuiKey.LeftCtrl] = vk_lcontrol;
    arr[ImGuiKey.LeftAlt] = vk_lalt;
    arr[ImGuiKey.RightShift] = vk_rshift;
    arr[ImGuiKey.RightCtrl] = vk_rcontrol;
    arr[ImGuiKey.RightAlt] = vk_ralt;
    arr[ImGuiKey.ImGuiKey_1] = ord("1");
    arr[ImGuiKey.ImGuiKey_2] = ord("2");
    arr[ImGuiKey.ImGuiKey_3] = ord("3");
    arr[ImGuiKey.ImGuiKey_4] = ord("4");
    arr[ImGuiKey.ImGuiKey_5] = ord("5");
    arr[ImGuiKey.ImGuiKey_6] = ord("6");
    arr[ImGuiKey.ImGuiKey_7] = ord("7");
    arr[ImGuiKey.ImGuiKey_8] = ord("8");
    arr[ImGuiKey.ImGuiKey_9] = ord("9");
    arr[ImGuiKey.ImGuiKey_0] = ord("10");
    arr[ImGuiKey.A] = ord("A");
    arr[ImGuiKey.B] = ord("B");
    arr[ImGuiKey.C] = ord("C");
    arr[ImGuiKey.D] = ord("D");
    arr[ImGuiKey.E] = ord("E");
    arr[ImGuiKey.F] = ord("F");
    arr[ImGuiKey.G] = ord("G");
    arr[ImGuiKey.H] = ord("H");
    arr[ImGuiKey.I] = ord("I");
    arr[ImGuiKey.J] = ord("J");
    arr[ImGuiKey.K] = ord("K");
    arr[ImGuiKey.L] = ord("L");
    arr[ImGuiKey.M] = ord("M");
    arr[ImGuiKey.N] = ord("N");
    arr[ImGuiKey.O] = ord("O");
    arr[ImGuiKey.P] = ord("P");
    arr[ImGuiKey.Q] = ord("Q");
    arr[ImGuiKey.R] = ord("R");
    arr[ImGuiKey.S] = ord("S");
    arr[ImGuiKey.T] = ord("T");
    arr[ImGuiKey.U] = ord("U");
    arr[ImGuiKey.V] = ord("V");
    arr[ImGuiKey.W] = ord("W");
    arr[ImGuiKey.X] = ord("X");
    arr[ImGuiKey.Y] = ord("Y");
    arr[ImGuiKey.Z] = ord("Z");
    arr[ImGuiKey.GraveAccent] = 192;
    return arr;
}

/// @endsection
