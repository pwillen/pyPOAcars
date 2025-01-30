from enum import Enum

cimport clibacars
cimport cvstring
cimport clist
cimport creassembly
cimport cacars
cimport carinc
cimport cadsc
cimport ccpdlc

# from Cython.Utility.MemoryView import free
# from Cython.Includes.libc.stdlib import free
# from Cython.Includes.libc.stdlib import malloc
from libc.stdint cimport uint8_t
# TODO Need to Figure out how to import malloc and free
from cython.cimports.libc.stdlib import malloc, free

from cpython cimport bool
# from libc.stdlib import malloc, free

# TODO NEED to convert other structs to python classes

cdef class PyVoid:
    """
    A Python wrapper for a C struct.
    """

    cdef void *_ptr
    cdef bint ptr_owner

    def __cinit__(self):
        self._ptr = NULL

    def __dealloc__(self):
        if self._ptr is not NULL and self.ptr_owner is True:
            pass

    @staticmethod
    cdef PyVoid from_ptr(void *_ptr, bint owner=False):
        """
        Factory function to create python objects from
        given pointer.
        """
        # Fast call to __new__() that bypasses the __init__() constructor.
        cdef PyVoid wrapper = PyVoid.__new__(PyVoid)
        wrapper._ptr = _ptr
        wrapper.ptr_owner = owner
        return wrapper


cdef class PyList:
    """
    A Python wrapper for the la_list pointer
    """

    # Define as la_list since list is a type and might be confusing
    cdef clist.la_list *_c_la_list
    cdef bint _c_la_list_owner

    def __cinit__(self):
        self._c_la_list_owner = False
        self._c_la_list = clist.la_list_append(NULL, NULL)
        if self._c_la_list is NULL:
            raise MemoryError()


    def __dealloc__(self):
        if self._c_la_list is not NULL and self._c_la_list_owner is True:
            clist.la_list_free(self._c_la_list)

    def __init__(self):
        # Prevent accidental instantiation from normal Python code
        # since we cannot pass a struct pointer into a Python constructor.
        raise TypeError("This class cannot be instantiated directly.")

    @property
    def data(self):
        # TODO data isn't always adsc_tag_t so need to find out what to cast to
        return PyAdscTagT.from_ptr(<cadsc.la_adsc_tag_t *>self._c_la_list.data) if self._c_la_list is not NULL else None

    @property
    def next(self):
        return PyList.from_ptr(self._c_la_list.next) if self._c_la_list is not NULL else None

    @staticmethod
    cdef PyList from_ptr(clist.la_list *_c_la_list, bint owner=False):
        """
        Factory function to create PyList objects from
        given _c_la_list pointer.
        """
        # Fast call to __new__() that bypasses the __init__() constructor.
        cdef PyList wrapper = PyList.__new__(PyList)
        wrapper._c_la_list = _c_la_list
        wrapper._c_la_list_owner = owner
        return wrapper

    @staticmethod
    cdef PyList new_struct():
        """
        Factory function to create PyList objects with
        newly allocated _c_la_list pointer.
        """
        cdef clist.la_list *_c_la_list = <clist.la_list *> malloc(sizeof(clist.la_list))

        if _c_la_list is NULL:
            raise MemoryError
        _c_la_list.data = NULL
        _c_la_list.next = NULL
        # Warning raised for bool instead bint
        # I think this is correct though
        return PyList.from_ptr(_c_la_list, owner=True)


