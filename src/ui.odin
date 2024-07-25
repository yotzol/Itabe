package main

import          "../lib/odin-imgui/imgui_impl_sdl2"
import          "../lib/odin-imgui/imgui_impl_opengl3"
import im       "../lib/odin-imgui"

import sdl      "vendor:sdl2"
import gl       "vendor:OpenGL"

import          "core:fmt"

CACHE_SIZE      :: 1 << 10
DEFAULT_IMG_SIZE: [2]f32: {256, 256}

c_search_text   : cstring     = "test_string"
running         :             = true
event           : sdl.Event
display_list    : [dynamic]Image

image_cache     : map[int]im.TextureID
thumbnail_size  : [2]f32 = {128, 128}

import fp "core:path/filepath"
main_loop :: proc() 
{
        // is_added := add_image("./test.jpg")

        get_all_images()
        for img in display_list {
                image_cache[img.id] = open_image(img.path)
        }

        for running {
                handle_events()

                imgui_impl_opengl3.NewFrame()
                imgui_impl_sdl2.NewFrame()

                gl.Viewport(0, 0, i32(io.DisplaySize.x), i32(io.DisplaySize.y))
                gl.ClearColor(0, 0, 0, 1)
                gl.Clear(gl.COLOR_BUFFER_BIT)

                im.NewFrame()

                draw_menu_bar(0, 0)
                draw_search_bar(0, 15)
                draw_image_grid(0, 30)

                im.Render()
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
        im.SetNextWindowPos({x, y})
        im.SetNextWindowSize(io.DisplaySize)
        im.SetNextWindowViewport(0)

        im.Begin("search", nil, {
                .NoResize,
                .NoMove,
                .NoCollapse,
                .NoTitleBar,
                .NoBringToFrontOnFocus,
        })
        {
                im.Text("Search: ")
                im.SameLine()
                im.Text(c_search_text)
        }
        im.End()
}

draw_image_grid :: proc(x, y: f32) 
{
        im.SetNextWindowPos({x, y})
        im.SetNextWindowSize(io.DisplaySize)
        im.SetNextWindowViewport(0)

        im.Begin("main", nil, {
                .NoResize,
                .NoMove,
                .NoCollapse,
                .NoTitleBar,
                .NoBringToFrontOnFocus,
        })
        {
                for img in display_list {
                        im.Image(image_cache[img.id], thumbnail_size)
                }
            
        }
        im.End()
}

open_file_dialog :: proc() 
{
}
