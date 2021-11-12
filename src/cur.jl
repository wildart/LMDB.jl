"""
A handle to a cursor structure for navigating through a database.
"""
mutable struct Cursor
    handle::Ptr{MDB_cursor}
end

"Check if cursor is open"
isopen(cur::Cursor) = cur.handle != C_NULL

"Create a cursor"
function open(txn::Transaction, dbi::DBI)
    cur_ptr_ref = Ref{Ptr{MDB_cursor}}(C_NULL)
    mdb_cursor_open(txn.handle, dbi.handle, cur_ptr_ref)
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
    _mdb_cursor_close(cur.handle)
    cur.handle = C_NULL
    return
end

"Renew a cursor"
function renew(txn::Transaction, cur::Cursor)
    mdb_cursor_renew(txn.handle, cur.handle)
end

"Return the cursor's transaction"
function transaction(cur::Cursor)
    txn_ptr = _mdb_cursor_txn(cur.handle)
    (txn_ptr == C_NULL) && return nothing
    return Transaction(txn_ptr)
end

"Return the cursor's database"
function database(cur::Cursor)
    dbi = _mdb_cursor_dbi(cur.handle)
    (dbi == 0) && return nothing
    return DBI(dbi, "")
end

"Type to implement the Iterator interface"
struct KeyIterator{T,S}
   cur::Cursor
   lb::MDB_val
   ub::S
end

testifstop(_, ::Nothing) = false
testifstop(newkey, ub) = ub(newkey)

"Iterate over keys"
function Base.iterate(iter::KeyIterator{T}, refs = nothing) where T
    # Setup parameters
    mdb_key_ref, mdb_val_ref, cursor_op = if refs === nothing
        op = iter.lb.mv_data == C_NULL ? MDB_FIRST : MDB_SET_RANGE
        Ref(iter.lb), Ref(MDBValue()), op
    else
        (refs..., MDB_NEXT)
    end

    ret = _mdb_cursor_get(iter.cur.handle, mdb_key_ref, mdb_val_ref, cursor_op)

    if ret == 0
        newkey = convert(T, mdb_key_ref)
        # Convert to proper type
        if testifstop(newkey, iter.ub)
            return nothing 
        else 
            return (newkey, (mdb_key_ref, mdb_val_ref))
        end
    elseif ret == MDB_NOTFOUND
        return nothing
    else
        throw(LMDBError(ret))
    end
end

Base.IteratorSize(::KeyIterator) = Base.SizeUnknown()
Base.eltype(::KeyIterator{T}) where T = T



"Return iterator over keys of uniform, specified type"
function keys(cur::Cursor, ::Type{T}; lb = nothing, breakfunc = nothing) where T
    firstkey = isa(lb, MDB_val) ? lb : isa(lb,Nothing) ? MDBValue() : MDBValue(lb)
    return KeyIterator{T,typeof(lastkey_ref)}(cur,firstkey,breakfunc)
end

"""Retrieve by cursor.

This function retrieves key/data pairs from the database.
"""
function get(cur::Cursor, key, ::Type{T}, op::MDB_cursor_op=SET_KEY) where T
    # Setup parameters
    mdb_key_ref = Ref(MDBValue(toref(key)))
    mdb_val_ref = Ref(MDBValue())

    # Get value
    mdb_cursor_get(cur.handle, mdb_key_ref, mdb_val_ref, op)

    # Convert to proper type
    return convert(T, mdb_val_ref)
end

"""Store by cursor.

This function stores key/data pairs into the database. The cursor is positioned at the new item, or on failure usually near it.
"""
function put!(cur::Cursor, key, val; flags::Cuint = zero(Cuint))
    mdb_key_ref = Ref(MDBValue(toref(key)))
    mdb_val_ref = Ref(MDBValue(toref(val)))

    mdb_cursor_put(cur.handle, mdb_key_ref, mdb_val_ref, flags)
end

"Delete current key/data pair to which the cursor refers"
function delete!(cur::Cursor; flags::Cuint = zero(Cuint))
    mdb_cursor_del(cur.handle, flags)
end

"Return count of duplicates for current key"
function count(cur::Cursor)
    countp = Ref(Csize_t(0))
    mdb_cursor_count(cur.handle, countp)
    return Int(countp[])
end
