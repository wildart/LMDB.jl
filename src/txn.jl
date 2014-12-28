"""Opaque structure for a transaction handle.
A database transaction. Every operation requires a transaction handle.
All database operations require a transaction handle. Transactions may be read-only or read-write.
"""
type Transaction
    handle::Ptr{Void}
    env::Environment
    Transaction(h::Ptr{Void}, env::Environment) = new(h, env)
end

@doc "Returns the transaction's environment."->
environment(txn::Transaction) = txn.env

@doc "Check if transaction is open." ->
isopen(txn::Transaction) = txn.handle != C_NULL

@doc "Create a transaction for use with the environment."->
function start(env::Environment; flags::Uint32 = 0x00000000)
    handle = ccall( (:mdb_txn_start, liblmdbwrapper), Ptr{Void}, (Ptr{Void}, Ptr{Void}, Cuint), env.handle, C_NULL, flags)
    return Transaction(handle, env)
end

@doc "Wrapper of `start` for `do` construct." ->
start(f::Function, env::Environment; flags::Uint32 = 0x00000000) = f(start(env, flags=flags))

@doc "Abandon all the operations of the transaction instead of saving them."->
function abort(txn::Transaction)
    ret = ccall( (:mdb_txn_abort, liblmdb), Cint, (Ptr{Void},), txn.handle)
    txn.handle = C_NULL
    if ret != 0
        warn(errormsg(ret))
    end
    return ret::Cint
end

@doc "Commit all the operations of a transaction into the database."->
function commit(txn::Transaction)
    ret = ccall( (:mdb_txn_commit, liblmdb), Cint, (Ptr{Void},), txn.handle)
    txn.handle = C_NULL
    if ret != 0
        warn(errormsg(ret))
    end
    return ret::Cint
end

@doc "Reset a read-only transaction."->
function reset(txn::Transaction)
    ret = ccall( (:mdb_txn_reset, liblmdb), Cint, (Ptr{Void},), txn.handle)
    if ret != 0
        warn(errormsg(ret))
    end
    return ret::Cint
end

@doc "Renew a read-only transaction."->
function renew(txn::Transaction)
    ret = ccall( (:mdb_txn_renew, liblmdb), Cint, (Ptr{Void},), txn.handle)
    if ret != 0
        warn(errormsg(ret))
    end
    return ret::Cint
end