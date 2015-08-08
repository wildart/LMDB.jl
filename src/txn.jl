"""
A database transaction. Every operation requires a transaction handle.
All database operations require a transaction handle. Transactions may be read-only or read-write.
"""
type Transaction
    handle::Ptr{Void}
    Transaction() = new(C_NULL)
    Transaction(h::Ptr{Void}) = new(h)
end

function env(txn::Transaction)
    env_ptr = ccall((:mdb_txn_env, liblmdb), Ptr{Void}, (Ptr{Void},), txn.handle)
    (env_ptr == C_NULL) && return nothing
    return Environment(env_ptr)
end

"Check if transaction is open."
isopen(txn::Transaction) = txn.handle != C_NULL

"""Create a transaction for use with the environment

`start` function creates a new transaction and returns `Transaction` object.
It allows to set transaction flags with `flags` option.
"""
function start(env::Environment; flags::Cuint=zero(Cuint),
               parent::Nullable{Transaction} = Nullable{Transaction}())
    txn_ref = Ref{Ptr{Void}}(C_NULL)
    ret = ccall( (:mdb_txn_begin, liblmdb), Cint,
                  (Ptr{Void}, Ptr{Void}, Cuint, Ptr{Ptr{Void}}),
                   env.handle, get(parent, Transaction()).handle,  flags, txn_ref)
    (ret != 0) && throw(LMDBError(ret))
    return Transaction(txn_ref[])
end
start(f::Function, env::Environment; flags::Cuint=zero(Cuint)) = f(start(env, flags=flags))

"""Abandon all the operations of the transaction instead of saving them

The transaction and its cursors must not be used after, because its handle is freed.
"""
function abort(txn::Transaction)
    ret = ccall( (:mdb_txn_abort, liblmdb), Cint, (Ptr{Void},), txn.handle)
    txn.handle = C_NULL
    (ret != 0) && throw(LMDBError(ret))
    return ret
end

"""Commit all the operations of a transaction into the database

The transaction and its cursors must not be used after, because its handle is freed.
"""
function commit(txn::Transaction)
    ret = ccall( (:mdb_txn_commit, liblmdb), Cint, (Ptr{Void},), txn.handle)
    txn.handle = C_NULL
    (ret != 0) && throw(LMDBError(ret))
    return ret
end

"""Reset a read-only transaction

Abort the transaction like `abort`, but keep the transaction handle.
"""
function reset(txn::Transaction)
    ret = ccall( (:mdb_txn_reset, liblmdb), Cint, (Ptr{Void},), txn.handle)
    (ret != 0) && throw(LMDBError(ret))
    return ret
end

"""Renew a read-only transaction

This acquires a new reader lock for a transaction handle that had been released by `reset`.
It must be called before a reset transaction may be used again.
"""
function renew(txn::Transaction)
    ret = ccall( (:mdb_txn_renew, liblmdb), Cint, (Ptr{Void},), txn.handle)
    (ret != 0) && throw(LMDBError(ret))
    return ret
end