cdef class PyVString:
    """
    A Python wrapper for the la_vstring pointer
    """

    cdef cvstring.la_vstring *_c_vstring
    cdef bint _c_vstring_owner

    def __cinit__(self):
        self._c_vstring_owner = False
        self._c_vstring = cvstring.la_vstring_new()
        if self._c_vstring is NULL:
            raise MemoryError()

    def __dealloc__(self):
        if self._c_vstring is not NULL and self._c_vstring_owner is True:
            cvstring.la_vstring_destroy(self._c_vstring, destroy_buffer=True)

    def __init__(self):
        # Prevent accidental instantiation from normal Python code
        # since we cannot pass a struct pointer into a Python constructor.
        raise TypeError("This class cannot be instantiated directly.")

    # Extension class properties
    @property
    def str_(self):
        return self._c_vstring.str if self._c_vstring is not NULL else None

    @staticmethod
    cdef PyVString from_ptr(cvstring.la_vstring *_c_vstring, bint owner=False):
        """
        Factory function to create PyProtoNode objects from
        given _c_vstring pointer.
        """
        # Fast call to __new__() that bypasses the __init__() constructor.
        cdef PyVString wrapper = PyVString.__new__(PyVString)
        wrapper._c_vstring = _c_vstring
        wrapper._c_vstring_owner = owner
        return wrapper

    @staticmethod
    cdef PyVString new_struct():
        """
        Factory function to create PyVString objects with
        newly allocated _c_vstring pointer.
        """
        cdef cvstring.la_vstring *_c_vstring = <cvstring.la_vstring *> malloc(sizeof(cvstring.la_vstring))

        if _c_vstring is NULL:
            raise MemoryError
        _c_vstring.str = NULL
        # Warning raised for bool instead bint
        # I think this is correct though
        return PyVString.from_ptr(_c_vstring, owner=True)


cdef class PyTypeDescriptor:
    """
    A Python wrapper for the la_type_descriptor pointer.
    """

    cdef clibacars.la_type_descriptor *_c_type_descriptor
    cdef bint _c_type_descriptor_owner

    def __cinit__(self):
        self._c_type_descriptor_owner = False
        self._c_type_descriptor = NULL

    def __dealloc__(self):
        if self._c_type_descriptor is not NULL and self._c_type_descriptor_owner is True:
            free(self._c_type_descriptor)

    def __init__(self):
        # Prevent accidental instantiation from normal Python code
        # since we cannot pass a struct pointer into a Python constructor.
        raise TypeError("This class cannot be instantiated directly.")

    @property
    def json_key(self):
        return self._c_type_descriptor.json_key if self._c_type_descriptor is not NULL else None

    @staticmethod
    cdef PyTypeDescriptor from_ptr(clibacars.la_type_descriptor *_c_type_descriptor, bint owner=False):
        """
        Factory function to create PyTypeDescriptor objects from
        given _c_type_descriptor pointer.
        """
        # Fast call to __new__() that bypasses the __init__() constructor.
        cdef PyTypeDescriptor wrapper = PyTypeDescriptor.__new__(PyTypeDescriptor)
        wrapper._c_type_descriptor = _c_type_descriptor
        wrapper._c_type_descriptor_owner = owner
        return wrapper

    @staticmethod
    cdef PyTypeDescriptor new_struct():
        """
        Factory function to create PyProtoNode objects with
        newly allocated _c_proto_node pointer.
        """
        cdef clibacars.la_type_descriptor *_c_type_descriptor = <clibacars.la_type_descriptor *> malloc(sizeof(clibacars.la_type_descriptor))

        if _c_type_descriptor is NULL:
            raise MemoryError
        return PyTypeDescriptor.from_ptr(_c_type_descriptor, owner=True)


