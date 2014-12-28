@doc "Store items into a database."->
function put!(txn::Transaction, dbi::DBI, key, val; flags::Uint32 = 0x00000000)
    keysize = Csize_t[val_size(key)]
    valsize = Csize_t[val_size(val)]

    ret = ccall( (:mdb_kv_put, liblmdbwrapper), Cint,
                 (Ptr{Void}, Cuint, Csize_t, Ptr{Void}, Csize_t, Ptr{Void}, Cuint),
                 txn.handle, dbi.handle, keysize[1], &key, valsize[1], &val, flags)
    if ret != 0
        warn(errormsg(ret))
    end
    return ret
end

@doc "Get items from a database."->
function get(txn::Transaction, dbi::DBI, key)
    keysize = Csize_t[val_size(key)]
    valsize = Csize_t[0]
    rc = Cint[0]
    val = ccall( (:mdb_kv_get, liblmdbwrapper), Ptr{Void},
                 (Ptr{Void}, Cuint, Csize_t, Ptr{Void}, Ptr{Csize_t}, Ptr{Cint}),
                 txn.handle, dbi.handle, keysize[1], &key, valsize, rc)
    ret = rc[1]
    if ret != 0
        warn(errormsg(ret))
    end
    value = pointer_to_array(val, (valsize[1],), true)
    return value
end