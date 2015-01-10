"A handle for a cursor in the DB environment."
type Cursor
    handle::Ptr{Void}
    Cursor(cur::Ptr{Void}) = new(cur)
end

@doc "Check if cursor is open." ->
isopen(cur::Cursor) = cur.handle != C_NULL

@doc "Create a cursor."->
function open(txn::Transaction, dbi::DBI)
    ret = Cint[0]
    handle = ccall( (:mdb_cursor_start, liblmdbjl), Ptr{Void},
                    (Ptr{Void}, Cuint, Ptr{Cint}),
                    txn.handle, dbi.handle, ret)
    if ret[1] != 0
        warn(errormsg(ret))
    end
    return Cursor(handle)
end

@doc "Close a cursor." ->
function close(cur::Cursor)
    if cur.handle == C_NULL
        error("Cursor is already closed")
    end
    ccall( (:mdb_cursor_close, liblmdbjl), Void, (Ptr{Void},), cur.handle)
    cur.handle = C_NULL
end

@doc "Renew a cursor."->
function renew(txn::Transaction, cur::Cursor)
    ret = ccall( (:mdb_cursor_renew, liblmdbjl), Cint, (Ptr{Void}, Ptr{Void}), txn.handle, cur.handle)
    if ret != 0
        warn(errormsg(ret))
    end
    return ret::Cint
end

@doc "Delete current key/data pair"->
function delete!(cur::Cursor; flags::Uint32 = 0x00000000)
    ret = ccall( (:mdb_cursor_del, liblmdbjl), Cint, (Ptr{Void}, Cuint), cur.handle, flags)
    if ret != 0
        warn(errormsg(ret))
    end
    return ret::Cint
end

@doc "Return count of duplicates for current key"->
function count(cur::Cursor)
    countp = Csize_t[0]
    ret = ccall( (:mdb_cursor_count, liblmdbjl), Cint, (Ptr{Void}, Csize_t), cur.handle, countp)
    if ret != 0
        warn(errormsg(ret))
    end
    return countp[1]
end

@doc "Store items into a database."->
function insert!(cur::Cursor, key, val; flags::Uint32 = EMPTY)
    keysize = Csize_t[uint32(sizeof(key))]
    valsize = Csize_t[uint32(sizeof(val))]

    if isa(key, Number)
        keyval=typeof(key)[key]
    else
        keyval=pointer(key)
    end

    if isa(val, Number)
        valval=typeof(val)[val]
    else
        valval=pointer(val)
    end

    ret = ccall( (:mdb_cursor_kv_put, liblmdbjl), Cint,
                 (Ptr{Void}, Csize_t, Ptr{Void}, Csize_t, Ptr{Void}, Cuint),
                 cur.handle, keysize[1], keyval, valsize[1], valval, flags)
    if ret != 0
        warn(errormsg(ret))
    end
    return ret
end

#int  mdb_cursor_get(MDB_cursor *cursor, MDB_val *key, MDB_val *data, MDB_cursor_op op);
@doc "Get items from a database."->
function get{T}(txn::Transaction, dbi::Cursor, key, ::Type{T})
    # Setup parameters
    keysize = Csize_t[uint32(sizeof(key))]
    valsize = Csize_t[0]
    if isa(key, Number)
        keyval=typeof(key)[key]
    else
        keyval=pointer(key)
    end
    rc = Cint[0]

    # Get value
    val = ccall( (:mdb_cursor_kv_get, LMDB.liblmdbjl), Ptr{Cuchar},
                 (Ptr{Void}, Cuint, Csize_t, Ptr{Void}, Ptr{Csize_t}, Ptr{Cint}),
                 txn.handle, dbi.handle, keysize[1], keyval, valsize, rc)
    ret = rc[1]
    if ret != 0
        warn(errormsg(ret))
    end

    # Convert to proper type
    value = pointer_to_array(val, (valsize[1],), true)
    if T <: String
        value = bytestring(value)
    else
        value = reinterpret(T, value)
    end
    return length(value) == 1 ? value[1] : value
end