cdef class PyAcarsMessage:
    """
    A Python wrapper for the la_acars_msg pointer
    """

    cdef cacars.la_acars_msg *_c_acars_msg
    cdef bint _c_acars_msg_owner

    def __cinit__(self):
        self._c_acars_msg_owner = False
        self._c_acars_msg = NULL

    def __dealloc__(self):
        if self._c_acars_msg is not NULL and self._c_acars_msg_owner is True:
            free(self._c_acars_msg)

    def __init__(self):
        # Prevent accidental instantiation from normal Python code
        # since we cannot pass a struct pointer into a Python constructor.
        raise TypeError("This class cannot be instantiated directly.")

    @property
    def crc_ok(self):
        return self._c_acars_msg.crc_ok if self._c_acars_msg is not NULL else False

    @property
    def err(self):
        return self._c_acars_msg.err if self._c_acars_msg is not NULL else True

    @property
    def final_block(self):
        return self._c_acars_msg.final_block if self._c_acars_msg is not NULL else False

    @property
    def mode(self):
        return self._c_acars_msg.mode if self._c_acars_msg is not NULL else None

    @property
    def reg(self):
        return self._c_acars_msg.reg if self._c_acars_msg is not NULL else None

    @property
    def ack(self):
        return self._c_acars_msg.ack if self._c_acars_msg is not NULL else None

    @property
    def label(self):
        return self._c_acars_msg.label if self._c_acars_msg is not NULL else None

    @property
    def sublabel(self):
        return self._c_acars_msg.sublabel if self._c_acars_msg is not NULL else None

    @property
    def mfi(self):
        return self._c_acars_msg.mfi if self._c_acars_msg is not NULL else None

    @property
    def block_id(self):
        return self._c_acars_msg.block_id if self._c_acars_msg is not NULL else None

    @property
    def msg_num(self):
        return self._c_acars_msg.msg_num if self._c_acars_msg is not NULL else None

    @property
    def msg_num_seq(self):
        return self._c_acars_msg.msg_num_seq if self._c_acars_msg is not NULL else None

    @property
    def flight_id(self):
        return self._c_acars_msg.flight_id if self._c_acars_msg is not NULL else None

    @property
    def reasm_status(self):
        return self._c_acars_msg.reasm_status if self._c_acars_msg is not NULL else None

    @property
    def txt(self):
        return self._c_acars_msg.txt if self._c_acars_msg is not NULL else None

    @staticmethod
    cdef PyAcarsMessage from_ptr(cacars.la_acars_msg *_c_acars_msg, bint owner=False):
        """
        Factory function to create PyAcarsMessage objects from
        given _c_acars_msg pointer.
        """
        # Fast call to __new__() that bypasses the __init__() constructor.
        cdef PyAcarsMessage wrapper = PyAcarsMessage.__new__(PyAcarsMessage)
        wrapper._c_acars_msg = _c_acars_msg
        wrapper._c_acars_msg_owner = owner
        return wrapper

    @staticmethod
    cdef PyAcarsMessage new_struct():
        """
        Factory function to create PyAcarsMessage objects with
        newly allocated _c_acars_message pointer.
        """
        cdef cacars.la_acars_msg *_c_acars_msg = <cacars.la_acars_msg *> malloc(
            sizeof(cacars.la_acars_msg))

        if _c_acars_msg is NULL:
            raise MemoryError
        _c_acars_msg.crc_ok = True
        _c_acars_msg.err = False
        _c_acars_msg.final_block = True
        # TODO Don't konw how to assign to char
        # _c_acars_msg.mode = <char>
        # _c_acars_msg.reg = <char [8]>
        # _c_acars_msg.ack = <char>
        # _c_acars_msg.label = <char [3]>
        # _c_acars_msg.sublabel = <char [3]>
        # _c_acars_msg.mfi = <char [3]>
        # _c_acars_msg.block_id = <char>
        # _c_acars_msg.msg_num = <char [4]>
        # _c_acars_msg.msg_num_seq = <char>
        # _c_acars_msg.flight_id = <char [7]>
        _c_acars_msg.reasm_status = creassembly.LA_REASM_UNKNOWN
        _c_acars_msg.txt = NULL
        return PyAcarsMessage.from_ptr(_c_acars_msg, owner=True)


