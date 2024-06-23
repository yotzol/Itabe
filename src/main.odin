package main

import "core:os"
import "core:path/filepath"
import "core:strings"


APP_DIR                 : string  : ".local/share/Itabe/"
DATABASE_FILE           : cstring : "itabe.db"

WINDOW_TITLE            : cstring : "Itabe"
WINDOW_DEFAULT_WIDTH    : i32     : 640
WINDOW_DEFAULT_HEIGHT   : i32     : 480

main :: proc() 
{
        home_dir := os.get_env("HOME")
        assert(home_dir != "", "Could not get home directory")

        app_dir_exists := os.exists(concat_string(home_dir, string("/"), APP_DIR))
        if !app_dir_exists {
                err := os.make_directory(concat_string(home_dir, string("/"), APP_DIR))
                assert(err == 0, "Could not create project directory")
        }

        db_path := concat_cstring(home_dir, string("/"), APP_DIR, DATABASE_FILE)

        init_db(db_path)
        defer close_db()

        init_graphics()
        defer close_graphics()

        main_loop()
}

