# cadsc.pxd
cimport clibacars
cimport cvstring
cimport clist
cimport carinc

cdef extern from "<stdint.h>":
    ctypedef int uint8_t
    ctypedef int uint32_t

cdef extern from "libacars/adsc.h":
    cdef clibacars.la_type_descriptor la_DEF_adsc_message

    ctypedef struct la_adsc_formatter_ctx_t:
        cvstring.la_vstring *vstr
        int indent

    ctypedef int la_adsc_parser_fun (void *dest, uint8_t *buf, uint32_t len)
    ctypedef void la_adsc_formatter_fun(la_adsc_formatter_ctx_t *ctx, char *label, void * data)
    ctypedef void la_adsc_destructor_fun(void *data);

    ctypedef struct la_adsc_type_descriptor_t:
        char *label
        char *json_key
        la_adsc_parser_fun *parse
        la_adsc_formatter_fun *format_text
        la_adsc_formatter_fun *format_json
        la_adsc_destructor_fun *destroy

    ctypedef struct la_adsc_msg_t:
        bint err
        clist.la_list *tag_list

    ctypedef struct la_adsc_tag_t:
        uint8_t tag
        la_adsc_type_descriptor_t *type
        void *data

    clibacars.la_proto_node *la_adsc_parse(uint8_t *buf, int len, clibacars.la_msg_dir msg_dir, carinc.la_arinc_imi imi)
