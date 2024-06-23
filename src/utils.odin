package main

import "core:strings"

StringUnion :: union {
        string,
        cstring,
}

concat_string :: proc(string_args: ..StringUnion) -> string
{
        string_arr : [dynamic]string
        for s in string_args {
                switch type in s {
                case string:
                        append(&string_arr, s.(string))
                case cstring:
                        append(&string_arr, string(s.(cstring)))
                }
        }

        return strings.concatenate(string_arr[:])
}

concat_cstring :: proc(string_args: ..StringUnion) -> cstring
{
        return strings.clone_to_cstring(concat_string(..string_args))
}
