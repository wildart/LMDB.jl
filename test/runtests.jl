using Base.Test

@testset "LMDB" for t in ["common", "env", "dbi", "cur"]
    fp = "$t.jl"
    println("* running $fp ...")
    include(fp)
end

