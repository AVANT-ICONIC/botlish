/* C-HEADER-ARCHAEOLOGY.md unsupported corpus: tcl
 * category:    ABI-INFORMATION-REQUIRED
 * shape:       union embedded by value
 * occurrences: tcl-embed 2, tcl-stubs 2, tcl-notommath 2
 * examples:    Tcl_Obj, Tcl_HashEntry
 * first seen:  tcl-embed (revision 6230a12b3bf6f7d8128f6ef14b0a3650a9d479e0), generic/tcl.h:743
 * reason:      a union field: overlapping storage the current layout cannot describe
 * expect:      struct Tcl_Obj
 */
typedef long unsigned int size_t;
typedef long int ptrdiff_t;
typedef long long Tcl_WideInt;
typedef ptrdiff_t Tcl_Size;
typedef struct Tcl_Interp Tcl_Interp;
typedef void (Tcl_DupInternalRepProc) (struct Tcl_Obj *srcPtr, struct Tcl_Obj *dupPtr);
typedef void (Tcl_FreeInternalRepProc) (struct Tcl_Obj *objPtr);
typedef int (Tcl_SetFromAnyProc) (Tcl_Interp *interp, struct Tcl_Obj *objPtr);
typedef void (Tcl_UpdateStringProc) (struct Tcl_Obj *objPtr);
typedef Tcl_Size(Tcl_ObjTypeLengthProc) (struct Tcl_Obj *listPtr);
typedef int (Tcl_ObjTypeIndexProc) (Tcl_Interp *interp, struct Tcl_Obj *listPtr, Tcl_Size index, struct Tcl_Obj **elemObj);
typedef int (Tcl_ObjTypeSliceProc) (Tcl_Interp *interp, struct Tcl_Obj *listPtr, Tcl_Size fromIdx, Tcl_Size toIdx, struct Tcl_Obj **newObjPtr);
typedef int (Tcl_ObjTypeReverseProc) (Tcl_Interp *interp, struct Tcl_Obj *listPtr, struct Tcl_Obj **newObjPtr);
typedef int (Tcl_ObjTypeGetElements) (Tcl_Interp *interp, struct Tcl_Obj *listPtr, Tcl_Size *objcptr, struct Tcl_Obj ***objvptr);
typedef struct Tcl_Obj * (Tcl_ObjTypeSetElement) (Tcl_Interp *interp, struct Tcl_Obj *listPtr, Tcl_Size indexCount, struct Tcl_Obj *const indexArray[], struct Tcl_Obj *valueObj);
typedef int (Tcl_ObjTypeReplaceProc) (Tcl_Interp *interp, struct Tcl_Obj *listObj, Tcl_Size first, Tcl_Size numToDelete, Tcl_Size numToInsert, struct Tcl_Obj *const insertObjs[]);
typedef int (Tcl_ObjTypeInOperatorProc) (Tcl_Interp *interp, struct Tcl_Obj *valueObj, struct Tcl_Obj *listObj, int *boolResult);
typedef struct Tcl_ObjType { const char *name; Tcl_FreeInternalRepProc *freeIntRepProc; Tcl_DupInternalRepProc *dupIntRepProc; Tcl_UpdateStringProc *updateStringProc; Tcl_SetFromAnyProc *setFromAnyProc; size_t version; Tcl_ObjTypeLengthProc *lengthProc; Tcl_ObjTypeIndexProc *indexProc; Tcl_ObjTypeSliceProc *sliceProc; Tcl_ObjTypeReverseProc *reverseProc; Tcl_ObjTypeGetElements *getElementsProc; Tcl_ObjTypeSetElement *setElementProc; Tcl_ObjTypeReplaceProc *replaceProc; Tcl_ObjTypeInOperatorProc *inOperProc; } Tcl_ObjType;
typedef union Tcl_ObjInternalRep { long longValue; double doubleValue; void *otherValuePtr; Tcl_WideInt wideValue; struct { void *ptr1; void *ptr2; } twoPtrValue; struct { void *ptr; unsigned long value; } ptrAndLongRep; struct { void *ptr; Tcl_Size size; } ptrAndSize; } Tcl_ObjInternalRep;
struct Tcl_Obj { Tcl_Size refCount; char *bytes; Tcl_Size length; const Tcl_ObjType *typePtr; Tcl_ObjInternalRep internalRep; };
