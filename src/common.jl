# Environment Flags
# -----------------
const FIXEDMAP   = 0x01     # mmap at a fixed address
const NOSUBDIR   = 0x4000   # no environment directory
const NOSYNC     = 0x10000  # don't fsync after commit
const RDONLY     = 0x20000  # read only
const NOMETASYNC = 0x40000  # don't fsync metapage after commit
const WRITEMAP   = 0x80000  # use writable mmap
const MAPASYNC   = 0x100000 # use asynchronous msync when #MDB_WRITEMAP is used
const MDB_NOTLS  = 0x200000 # tie reader locktable slots to #MDB_txn objects instead of to threads
const NOLOCK     = 0x400000 # don't do any locking, caller must manage their own locks
const NORDAHEAD  = 0x800000 # don't do readahead (no effect on Windows)
const NOMEMINIT  = 0x1000000 # don't initialize malloc'd memory before writing to datafile

# Database Flags
# --------------
const REVERSEKEY = 0x02 # use reverse string keys
const DUPSORT    = 0x04 # use sorted duplicates
const INTEGERKEY = 0x08 # numeric keys in native byte order. The keys must all be of the same size.
const DUPFIXED   = 0x10 # with MDB_DUPSORT, sorted dup items have fixed size
const INTEGERDUP = 0x20 # with MDB_DUPSORT, dups are numeric in native byte order
const REVERSEDUP = 0x40 # with #MDB_DUPSORT, use reverse string dups
const CREATE     = 0x40000 # create DB if not already existing

@doc "Return the LMDB library version and version information." ->
function version()
    major = Cint[0]
    minor = Cint[0]
    patch = Cint[0]
    ver_str = ccall( (:mdb_version, liblmdb), Ptr{Cchar}, (Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), major, minor, patch)
    return VersionNumber(major[1],minor[1],patch[1]), bytestring(ver_str)
end

@doc "Return a string describing a given error code." ->
function errormsg(ret::Cint)
    errstr = ccall( (:mdb_strerror, liblmdb), Ptr{Cchar}, (Cint,), ret)
    return bytestring(errstr)
end

isflagset(value, flag) = (value & flag) == flag

function val_size(val)
    valsize = sizeof(val)
    if isa(val, String)
        valsize *= sizeof(eltype(val))
    end
    return uint32(valsize)
end

