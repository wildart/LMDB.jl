"""
A handle to a cursor structure for navigating through a database.
"""
mutable struct Cursor
    handle::Ptr{Nothing}
    Cursor(cur::Ptr{Nothing}) = new(cur)
end

"Check if cursor is open"
isopen(cur::Cursor) = cur.handle != C_NULL

"Create a cursor"
function open(txn::Transaction, dbi::DBI)
    cur_ptr_ref = Ref{Ptr{Nothing}}(C_NULL)
    ret = ccall((:mdb_cursor_open, liblmdb), Cint,
                 (Ptr{Nothing}, Cuint, Ptr{Ptr{Nothing}}),
                  txn.handle, dbi.handle, cur_ptr_ref)
    (ret != 0) && throw(LMDBError(ret))
    return Cursor(cur_ptr_ref[])
end

"Wrapper of Cursor `open` for `do` construct"
function open(f::Function, txn::Transaction, dbi::DBI)
    cur = open(txn, dbi)
    try
        f(cur)
    finally
        close(cur)
    end
end

"Close a cursor"
function close(cur::Cursor)
    if cur.handle == C_NULL
        warn("Cursor is already closed")
    end
    ccall((:mdb_cursor_close, liblmdb), Nothing, (Ptr{Nothing},), cur.handle)
    cur.handle = C_NULL
    return
end

"Renew a cursor"
function renew(txn::Transaction, cur::Cursor)
    ret = ccall((:mdb_cursor_renew, liblmdb), Cint,
                 (Ptr{Nothing}, Ptr{Nothing}), txn.handle, cur.handle)
    (ret != 0) && throw(LMDBError(ret))
    return ret
end

"Return the cursor's transaction"
function transaction(cur::Cursor)
    txn_ptr = ccall((:mdb_cursor_txn, liblmdb), Ptr{Nothing}, (Ptr{Nothing},), cur.handle)
    (txn_ptr == C_NULL) && return nothing
    return Transaction(txn_ptr)
end

"Return the cursor's database"
function database(cur::Cursor)
    dbi = ccall((:mdb_cursor_dbi, liblmdb), Cuint, (Ptr{Nothing},), cur.handle)
    (dbi == 0) && return nothing
    return DBI(dbi, "")
end

"Type to implement the Iterator interface"
mutable struct KeyIterator
   cur::Cursor
   keytype::Type
end

"Iterate over keys"
function Base.iterate(iter::KeyIterator, first=true)
    # Setup parameters
    mdb_key_ref = Ref(MDBValue())
    mdb_val_ref = Ref(MDBValue())
    NOTFOUND::Cint = -30798

    cursor_op = first ? FIRST : NEXT
    ret = ccall( (:mdb_cursor_get, liblmdb), Cint,
               (Ptr{Nothing}, Ptr{MDBValue}, Ptr{MDBValue}, Cint),
                iter.cur.handle, mdb_key_ref, mdb_val_ref, Cint(cursor_op))

    if ret == 0
        # Convert to proper type
        return (convert(iter.keytype, mdb_key_ref), false)
    elseif ret == NOTFOUND
        return nothing
    else
        throw(LMDBError(ret))
    end
end

Base.IteratorSize(::KeyIterator) = Base.SizeUnknown()
Base.eltype(iter::KeyIterator) = iter.keytype

"Return iterator over keys of uniform, specified type"
function keys(cur::Cursor, keytype::Type{T}) where T
    return  KeyIterator(cur, keytype)
end

"""Retrieve by cursor.

This function retrieves key/data pairs from the database.
"""
function get(cur::Cursor, key, ::Type{T}, op::CursorOps=SET_KEY) where T
    # Setup parameters
    k = isbitstype(typeof(key)) ? [key] :  key
    mdb_key_ref = Ref(MDBValue(k))
    mdb_val_ref = Ref(MDBValue())

    # Get value
    ret = ccall( (:mdb_cursor_get, liblmdb), Cint,
                  (Ptr{Nothing}, Ptr{MDBValue}, Ptr{MDBValue}, Cint),
                   cur.handle, mdb_key_ref, mdb_val_ref, Cint(op))
    (ret != 0) && throw(LMDBError(ret))

    # Convert to proper type
    return convert(T, mdb_val_ref)
end

"""Store by cursor.

This function stores key/data pairs into the database. The cursor is positioned at the new item, or on failure usually near it.
"""
function put!(cur::Cursor, key, val; flags::Cuint = zero(Cuint))
    k = isbitstype(typeof(key)) ? [key] :  key
    mdb_key_ref = Ref(MDBValue(k))
    v = isbitstype(typeof(val)) ? [val] :  val
    mdb_val_ref = Ref(MDBValue(v))

    ret = ccall((:mdb_cursor_put, liblmdb), Cint,
                 (Ptr{Nothing}, Ptr{MDBValue}, Ptr{MDBValue}, Cuint),
                  cur.handle, mdb_key_ref, mdb_val_ref, flags)

    (ret != 0) && throw(LMDBError(ret))
    return ret
end

"Delete current key/data pair to which the cursor refers"
function delete!(cur::Cursor; flags::Cuint = zero(Cuint))
    ret = ccall((:mdb_cursor_del, liblmdb), Cint,
                 (Ptr{Nothing}, Cuint), cur.handle, flags)
    (ret != 0) && throw(LMDBError(ret))
    return ret
end

"Return count of duplicates for current key"
function count(cur::Cursor)
    countp = Csize_t[0]
    ret = ccall( (:mdb_cursor_count, liblmdb), Cint,
                  (Ptr{Nothing}, Csize_t), cur.handle, countp)
    (ret != 0) && throw(LMDBError(ret))
    return Int(countp[1])
end
