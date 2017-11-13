__precompile__(true)
module LMDB

    isdefined(:Docile) && eval(:(@document))

    import Base: open, close, getindex, setindex!, put!, start, reset,
                 isopen, count, delete!, info, get, show

    if VERSION < v"0.6.0"
        import Base: drop
    end

    depsfile = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
    if isfile(depsfile)
        include(depsfile)
    else
        error("LMDB not properly installed. Please run Pkg.build(\"LMDB\")")
    end

    export Environment, create, open, close, sync, set!, unset!, getindex, setindex!, path, info, show,
           Transaction, start, abort, commit, reset, renew, environment,
           DBI, drop, delete!, get, put!,
           Cursor, count,
           isflagset, isopen,
           LMDBError, CursorOps

    include("common.jl")
    include("env.jl")
    include("txn.jl")
    include("dbi.jl")
    include("cur.jl")
end
