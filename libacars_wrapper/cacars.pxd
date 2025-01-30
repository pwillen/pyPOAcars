# cacars.pxd
cimport clibacars
cimport cvstring
cimport creassembly

cdef extern from "<stdint.h>":
    ctypedef int uint8_t

cdef extern from "<sys/time.h>":
    ctypedef struct timeval:
        pass

cdef extern from "libacars/acars.h":
    cdef clibacars.la_type_descriptor la_DEF_acars_message

    ctypedef struct la_acars_msg:
        bint crc_ok
        bint err
        bint final_block
        char mode
        char reg[8]
        char ack
        char label[3]
        char sublabel[3]
        char mfi[3]
        char block_id
        char msg_num[4]
        char msg_num_seq
        char flight_id[7]
        creassembly.la_reasm_status reasm_status
        char *txt

    clibacars.la_proto_node *la_acars_decode_apps(char *label, char *txt, clibacars.la_msg_dir msg_dir)
    clibacars.la_proto_node *la_acars_apps_parse_and_reassemble(char *reg, char *label, char *txt, clibacars.la_msg_dir msg_dir, creassembly.la_reasm_ctx *rtables, timeval rx_time)
    clibacars.la_proto_node *la_acars_parse_and_reassemble(uint8_t *buf, int len, clibacars.la_msg_dir msg_dir, creassembly.la_reasm_ctx *rtables, timeval rx_time)
    clibacars.la_proto_node *la_acars_parse(uint8_t *buf, int len, clibacars.la_msg_dir msg_dir)
    int la_acars_extract_sublabel_and_mfi(char *label, clibacars.la_msg_dir msg_dir, char *txt, int len, char *sublabel, char *mfi)
    void la_acars_format_text(cvstring.la_vstring *vstr, void *data, int indent)
    void la_acars_format_json(cvstring.la_vstring *vstr, void *data)
    clibacars.la_proto_node *la_proto_tree_find_acars(clibacars.la_proto_node *root)