cdef class PyArincMessage:
    """
    A Python wrapper for the la_arinc_msg pointer
    """

    cdef carinc.la_arinc_msg *_c_arinc_msg
    cdef bint _c_arinc_msg_owner

    def __cinit__(self):
        self._c_arinc_msg_owner = False
        self._c_arinc_msg = NULL

    def __dealloc__(self):
        if self._c_arinc_msg is not NULL and self._c_arinc_msg_owner is True:
            free(self._c_arinc_msg)

    def __init__(self):
        # Prevent accidental instantiation from normal Python code
        # since we cannot pass a struct pointer into a Python constructor.
        raise TypeError("This class cannot be instantiated directly.")

    @property
    def gs_addr(self):
        return self._c_arinc_msg.gs_addr if self._c_arinc_msg is not NULL else None

    @property
    def air_reg(self):
        return self._c_arinc_msg.air_reg if self._c_arinc_msg is not NULL else None

    @property
    def imi(self):
        return self._c_arinc_msg.imi if self._c_arinc_msg is not NULL else None

    @property
    def crc_ok(self):
        return self._c_arinc_msg.crc_ok if self._c_arinc_msg is not NULL else False

    @staticmethod
    cdef PyArincMessage from_ptr(carinc.la_arinc_msg *_c_arinc_msg, bint owner=False):
        """
        Factory function to create PyArincMessage objects from
        given _c_arinc_msg pointer.
        """
        # Fast call to __new__() that bypasses the __init__() constructor.
        cdef PyArincMessage wrapper = PyArincMessage.__new__(PyArincMessage)
        wrapper._c_arinc_msg = _c_arinc_msg
        wrapper._c_arinc_msg_owner = owner
        return wrapper

    @staticmethod
    cdef PyArincMessage new_struct():
        """
        Factory function to create PyArincMessage objects with
        newly allocated _c_arinc_message pointer.
        """
        cdef carinc.la_arinc_msg *_c_arinc_msg = <carinc.la_arinc_msg *> malloc(
            sizeof(carinc.la_arinc_msg))

        if _c_arinc_msg is NULL:
            raise MemoryError
        _c_arinc_msg.imi = carinc.ARINC_MSG_UNKNOWN
        _c_arinc_msg.crc_ok = True
        return PyArincMessage.from_ptr(_c_arinc_msg, owner=True)


cdef class PyAdscTagT:
    """
    A python wrapper for the la_adsc_tag_t pointer
    """
    cdef cadsc.la_adsc_tag_t *_c_adsc_tag_t
    cdef bint _c_adsc_tag_t_owner

    def __cinit__(self):
        self._c_adsc_tag_t_owner = False
        self._c_adsc_tag_t = NULL

    def __dealloc__(self):
        if self._c_adsc_tag_t is not NULL and self._c_adsc_tag_t_owner is True:
            free(self._c_adsc_tag_t)

    def __init__(self):
        # Prevent accidental instantiation from normal Python code
        # since we cannot pass a struct pointer into a Python constructor.
        raise TypeError("This class cannot be instantiated directly.")

    @staticmethod
    cdef PyAdscTagT from_ptr(cadsc.la_adsc_tag_t *_c_adsc_tag_t, bint owner=False):
        """
        Factory function to create PyAdscTagT objects from
        given _c_adsc_tag_t pointer.
        """
        # Fast call to __new__() that bypasses the __init__() constructor.
        cdef PyAdscTagT wrapper = PyAdscTagT.__new__(PyAdscTagT)
        wrapper._c_adsc_tag_t = _c_adsc_tag_t
        wrapper._c_adsc_tag_t_owner = owner
        return wrapper

    @staticmethod
    cdef PyAdscTagT new_struct():
        """
        Factory function to create PyAdscTagT objects with
        newly allocated _c_adsdc_tag_t pointer.
        """
        cdef cadsc.la_adsc_tag_t *_c_adsc_tag_t = <cadsc.la_adsc_tag_t *> malloc(
            sizeof(cadsc.la_adsc_tag_t))

        if _c_adsc_tag_t is NULL:
            raise MemoryError
        return PyAdscTagT.from_ptr(_c_adsc_tag_t, owner=True)


cdef class PyAdscMessageT:
    """
    A python wrapper for the la_adsc_msg_t pointer
    """
    cdef cadsc.la_adsc_msg_t *_c_adsc_msg_t
    cdef bint _c_adsc_msg_t_owner

    def __cinit__(self):
        self._c_adsc_msg_t_owner = False
        self._c_adsc_msg_t = NULL

    def __dealloc__(self):
        if self._c_adsc_msg_t is not NULL and self._c_adsc_msg_t_owner is True:
            free(self._c_adsc_msg_t)

    def __init__(self):
        # Prevent accidental instantiation from normal Python code
        # since we cannot pass a struct pointer into a Python constructor.
        raise TypeError("This class cannot be instantiated directly.")

    @property
    def err(self):
        return self._c_adsc_msg_t.err if self._c_adsc_msg_t is not NULL else True

    @property
    def tag_list(self):
        return PyList.from_ptr(self._c_adsc_msg_t.tag_list) if self._c_adsc_msg_t is not NULL else None

    @staticmethod
    cdef PyAdscMessageT from_ptr(cadsc.la_adsc_msg_t *_c_adsc_msg_t, bint owner=False):
        """
        Factory function to create PyAdscMessageT objects from
        given _c_adsc_msg_t pointer.
        """
        # Fast call to __new__() that bypasses the __init__() constructor.
        cdef PyAdscMessageT wrapper = PyAdscMessageT.__new__(PyAdscMessageT)
        wrapper._c_adsc_msg_t = _c_adsc_msg_t
        wrapper._c_adsc_msg_t_owner = owner
        return wrapper

    @staticmethod
    cdef PyAdscMessageT new_struct():
        """
        Factory function to create PyAdscMessageT objects with
        newly allocated _c_adsdc_message_t pointer.
        """
        cdef cadsc.la_adsc_msg_t *_c_adsc_msg_t = <cadsc.la_adsc_msg_t *> malloc(
            sizeof(cadsc.la_adsc_msg_t))

        if _c_adsc_msg_t is NULL:
            raise MemoryError
        return PyAdscMessageT.from_ptr(_c_adsc_msg_t, owner=True)


