package main

import          "../lib/odin-imgui/imgui_impl_sdl2"
import          "../lib/odin-imgui/imgui_impl_opengl3"
import im       "../lib/odin-imgui"

import sdl      "vendor:sdl2"
import gl       "vendor:OpenGL"


window  : ^sdl.Window
gl_ctx  : sdl.GLContext
io      : ^im.IO

init_graphics :: proc() 
{
        assert(sdl.Init(sdl.INIT_EVERYTHING) == 0,  "Failed to initialize SDL")

        sdl.GL_SetAttribute(.CONTEXT_FLAGS,         i32(sdl.GLcontextFlag.FORWARD_COMPATIBLE_FLAG))
        sdl.GL_SetAttribute(.CONTEXT_PROFILE_MASK,  i32(sdl.GLprofile.CORE))
        sdl.GL_SetAttribute(.CONTEXT_MAJOR_VERSION, 3)
        sdl.GL_SetAttribute(.CONTEXT_MINOR_VERSION, 2)

        window = sdl.CreateWindow(
                WINDOW_TITLE,
                sdl.WINDOWPOS_CENTERED,
                sdl.WINDOWPOS_CENTERED,
                WINDOW_DEFAULT_WIDTH,
                WINDOW_DEFAULT_HEIGHT,
                { .OPENGL, .RESIZABLE, .ALLOW_HIGHDPI }
        )
        assert(window != nil, "Failed to create window")

        gl_ctx = sdl.GL_CreateContext(window)
        assert(gl_ctx != nil, "Failed to create OpenGL context")

        sdl.GL_MakeCurrent(window, gl_ctx)
        sdl.GL_SetSwapInterval(0) // disable vsync

        gl.load_up_to(3, 2, proc(p: rawptr, name: cstring) {
                (cast(^rawptr)p)^ = sdl.GL_GetProcAddress(name)
        })

        im.CreateContext()
        io = im.GetIO()
        io.ConfigFlags += { .NavEnableKeyboard }
        im.StyleColorsDark()

        imgui_impl_sdl2   .InitForOpenGL(window, gl_ctx)
        imgui_impl_opengl3.Init(nil)
}

close_graphics :: proc() 
{
        imgui_impl_opengl3.Shutdown()
        imgui_impl_sdl2   .Shutdown()
        im.DestroyContext()

        sdl.GL_DeleteContext(gl_ctx)
        sdl.DestroyWindow(window)
        sdl.Quit()
}
