# clist.pxd
cdef extern from "libacars/list.h":
    ctypedef struct la_list:
        void *data
        la_list *next

    la_list *la_list_append(la_list *l, void *data);
    void *la_list_free(la_list *l)