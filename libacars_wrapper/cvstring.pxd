cdef extern from "libacars/vstring.h":
    ctypedef struct la_vstring:
        char *str;

    la_vstring *la_vstring_new()
    void la_vstring_destroy(la_vstring *vstr, bint destroy_buffer);