cdef class PyCpdlcMessage:
    """
    A python wrapper for the la_cpdlc_msg pointer
    """

    cdef ccpdlc.la_cpdlc_msg *_c_cpdlc_msg
    cdef bint _c_cpdlc_msg_owner

    def __cinit__(self):
        self._c_cpdlc_msg_owner = False
        self._c_cpdlc_msg = NULL

    def __dealloc__(self):
        if self._c_cpdlc_msg is not NULL and self._c_cpdlc_msg_owner is True:
            free(self._c_cpdlc_msg)

    def __init__(self):
        # Prevent accidental instantiation from normal Python code
        # since we cannot pass a struct pointer into a Python constructor.
        raise TypeError("This class cannot be instantiated directly.")

    @property
    def err(self):
        return self._c_cpdlc_msg.err if self._c_cpdlc_msg is not NULL else True

    @staticmethod
    cdef PyCpdlcMessage from_ptr(ccpdlc.la_cpdlc_msg *_c_cpdlc_msg, bint owner=False):
        """
        Factory function to create PyCpdlcMessage objects from
        given _c_cpdlc_msg pointer.
        """
        # Fast call to __new__() that bypasses the __init__() constructor.
        cdef PyCpdlcMessage wrapper = PyCpdlcMessage.__new__(PyCpdlcMessage)
        wrapper._c_cpdlc_msg = _c_cpdlc_msg
        wrapper._c_cpdlc_msg_owner = owner
        return wrapper

    @staticmethod
    cdef PyCpdlcMessage new_struct():
        """
        Factory function to create PyCpdlcMessage objects with
        newly allocated _c_cpdlc_message pointer.
        """
        cdef ccpdlc.la_cpdlc_msg *_c_cpdlc_msg = <ccpdlc.la_cpdlc_msg *> malloc(
            sizeof(ccpdlc.la_cpdlc_msg))

        if _c_cpdlc_msg is NULL:
            raise MemoryError
        return PyCpdlcMessage.from_ptr(_c_cpdlc_msg, owner=True)


