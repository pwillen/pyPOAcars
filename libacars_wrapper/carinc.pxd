cimport clibacars

cdef extern from "libacars/arinc.h":
    ctypedef enum la_arinc_imi:
        ARINC_MSG_UNKNOWN = 0
        ARINC_MSG_CR1
        ARINC_MSG_CC1
        ARINC_MSG_DR1
        ARINC_MSG_AT1
        ARINC_MSG_ADS
        ARINC_MSG_DIS

    cdef clibacars.la_type_descriptor la_DEF_arinc_message

    ctypedef struct la_arinc_msg:
        char gs_addr[8]
        char air_reg[8]
        la_arinc_imi imi
        bint crc_ok