using Test, LMDB
@testset "Dictionary-like interface" begin
p1 = tempname()
#Test dict with string keys, float64 values
mkpath(p1)
d = LMDBDict{String, Float64}(p1)
d["x"] = 5.0
d["y"] = 12.0
d["z"] = 3
@test d["x"] === 5.0
@test d["y"] === 12.0
@test d["z"] === 3.0
@test haskey(d,"x")
@test !haskey(d,"a")
@test keys(d) == ["x", "y", "z"]
@test values(d) == [5.0, 12.0, 3.0]
@test collect(d) == ["x"=>5.0, "y"=>12.0, "z"=>3.0]
@test LMDB.valuesize(d) == sizeof(Float64)*3
delete!(d,"z")
@test !haskey(d,"z")
@test_throws LMDB.LMDBError d["z"]

#Test int key and values
p2 = tempname()
mkpath(p2)
d = LMDBDict{Int64, Int16}(p2)
for i in 1:10
    d[i] = i+1
end
@test keys(d) == 1:10
@test values(d) == 2:11
@test d[2] === Int16(3)
@test d[3.0] == 4
@test eltype(d) == Int16
@test keytype(d) == Int64

#Some extra tests for string dicts
p3 = tempname()
mkpath(p3)
d = LMDBDict{String, Vector{Float32}}(p3)
d["aa/a"] = Float32[1,2,3,4]
d["aa/b"] = Float32.(2:12)
d["aa/c"] = [10,11,12]
d["b"] = [0,0,0]
@test d["aa/a"] == 1:4
@test d["aa/b"] == 2:12
@test d["aa/c"] == 10:12
@test d["b"] == [0,0,0]
@test LMDB.list_dirs(d) == ["aa/", "b"]
@test LMDB.list_dirs(d,prefix="aa/") == ["aa/a", "aa/b", "aa/c"]
@test LMDB.valuesize(d,prefix="aa/") == sizeof(Float32)*18
end