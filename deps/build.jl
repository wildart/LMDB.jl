using BinDeps

@BinDeps.setup

version = "0.9.14"
url = "https://gitorious.org/mdb/mdb/archive/LMDB_$(version).tar.gz"

liblmdbjl = library_dependency("liblmdbjl")

provides(Sources, URI(url), liblmdbjl, unpacked_dir="mdb-mdb")

lmdbbuilddir = BinDeps.builddir(liblmdbjl)
lmdbsrcdir = joinpath(BinDeps.depsdir(liblmdbjl),"src", "lmdb-$version")
lmdbunpkddir = joinpath(BinDeps.depsdir(liblmdbjl),"src","mdb-mdb")
lmdblib = joinpath(BinDeps.libdir(liblmdbjl),liblmdbjl.name*"."*BinDeps.shlib_ext)

provides(BuildProcess,
	(@build_steps begin
		GetSources(liblmdbjl)
		CreateDirectory(BinDeps.libdir(liblmdbjl))
		@build_steps begin
			`rm -rf $(lmdbsrcdir)`
			`mv $(lmdbunpkddir)/libraries/liblmdb $(lmdbsrcdir)`
			@build_steps begin
				`rm -rf $(lmdbunpkddir)`
				@build_steps begin
					ChangeDirectory(lmdbbuilddir)
					FileRule(lmdblib,
						@build_steps begin
							MakeTargets(env=[
								utf8("LMDBSRC")=>utf8(lmdbsrcdir),
								utf8("LMDBLIB")=>utf8(lmdblib)])
							`make`
						end
					)
				end
			end
		end
	end), liblmdbjl)

@BinDeps.install [ :liblmdbjl => :liblmdbjl]