cdef class PyProtoNode:
    """
    A Python wrapper for the la_proto_node pointer.
    """

    cdef clibacars.la_proto_node *_c_proto_node
    cdef bint _c_proto_node_owner

    def __cinit__(self):
        self._c_proto_node_owner = False
        self._c_proto_node = clibacars.la_proto_node_new()
        if self._c_proto_node is NULL:
            raise MemoryError()

    def __dealloc__(self):
        if self._c_proto_node is not NULL and self._c_proto_node_owner is True:
            clibacars.la_proto_tree_destroy(self._c_proto_node)

    def __init__(self):
        # Prevent accidental instantiation from normal Python code
        # since we cannot pass a struct pointer into a Python constructor.
        raise TypeError("This class cannot be instantiated directly.")

    # Extension class properties
    @property
    def td(self):
        return PyTypeDescriptor.from_ptr(self._c_proto_node.td) if self._c_proto_node is not NULL else None

    @property
    def is_valid_acars(self):
        if self._c_proto_node is not NULL:
            # Check what type of message the node points to
            # Return message validators
            if self._c_proto_node.td == &cacars.la_DEF_acars_message:
                return self.data.crc_ok and not self.data.err
            elif self._c_proto_node.td == &carinc.la_DEF_arinc_message:
                return self.data.crc_ok
            elif self._c_proto_node.td == &cadsc.la_DEF_adsc_message:
                return not self.data.err
            elif self._c_proto_node.td == &ccpdlc.la_DEF_cpdlc_message:
                return not self.data.err
            else:
                return False

    @property
    def data(self):
        if self._c_proto_node is not NULL:
            # Check what type of message the node points to
            if self._c_proto_node.td == &cacars.la_DEF_acars_message:
                # Need to cast data to the right pointer
                # Then Use Extension class wrapper to return the object from a pointer
                return PyAcarsMessage.from_ptr(<cacars.la_acars_msg *>self._c_proto_node.data)
            elif self._c_proto_node.td == &carinc.la_DEF_arinc_message:
                return PyArincMessage.from_ptr(<carinc.la_arinc_msg *>self._c_proto_node.data)
            elif self._c_proto_node.td == &cadsc.la_DEF_adsc_message:
                # TODO Need to keep exposing bindings down the line
                return PyAdscMessageT.from_ptr(<cadsc.la_adsc_msg_t*>self._c_proto_node.data)
            elif self._c_proto_node.td == &ccpdlc.la_DEF_cpdlc_message:
                # TODO Need to keep exposing bindings down the line
                return PyCpdlcMessage.from_ptr(<ccpdlc.la_cpdlc_msg*>self._c_proto_node.data)
            else:
                return None
        else:
            return None


    @property
    def next(self):
        return PyProtoNode.from_ptr(self._c_proto_node.next) if self._c_proto_node is not NULL else None

    @staticmethod
    cdef PyProtoNode from_ptr(clibacars.la_proto_node *_c_proto_node, bint owner=False):
        """
        Factory function to create PyProtoNode objects from
        given _c_proto_node pointer.
        """
        # Fast call to __new__() that bypasses the __init__() constructor.
        cdef PyProtoNode wrapper = PyProtoNode.__new__(PyProtoNode)
        wrapper._c_proto_node = _c_proto_node
        wrapper._c_proto_node_owner = owner
        return wrapper

    @staticmethod
    cdef PyProtoNode new_struct():
        """
        Factory function to create PyProtoNode objects with
        newly allocated _c_proto_node
        """
        cdef clibacars.la_proto_node *_c_proto_node = <clibacars.la_proto_node *> malloc(sizeof(clibacars.la_proto_node))

        if _c_proto_node is NULL:
            raise MemoryError
        _c_proto_node.next = NULL
        return PyProtoNode.from_ptr(_c_proto_node, owner=True)


class FormatMode(Enum):
    JSON = 'json'
    TEXT = 'text'

class PyMsgDir(Enum):
    LA_MSG_DIR_UNKNOWN = clibacars.LA_MSG_DIR_UNKNOWN
    LA_MSG_DIR_GND2AIR = clibacars.LA_MSG_DIR_GND2AIR
    LA_MSG_DIR_AIR2GND = clibacars.LA_MSG_DIR_AIR2GND

class PyArincImi(Enum):
    ARINC_MSG_UNKNOWN = carinc.ARINC_MSG_UNKNOWN
    ARINC_MSG_CR1 = carinc.ARINC_MSG_CR1
    ARINC_MSG_CC1 = carinc.ARINC_MSG_CC1
    ARINC_MSG_DR1 = carinc.ARINC_MSG_DR1
    ARINC_MSG_AT1 = carinc.ARINC_MSG_AT1
    ARINC_MSG_ADS = carinc.ARINC_MSG_ADS
    ARINC_MSG_DIS = carinc.ARINC_MSG_DIS

