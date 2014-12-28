using BinDeps

@BinDeps.setup

version = "0.9.10"
url = "https://gitorious.org/mdb/mdb/archive/LMDB_$(version).tar.gz"

liblmdb = library_dependency("liblmdb", aliases = ["liblmdb0", "lmdb.dll", "lmdb"])
liblmdbwrapper = library_dependency("liblmdbwrapper")

provides(AptGet, {"liblmdb-dev" => liblmdb})
provides(Sources, URI(url), [liblmdb, liblmdbwrapper], unpacked_dir="mdb-mdb")
provides(Sources, URI(joinpath(BinDeps.srcdir(liblmdbwrapper),"lmdbwrapper")), liblmdbwrapper)

lmdbsrcdir = joinpath(BinDeps.depsdir(liblmdb),"src", "lmdb-$version")
lmdbunpkddir = joinpath(BinDeps.depsdir(liblmdb),"src","mdb-mdb")
lmdblibfile = joinpath(BinDeps.libdir(liblmdb),liblmdb.name*".so")

provides(BuildProcess,
	(@build_steps begin
		GetSources(liblmdb)
		CreateDirectory(BinDeps.libdir(liblmdb))
		@build_steps begin
			`mv $(lmdbunpkddir)/libraries/liblmdb $(lmdbsrcdir)`
			@build_steps begin
				`rm -rf $(lmdbunpkddir)`
				@build_steps begin
					ChangeDirectory(lmdbsrcdir)
					FileRule(lmdblibfile, @build_steps begin
						`make liblmdb.so`
						`cp liblmdb.so $(lmdblibfile)`
					end)
				end
			end
		end
	end), liblmdb, os = :Unix)

wbuilddir = joinpath(BinDeps.builddir(liblmdbwrapper),"lmdbwrapper")
wlibfile = joinpath(BinDeps.libdir(liblmdbwrapper),liblmdbwrapper.name*".so")

provides(BuildProcess,
	(@build_steps begin
		CreateDirectory(wbuilddir)
		@build_steps begin
			ChangeDirectory(wbuilddir)
			FileRule(wlibfile, @build_steps begin
				MakeTargets(env=[utf8("LMDBINC")=>utf8(lmdbsrcdir)])
				`make install`
			end)
		end
	end), liblmdbwrapper)

@BinDeps.install [ :liblmdbwrapper => :liblmdbwrapper, :liblmdb => :liblmdb]