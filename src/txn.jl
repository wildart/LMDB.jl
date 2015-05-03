"""
A database transaction. Every operation requires a transaction handle.
All database operations require a transaction handle. Transactions may be read-only or read-write.
"""
type Transaction
    handle::Ptr{Void}
    env::Environment
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
function start(env::Environment; flags::Uint32 = 0x00000000)
    ret = Cint[0]
    handle = ccall( (:mdb_txn_start, liblmdbjl), Ptr{Void},
                    (Ptr{Void}, Cuint, Ptr{Cint}),
                    env.handle, flags, ret)
    (ret[1] != 0) && error(errormsg(ret))
    return Transaction(handle, env)
end

"Wrapper of `start` for `do` construct"
start(f::Function, env::Environment; flags::Uint32 = 0x00000000) = f(start(env, flags=flags))

"""Abandon all the operations of the transaction instead of saving them

*Note:* The transaction and its cursors must not be used after, because its handle is freed.
"""
function abort(txn::Transaction)
    ret = ccall( (:mdb_txn_abort, liblmdbjl), Cint, (Ptr{Void},), txn.handle)
    txn.handle = C_NULL
    (ret != 0) && error(errormsg(ret))
    return ret::Cint
end

"""Commit all the operations of a transaction into the database

*Note:* The transaction and its cursors must not be used after, because its handle is freed.
"""
function commit(txn::Transaction)
    ret = ccall( (:mdb_txn_commit, liblmdbjl), Cint, (Ptr{Void},), txn.handle)
    txn.handle = C_NULL
    (ret != 0) && error(errormsg(ret))
    return ret::Cint
end

"Reset a read-only transaction"
function reset(txn::Transaction)
    ret = ccall( (:mdb_txn_reset, liblmdbjl), Cint, (Ptr{Void},), txn.handle)
    (ret != 0) && error(errormsg(ret))
    return ret::Cint
end

"Renew a read-only transaction"
function renew(txn::Transaction)
    ret = ccall( (:mdb_txn_renew, liblmdbjl), Cint, (Ptr{Void},), txn.handle)
    (ret != 0) && error(errormsg(ret))
    return ret::Cint
end