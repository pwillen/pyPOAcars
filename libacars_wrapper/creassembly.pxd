cdef extern from "libacars/reassembly.h":
    ctypedef struct la_reasm_ctx
    ctypedef enum la_reasm_status:
        LA_REASM_UNKNOWN
        LA_REASM_COMPLETE
        LA_REASM_IN_PROGRESS
        LA_REASM_SKIPPED
        LA_REASM_DUPLICATE
        LA_REASM_FRAG_OUT_OF_SEQUENCE
        LA_REASM_ARGS_INVALID