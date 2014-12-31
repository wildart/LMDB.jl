@doc "Store items into a database."->
function insert!(txn::Transaction, dbi::DBI, key, val; flags::Uint32 = 0x00000000)
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

    ret = ccall( (:mdb_kv_put, liblmdbjl), Cint,
                 (Ptr{Void}, Cuint, Csize_t, Ptr{Void}, Csize_t, Ptr{Void}, Cuint),
                 txn.handle, dbi.handle, keysize[1], keyval, valsize[1], valval, flags)
    if ret != 0
        warn(errormsg(ret))
    end
    return ret
end

@doc "Get items from a database."->
function get{T}(txn::Transaction, dbi::DBI, key, ::Type{T})
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
    val = ccall( (:mdb_kv_get, LMDB.liblmdbjl), Ptr{Cuchar},
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