# TODO
#  there is also la_acars_format... that might need to be defined later on, but proto_tree_format is better in most cases
#  there is also la_acars_parse_and_reassemble that might be useful but not what warrants reassembly yet
#  Most of the data is exposed in ProtoNode - More Complex messages need more work in the future
def parse_acars_message(uint8_t *buf, msg_dir: object = PyMsgDir.LA_MSG_DIR_UNKNOWN) -> PyProtoNode:
    """
    Parse an ACARS message

    :param buf: The byte buffer containing the ACARS message. It is a python object cast as a c uint8_t pointer.
    :param msg_dir: The direction of the ACARS message. It is a python enum. Default to Unknown
    :return: The parsed ACARS message in Extension class wrapper with pointer to c proto_node.
    """
    # Call the C function to parse the ACARS message
    # skip the first byte of the buffer and adjust length accordingly
    # Take the Enum value and cast it to c enum
    # Parse always returns a proto_node so shouldn't need to check for NULL
    c_node = cacars.la_acars_parse(buf + 1, len(buf) - 1, <clibacars.la_msg_dir>msg_dir.value)
    # Use Extension class wrapper to return the object from a pointer
    return PyProtoNode.from_ptr(c_node)

def parse_adsc_message(uint8_t *buf, msg_dir: object = PyMsgDir.LA_MSG_DIR_UNKNOWN, imi: object = PyArincImi.ARINC_MSG_UNKNOWN) -> PyProtoNode:
    """
    Parse an ADS-C message

    :param buf: The byte buffer containing the ADS-C message. It is a python object cast as a c uint8_t pointer.
    :param msg_dir: The direction of the ADS-C message. It is a python enum. Default to Unknown
    :param imi: The ARINC IMI of the ADS-C message. It is a python enum. Default to Unknown
    :return: The parsed ADS-C message in Extension class wrapper with pointer to c proto_node.
    """
    # Parse always returns a proto_node so shouldn't need to check for NULL
    c_node = cadsc.la_adsc_parse(buf, len(buf), <clibacars.la_msg_dir>msg_dir.value, <carinc.la_arinc_imi>imi.value)
    # Use Extension class wrapper to return the object from a pointer
    return PyProtoNode.from_ptr(c_node)

def format_proto_tree(node: PyProtoNode, mode: object) -> str:
    """
    Format a ProtoNode tree.

    :param node: Extension class wrapper with pointer to c proto_node.
    :param mode: Mode of format - TEXT or JSON.
    :return: Formatted ProtoNode tree as str.
    """

    if node._c_proto_node is NULL:
        return ""
    if mode == FormatMode.JSON:
        # Format the tree as JSON
        # Returns a c VString pointer
        c_serial = clibacars.la_proto_tree_format_json(NULL, node._c_proto_node)
    elif mode == FormatMode.TEXT:
        # Format the tree as TEXT
        # Returns a c VString pointer
        c_serial = clibacars.la_proto_tree_format_text(NULL, node._c_proto_node)
    # Check if the proto_tree_node was serializable
    if c_serial is NULL:
        return ""
    # Use Extension class wrapper to return the object from a pointer
    py_serial = PyVString.from_ptr(c_serial)
    if py_serial.str_ :
        return py_serial.str_.decode()
    else:
        return py_serial.str_

def extract_sublabel_and_mfi(char *label, char *txt, msg_dir: object = PyMsgDir.LA_MSG_DIR_UNKNOWN) -> int:
    """
    Extract the sublabel and MFI from an ACARS message.

    :param label: The ACARS label.
    :param txt: The ACARS message text.
    :return: Message text offset after sublabel and MFI.
    """
    # -1 is returned if offset is not found
    # Null parameters are pointers to sublabel and mfi that could be filled. I don't need them so I pass NULL
    return cacars.la_acars_extract_sublabel_and_mfi(label, <clibacars.la_msg_dir>msg_dir.value, txt, len(txt), NULL, NULL)

def parse_acars_apps(char *label, char *txt, msg_dir: object = PyMsgDir.LA_MSG_DIR_UNKNOWN) -> PyProtoNode:
    """
    Parse the ACARS message text using application determined by message label.

    :param label: The ACARS label that determines the application.
    :return: The ACARS message text.
    :return: The parsed ACARS app in Extension class wrapper with pointer to c proto_node.
    """
    # Parse always returns a proto_node so shouldn't need to check for NULL
    c_node = cacars.la_acars_decode_apps(label, txt, <clibacars.la_msg_dir>msg_dir.value)
    # Use Extension class wrapper to return the object from a pointer
    return PyProtoNode.from_ptr(c_node)