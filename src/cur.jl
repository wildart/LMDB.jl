"""
A handle to a cursor structure for navigating through a database.
"""
type Cursor
    handle::Ptr{Void}
    Cursor(cur::Ptr{Void}) = new(cur)
end

"Check if cursor is open"
isopen(cur::Cursor) = cur.handle != C_NULL

"Create a cursor"
function open(txn::Transaction, dbi::DBI)
    ret = Cint[0]
    handle = ccall( (:mdb_cursor_start, liblmdbjl), Ptr{Void},
                    (Ptr{Void}, Cuint, Ptr{Cint}),
                    txn.handle, dbi.handle, ret)
    (ret[1] != 0) && error(errormsg(ret))
    return Cursor(handle)
end

"Close a cursor"
function close(cur::Cursor)
    if cur.handle == C_NULL
        warn("Cursor is already closed")
    end
    ccall( (:mdb_cursor_close, liblmdbjl), Void, (Ptr{Void},), cur.handle)
    cur.handle = C_NULL
end

"Renew a cursor"
function renew(txn::Transaction, cur::Cursor)
    ret = ccall( (:mdb_cursor_renew, liblmdbjl), Cint, (Ptr{Void}, Ptr{Void}), txn.handle, cur.handle)
    (ret != 0) && error(errormsg(ret))
    return ret::Cint
end

"Delete current key/data pair"
function delete!(cur::Cursor; flags::Uint32 = 0x00000000)
    ret = ccall( (:mdb_cursor_del, liblmdbjl), Cint, (Ptr{Void}, Cuint), cur.handle, flags)
    (ret != 0) && error(errormsg(ret))
    return ret::Cint
end

"Return count of duplicates for current key"
function count(cur::Cursor)
    countp = Csize_t[0]
    ret = ccall( (:mdb_cursor_count, liblmdbjl), Cint, (Ptr{Void}, Csize_t), cur.handle, countp)
    (ret != 0) && error(errormsg(ret))
    return countp[1]
end

"Store items into a database"
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
    (ret != 0) && error(errormsg(ret))
    return ret
end

#int  mdb_cursor_get(MDB_cursor *cursor, MDB_val *key, MDB_val *data, MDB_cursor_op op);
"Get items from a database"
function get{T}(txn::Transaction, dbi::Cursor, key, ::Type{T})
    # Setup parameters
    keysize = Csize_t[uint32(sizeof(key))]
    valsize = Csize_t[0]
    if isa(key, Number)
        keyval=typeof(key)[key]
    else
        keyval=pointer(key)
    end
    ret = Cint[0]

    # Get value
    val = ccall( (:mdb_cursor_kv_get, LMDB.liblmdbjl), Ptr{Cuchar},
                 (Ptr{Void}, Cuint, Csize_t, Ptr{Void}, Ptr{Csize_t}, Ptr{Cint}),
                 txn.handle, dbi.handle, keysize[1], keyval, valsize, ret)
    (ret[1] != 0) && error(errormsg(ret))

    # Convert to proper type
    value = pointer_to_array(val, (valsize[1],), true)
    if T <: String
        value = bytestring(value)
    else
        value = reinterpret(T, value)
    end
    return length(value) == 1 ? value[1] : value
end