cimport clibacars

# TODO Move to its own definition file and further define the struct
#  Maybe... This thing is complicated
cdef extern from "libacars/asn1/asn_application.h":
    ctypedef struct asn_TYPE_descriptor_t:
        pass

cdef extern from "libacars/cpdlc.h":
    cdef clibacars.la_type_descriptor la_DEF_cpdlc_message

    ctypedef struct la_cpdlc_msg:
        asn_TYPE_descriptor_t *asn_type;
        void *data;
        bint err;