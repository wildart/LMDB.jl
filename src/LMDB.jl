__precompile__(true)
module LMDB

    isdefined(:Docile) && eval(:(@document))

    import Base: open, close, getindex, setindex!, put!, start, reset,
                 isopen, count, delete!, info, get, show, convert
    import Base.Iterators: drop

    if isfile(depsfile)
        include(depsfile)
    else
        error("LMDB not properly installed. Please run Pkg.build(\"LMDB\")")
    end

    depsfile = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")

    export Environment, create, open, close, sync, set!, unset!, getindex, setindex!, path, info, show,
           Transaction, start, abort, commit, reset, renew, environment,
           DBI, drop, delete!, get, put!,
           Cursor, count, transaction, database,
           isflagset, isopen,
           LMDBError, CursorOps

    include("common.jl")
    include("env.jl")
    include("txn.jl")
    include("dbi.jl")
    include("cur.jl")
end
