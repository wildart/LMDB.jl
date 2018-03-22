if VERSION.minor < 7
    using Base.Test
else
    using Test
end
push!(LOAD_PATH, joinpath(dirname(@__FILE__), "../src"))

@testset "LMDB" for t in ["common", "env", "dbi", "cur"]
    fp = "$t.jl"
    println("* running $fp ...")
    include(fp)
end

