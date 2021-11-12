mutable struct LMDBDict{K,V}
    env::LMDB.Environment
    dbi::LMDB.DBI
    function LMDBDict{K,V}(env::LMDB.Environment, dbi::LMDB.DBI) where {K,V}
        x = new{K,V}(env, dbi)
        finalizer(x) do d
            LMDB.close(d.env,d.dbi)
            LMDB.close(d.env)
        end
        x
    end
end
function LMDBDict{K,V}(path::String) where {K,V} 
    env = LMDB.create()
    open(env, path)
    #A transaction just for getting a DBI handle
    dbi = LMDB.start(env) do txn
        LMDB.open(txn)
    end
    LMDBDict{K,V}(env, dbi)
end
LMDBDict(path::String) = LMDBDict{String, Vector{Uint8}}(path)


function cursor_do(f, d; readonly = false)
    txnflags = readonly ? Cuint(LMDB.MDB_RDONLY) : Cuint(0)
    LMDB.start(d.env, flags = txnflags) do txn
        LMDB.open(txn,d.dbi) do cur
            f(cur)
        end
    end
end

function txn_dbi_do(f, d; readonly = false)
    txnflags = readonly ? Cuint(LMDB.MDB_RDONLY) : Cuint(0)
    LMDB.start(d.env, flags = txnflags) do txn
        f(txn, d.dbi)
    end
end

function list_dirs(d::LMDBDict{String}; prefix = "", sep = '/')
    cursor_do(d, readonly = true) do cur
        iter = LMDB.LMDBIterator(cur,LMDB.DirectoryLister(;prefix=prefix, sep = sep))
        collect(iter)
    end
end

function Base.keys(d::LMDBDict{K}) where K
    cursor_do(d, readonly = true) do cur
        collect(keys(cur,K))
    end
end

function Base.values(d::LMDBDict{K,V}) where {K,V}
    cursor_do(d, readonly = true) do cur
        collect(values(cur,V))
    end
end

function Base.collect(d::LMDBDict{K,V}) where {K,V}
    cursor_do(d, readonly = true) do cur
        collect((LMDB.LMDBIterator{LMDB.ReturnBoth{K,V}}(cur)))
    end
end


function Base.getindex(d::LMDBDict{K,V},k) where {K,V}
    cursor_do(d, readonly = true) do cur
        LMDB.get(cur, k, V, LMDB.MDB_SET_KEY)
    end
end

function Base.setindex!(d::LMDBDict{K,V},v,k) where {K,V}
    txn_dbi_do(d) do txn, dbi
        LMDB.put!(txn,dbi,k,v)
    end
    v
end

function Base.delete!(d::LMDBDict{K},k) where K
    txn_dbi_do(d) do txn, dbi
        LMDB.delete!(txn, dbi, k)
    end
    d
end