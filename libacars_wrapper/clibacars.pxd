# clibacars.pxd
cimport cvstring
cdef extern from "libacars/version.h":
    pass

cdef extern from "libacars/libacars.h":
    ctypedef enum la_msg_dir:
        LA_MSG_DIR_UNKNOWN
        LA_MSG_DIR_GND2AIR
        LA_MSG_DIR_AIR2GND

    ctypedef void la_format_text_func(cvstring.la_vstring *vstr, void *data, int indent)
    ctypedef void la_format_json_func(cvstring.la_vstring *vstr, void *data)
    ctypedef void la_destroy_type_f(void *data)

    ctypedef struct la_type_descriptor:
        la_format_text_func *format_text
        la_destroy_type_f *destroy
        la_format_json_func *format_json
        char *json_key

    ctypedef struct la_proto_node:
        la_type_descriptor *td
        void *data
        la_proto_node *next

    la_proto_node *la_proto_node_new()
    void la_proto_tree_destroy(la_proto_node *root)
    cvstring.la_vstring *la_proto_tree_format_text(cvstring.la_vstring *vstr, la_proto_node *root)
    cvstring.la_vstring *la_proto_tree_format_json(cvstring.la_vstring *vstr, la_proto_node *root)
