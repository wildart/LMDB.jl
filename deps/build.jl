using BinDeps, Libdl

@BinDeps.setup

version = "0.9.21"
url = "https://github.com/LMDB/lmdb/archive/LMDB_$(version).tar.gz"

liblmdb = library_dependency("liblmdb")

provides(Sources, URI(url), liblmdb, unpacked_dir="lmdb-LMDB_$version")

lmdbsrcdir = joinpath(BinDeps.srcdir(liblmdb),"lmdb-LMDB_$version","libraries","liblmdb")
lmdblibfile = joinpath(BinDeps.libdir(liblmdb),liblmdb.name*"."*Libdl.dlext)

provides(BuildProcess,
	(@build_steps begin
		GetSources(liblmdb)
		CreateDirectory(BinDeps.libdir(liblmdb))
		FileRule(lmdblibfile, @build_steps begin
			MakeTargets(lmdbsrcdir, ["liblmdb.so"])
			`mv $lmdbsrcdir/liblmdb.so $lmdblibfile`
		end)
	end), liblmdb)

@BinDeps.install Dict( :liblmdb => :liblmdb)
