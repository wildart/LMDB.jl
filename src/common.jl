const Cmode_t = Cushort

"Generic structure used for passing keys and data in and out of the database."
type MDBValue
    size::Csize_t   # size of the data item
    data::Ptr{Void} # address of the data item
end
MDBValue() = MDBValue(zero(Csize_t), C_NULL)
function MDBValue(val)
    val_size = sizeof(val)
    val = isa(val, Number) ? typeof(val)[val] : val
    return MDBValue(val_size, pointer(val))
end


# Environment Flags
# -----------------
@enum(EnvironmentFlags,
      FIXEDMAP   = 0x00000001, # mmap at a fixed address
      NOSUBDIR   = 0x00004000, # no environment directory
      NOSYNC     = 0x00010000, # don't fsync after commit
      RDONLY     = 0x00020000, # read only
      NOMETASYNC = 0x00040000, # don't fsync metapage after commit
      WRITEMAP   = 0x00080000, # use writable mmap
      MAPASYNC   = 0x00100000, # use asynchronous msync when #MDB_WRITEMAP is used
      NOTLS      = 0x00200000, # tie reader locktable slots to #MDB_txn objects instead of to threads
      NOLOCK     = 0x00400000, # don't do any locking, caller must manage their own locks
      NORDAHEAD  = 0x00800000, # don't do readahead (no effect on Windows)
      NOMEMINIT  = 0x01000000 # don't initialize malloc'd memory before writing to datafile
)

# Database Flags
# --------------
@enum(DatabaseFlags,
      REVERSEKEY = 0x00000002, # use reverse string keys
      DUPSORT    = 0x00000004, # use sorted duplicates
      INTEGERKEY = 0x00000008, # numeric keys in native byte order. The keys must all be of the same size.
      DUPFIXED   = 0x00000010, # with MDB_DUPSORT, sorted dup items have fixed size
      INTEGERDUP = 0x00000020, # with MDB_DUPSORT, dups are numeric in native byte order
      REVERSEDUP = 0x00000040, # with #MDB_DUPSORT, use reverse string dups
      CREATE     = 0x00040000 # create DB if not already existing
)

# Write Flags
# -----------
@enum(WriteFlags,
      NOOVERWRITE =0x00000010, # For put: Don't write if the key already exists.
#= Only for #MDB_DUPSORT
 * For put: don't write if the key and data pair already exist.
 * For mdb_cursor_del: remove all duplicate data items.
 =#
      NODUPDATA = 0x00000020,
      CURRENT   = 0x00000040, # For mdb_cursor_put: overwrite the current key/data pair
      RESERVE   = 0x00010000, # For put: Just reserve space for data, don't copy it. Return a pointer to the reserved space.
      APPEND    = 0x00020000, # Data is being appended, don't split full pages.
      APPENDDUP = 0x00040000, # Duplicate data is being appended, don't split full pages.
      MULTIPLE  = 0x00080000 # Store multiple data items in one call. Only for DUPFIXED.
)

# Cursor `get` operations
# -----------------------
@enum(CursorOps,
      FIRST,          # Position at first key/data item
      FIRST_DUP,      # Position at first data item of current key. Only for #DUPSORT
      GET_BOTH,       # Position at key/data pair. Only for #MDB_DUPSORT
      GET_BOTH_RANGE, # Position at key, nearest data. Only for #MDB_DUPSORT
      GET_CURRENT,    # Return key/data at current cursor position
      GET_MULTIPLE,   # Return key and up to a page of duplicate data items from current cursor position. Move cursor to prepare for #NEXT_MULTIPLE. Only for #DUPFIXED
      LAST,           # Position at last key/data item
      LAST_DUP,       # Position at last data item of current key. Only for #DUPSORT
      NEXT,           # Position at next data item
      NEXT_DUP,       # Position at next data item of current key. Only for #DUPSORT
      NEXT_MULTIPLE,  # Return key and up to a page of duplicate data items from next cursor position. Move cursor to prepare for #NEXT_MULTIPLE. Only for #DUPFIXED
      NEXT_NODUP,     # Position at first data item of next key
      PREV,           # Position at previous data item
      PREV_DUP,       # Position at previous data item of current key. Only for #MDB_DUPSORT
      PREV_NODUP,     # Position at last data item of previous key
      SET,            # Position at specified key
      SET_KEY,        # Position at specified key, return key + data
      SET_RANGE)      # Position at first key greater than or equal to specified key.


"""Return the LMDB library version and version information

Function returns tuple `(VersionNumber, String)` that contains a library version and a library version string.
"""
function version()
    major = Cint[0]
    minor = Cint[0]
    patch = Cint[0]
    ver_str = ccall( (:mdb_version, liblmdb), Cstring, (Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), major, minor, patch)
    return VersionNumber(major[1],minor[1],patch[1]), unsafe_string(ver_str)
end

"""Return a string describing a given error code

Function returns description of the error as a string. It accepts following arguments:
* `err::Int32`: An error code.
"""
function errormsg(err::Cint)
    errstr = ccall( (:mdb_strerror, liblmdb), Cstring, (Cint,), err)
    return unsafe_string(errstr)
end

"""LMDB exception type"""
immutable LMDBError <: Exception
    code::Cint
    msg::AbstractString
    LMDBError(code::Cint) = new(code, errormsg(code))
end
Base.show(io::IO, err::LMDBError) = print(io, "Code[$(err.code)]: $(err.msg)")

""" Check if binary flag is set in provided value"""
isflagset(value, flag) = (value & flag) == flag
