"""
A database transaction. Every operation requires a transaction handle.
All database operations require a transaction handle. Transactions may be read-only or read-write.
"""
type Transaction
    handle::Ptr{Void}
    env::Environment
    Transaction() = new(C_NULL, Environment())
    Transaction(h::Ptr{Void}, env::Environment) = new(h, env)
end

"Returns the transaction's environment"
environment(txn::Transaction) = txn.env

"Check if transaction is open."
isopen(txn::Transaction) = txn.handle != C_NULL

"""Create a transaction for use with the environment

`start` function creates a new transaction and returns `Transaction` object.
It allows to set transaction flags with `flags` option.
"""
function start(env::Environment; flags::EnvironmentFlags = EMPTY,
               parent::Nullable{Transaction} = Nullable{Transaction}())
    txn_ref = Ref{Ptr{Void}}(C_NULL)
    ret = ccall( (:mdb_txn_begin, liblmdb), Cint,
                  (Ptr{Void}, Ptr{Void}, Cuint, Ptr{Ptr{Void}}),
                   env.handle, get(parent, Transaction()).handle,  Cuint(flags), txn_ref)
    (ret != 0) && throw(LMDBError(ret))
    return Transaction(txn_ref[], env)
end
start(f::Function, env::Environment; flags::EnvironmentFlags = EMPTY) = f(start(env, flags=flags))

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