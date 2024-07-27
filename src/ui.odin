package main

import          "../lib/odin-imgui/imgui_impl_sdl2"
import          "../lib/odin-imgui/imgui_impl_opengl3"
import im       "../lib/odin-imgui"

import sdl      "vendor:sdl2"
import gl       "vendor:OpenGL"

import          "core:fmt"
import          "core:strings"

CACHE_SIZE      :: 1 << 10
DEFAULT_IMG_SIZE: [2]f32: {256, 256}

c_search_text   : cstring     = "test_string"
running         :             = true
event           : sdl.Event
display_list    : [dynamic]Image

image_cache     : map[int]im.TextureID
thumbnail_size  : [2]f32 = {128, 128}

main_loop :: proc() 
{
        get_all_images()
        for img in display_list {
                image_cache[img.id] = open_image(img.path)
        }

        for running {
                handle_events()

                imgui_impl_opengl3.NewFrame()
                imgui_impl_sdl2.NewFrame()
                im.NewFrame()

                draw_menu_bar(0, 0)

                im.Begin("main", nil,
                        {
                                .NoResize,
                                .NoMove,
                                .NoCollapse,
                                .NoTitleBar,
                                .NoBringToFrontOnFocus,
                        })
                draw_search_bar(0, 15)
                draw_image_grid(0, 30)
                im.End()

                im.Render()
                io = im.GetIO()
                gl.Viewport(0, 0, i32(io.DisplaySize.x), i32(io.DisplaySize.y))
                gl.Clear(gl.COLOR_BUFFER_BIT)
                imgui_impl_opengl3.RenderDrawData(im.GetDrawData())
                sdl.GL_SwapWindow(window)
        }
}

image_load_queue : [dynamic]cstring
selected_files   : [dynamic]cstring

handle_events :: proc() 
{
        for sdl.PollEvent(&event) {
                imgui_impl_sdl2.ProcessEvent(&event)

                #partial switch event.type {
                case .QUIT: running = false
                case .DROPFILE:
                        path := string(event.drop.file)
                        if add_image(path) {
                                append(&selected_files, event.drop.file)
                        }
                case .MOUSEWHEEL:
                        if !im.IsKeyPressed(im.Key.LeftCtrl) do continue
                        switch {
                        //TODO: min and max sizes
                        case event.wheel.y > 0: thumbnail_size *= 2
                        case event.wheel.y < 0: thumbnail_size /= 2
                        }
                }
        }
}

draw_menu_bar :: proc(x, y: f32) 
{
        im.BeginMainMenuBar()
        {
                if im.BeginMenu("File") {
                        clicked := im.MenuItem("Open")
                        if clicked do open_file_dialog()
                        im.EndMenu()
                }
        }
        im.EndMainMenuBar()
}

draw_search_bar :: proc(x, y: f32) 
{
        im.Text("Search: ")
        im.SameLine()
        im.Text(c_search_text)
}

draw_image_grid :: proc(x, y: f32) 
{
        for img in display_list {
                id := strings.clone_to_cstring(img.path)
                if texture_id := image_cache[img.id]; texture_id != nil {
                        im.Image(image_cache[img.id], thumbnail_size)
                } else do im.Dummy(thumbnail_size)
        }
}

open_file_dialog :: proc() 
{
}
