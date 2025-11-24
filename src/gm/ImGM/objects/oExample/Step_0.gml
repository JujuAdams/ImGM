ImGuiSetNextWindowSize(room_width / 2, room_height / 2, ImGuiCond.Once);
var ret = ImGuiBegin("ImGM Example", true, ImGuiWindowFlags.None, ImGuiReturnMask.Both);
ImGuiEnd();

display_set_gui_size(window_get_width(), window_get_height());