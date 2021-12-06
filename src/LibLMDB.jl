module LibLMDB

import ..checked_call

using LMDB_jll
export LMDB_jll

using CEnum

const __mode_t = Cushort

const mode_t = __mode_t

mutable struct MDB_txn end

const MDB_dbi = Cuint

function _mdb_dbi_open(txn, name, flags, dbi)
    ccall((:mdb_dbi_open, liblmdb), Cint, (Ptr{MDB_txn}, Ptr{Cchar}, Cuint, Ptr{MDB_dbi}), txn, name, flags, dbi)
end

mdb_dbi_open(txn, name, flags, dbi) = checked_call(_mdb_dbi_open, txn, name, flags, dbi)

mutable struct MDB_env end

function _mdb_dbi_close(env, dbi)
    ccall((:mdb_dbi_close, liblmdb), Cvoid, (Ptr{MDB_env}, MDB_dbi), env, dbi)
end

mdb_dbi_close(env, dbi) = checked_call(_mdb_dbi_close, env, dbi)

const mdb_mode_t = mode_t

const mdb_filehandle_t = Cint

mutable struct MDB_cursor end

struct MDB_val
    mv_size::Csize_t
    mv_data::Ptr{Cvoid}
end

# typedef int ( MDB_cmp_func ) ( const MDB_val * a , const MDB_val * b )
const MDB_cmp_func = Cvoid

# typedef void ( MDB_rel_func ) ( MDB_val * item , void * oldptr , void * newptr , void * relctx )
const MDB_rel_func = Cvoid

@cenum MDB_cursor_op::UInt32 begin
    MDB_FIRST = 0
    MDB_FIRST_DUP = 1
    MDB_GET_BOTH = 2
    MDB_GET_BOTH_RANGE = 3
    MDB_GET_CURRENT = 4
    MDB_GET_MULTIPLE = 5
    MDB_LAST = 6
    MDB_LAST_DUP = 7
    MDB_NEXT = 8
    MDB_NEXT_DUP = 9
    MDB_NEXT_MULTIPLE = 10
    MDB_NEXT_NODUP = 11
    MDB_PREV = 12
    MDB_PREV_DUP = 13
    MDB_PREV_NODUP = 14
    MDB_SET = 15
    MDB_SET_KEY = 16
    MDB_SET_RANGE = 17
    MDB_PREV_MULTIPLE = 18
end

struct MDB_stat
    ms_psize::Cuint
    ms_depth::Cuint
    ms_branch_pages::Csize_t
    ms_leaf_pages::Csize_t
    ms_overflow_pages::Csize_t
    ms_entries::Csize_t
end

struct MDB_envinfo
    me_mapaddr::Ptr{Cvoid}
    me_mapsize::Csize_t
    me_last_pgno::Csize_t
    me_last_txnid::Csize_t
    me_maxreaders::Cuint
    me_numreaders::Cuint
end

function _mdb_version(major, minor, patch)
    ccall((:mdb_version, liblmdb), Ptr{Cchar}, (Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), major, minor, patch)
end

mdb_version(major, minor, patch) = checked_call(_mdb_version, major, minor, patch)

function _mdb_strerror(err)
    ccall((:mdb_strerror, liblmdb), Ptr{Cchar}, (Cint,), err)
end

mdb_strerror(err) = checked_call(_mdb_strerror, err)

function _mdb_env_create(env)
    ccall((:mdb_env_create, liblmdb), Cint, (Ptr{Ptr{MDB_env}},), env)
end

mdb_env_create(env) = checked_call(_mdb_env_create, env)

function _mdb_env_open(env, path, flags, mode)
    ccall((:mdb_env_open, liblmdb), Cint, (Ptr{MDB_env}, Ptr{Cchar}, Cuint, mdb_mode_t), env, path, flags, mode)
end

mdb_env_open(env, path, flags, mode) = checked_call(_mdb_env_open, env, path, flags, mode)

function _mdb_env_copy(env, path)
    ccall((:mdb_env_copy, liblmdb), Cint, (Ptr{MDB_env}, Ptr{Cchar}), env, path)
end

mdb_env_copy(env, path) = checked_call(_mdb_env_copy, env, path)

function _mdb_env_copyfd(env, fd)
    ccall((:mdb_env_copyfd, liblmdb), Cint, (Ptr{MDB_env}, mdb_filehandle_t), env, fd)
end

mdb_env_copyfd(env, fd) = checked_call(_mdb_env_copyfd, env, fd)

function _mdb_env_copy2(env, path, flags)
    ccall((:mdb_env_copy2, liblmdb), Cint, (Ptr{MDB_env}, Ptr{Cchar}, Cuint), env, path, flags)
end

mdb_env_copy2(env, path, flags) = checked_call(_mdb_env_copy2, env, path, flags)

function _mdb_env_copyfd2(env, fd, flags)
    ccall((:mdb_env_copyfd2, liblmdb), Cint, (Ptr{MDB_env}, mdb_filehandle_t, Cuint), env, fd, flags)
end

mdb_env_copyfd2(env, fd, flags) = checked_call(_mdb_env_copyfd2, env, fd, flags)

function _mdb_env_stat(env, stat)
    ccall((:mdb_env_stat, liblmdb), Cint, (Ptr{MDB_env}, Ptr{MDB_stat}), env, stat)
end

mdb_env_stat(env, stat) = checked_call(_mdb_env_stat, env, stat)

function _mdb_env_info(env, stat)
    ccall((:mdb_env_info, liblmdb), Cint, (Ptr{MDB_env}, Ptr{MDB_envinfo}), env, stat)
end

mdb_env_info(env, stat) = checked_call(_mdb_env_info, env, stat)

function _mdb_env_sync(env, force)
    ccall((:mdb_env_sync, liblmdb), Cint, (Ptr{MDB_env}, Cint), env, force)
end

mdb_env_sync(env, force) = checked_call(_mdb_env_sync, env, force)

function _mdb_env_close(env)
    ccall((:mdb_env_close, liblmdb), Cvoid, (Ptr{MDB_env},), env)
end

mdb_env_close(env) = checked_call(_mdb_env_close, env)

function _mdb_env_set_flags(env, flags, onoff)
    ccall((:mdb_env_set_flags, liblmdb), Cint, (Ptr{MDB_env}, Cuint, Cint), env, flags, onoff)
end

mdb_env_set_flags(env, flags, onoff) = checked_call(_mdb_env_set_flags, env, flags, onoff)

function _mdb_env_get_flags(env, flags)
    ccall((:mdb_env_get_flags, liblmdb), Cint, (Ptr{MDB_env}, Ptr{Cuint}), env, flags)
end

mdb_env_get_flags(env, flags) = checked_call(_mdb_env_get_flags, env, flags)

function _mdb_env_get_path(env, path)
    ccall((:mdb_env_get_path, liblmdb), Cint, (Ptr{MDB_env}, Ptr{Ptr{Cchar}}), env, path)
end

mdb_env_get_path(env, path) = checked_call(_mdb_env_get_path, env, path)

function _mdb_env_get_fd(env, fd)
    ccall((:mdb_env_get_fd, liblmdb), Cint, (Ptr{MDB_env}, Ptr{mdb_filehandle_t}), env, fd)
end

mdb_env_get_fd(env, fd) = checked_call(_mdb_env_get_fd, env, fd)

function _mdb_env_set_mapsize(env, size)
    ccall((:mdb_env_set_mapsize, liblmdb), Cint, (Ptr{MDB_env}, Csize_t), env, size)
end

mdb_env_set_mapsize(env, size) = checked_call(_mdb_env_set_mapsize, env, size)

function _mdb_env_set_maxreaders(env, readers)
    ccall((:mdb_env_set_maxreaders, liblmdb), Cint, (Ptr{MDB_env}, Cuint), env, readers)
end

mdb_env_set_maxreaders(env, readers) = checked_call(_mdb_env_set_maxreaders, env, readers)

function _mdb_env_get_maxreaders(env, readers)
    ccall((:mdb_env_get_maxreaders, liblmdb), Cint, (Ptr{MDB_env}, Ptr{Cuint}), env, readers)
end

mdb_env_get_maxreaders(env, readers) = checked_call(_mdb_env_get_maxreaders, env, readers)

function _mdb_env_set_maxdbs(env, dbs)
    ccall((:mdb_env_set_maxdbs, liblmdb), Cint, (Ptr{MDB_env}, MDB_dbi), env, dbs)
end

mdb_env_set_maxdbs(env, dbs) = checked_call(_mdb_env_set_maxdbs, env, dbs)

function _mdb_env_get_maxkeysize(env)
    ccall((:mdb_env_get_maxkeysize, liblmdb), Cint, (Ptr{MDB_env},), env)
end

mdb_env_get_maxkeysize(env) = checked_call(_mdb_env_get_maxkeysize, env)

function _mdb_env_set_userctx(env, ctx)
    ccall((:mdb_env_set_userctx, liblmdb), Cint, (Ptr{MDB_env}, Ptr{Cvoid}), env, ctx)
end

mdb_env_set_userctx(env, ctx) = checked_call(_mdb_env_set_userctx, env, ctx)

function _mdb_env_get_userctx(env)
    ccall((:mdb_env_get_userctx, liblmdb), Ptr{Cvoid}, (Ptr{MDB_env},), env)
end

mdb_env_get_userctx(env) = checked_call(_mdb_env_get_userctx, env)

# typedef void MDB_assert_func ( MDB_env * env , const char * msg )
const MDB_assert_func = Cvoid

function _mdb_env_set_assert(env, func)
    ccall((:mdb_env_set_assert, liblmdb), Cint, (Ptr{MDB_env}, Ptr{Cvoid}), env, func)
end

mdb_env_set_assert(env, func) = checked_call(_mdb_env_set_assert, env, func)

function _mdb_txn_begin(env, parent, flags, txn)
    ccall((:mdb_txn_begin, liblmdb), Cint, (Ptr{MDB_env}, Ptr{MDB_txn}, Cuint, Ptr{Ptr{MDB_txn}}), env, parent, flags, txn)
end

mdb_txn_begin(env, parent, flags, txn) = checked_call(_mdb_txn_begin, env, parent, flags, txn)

function _mdb_txn_env(txn)
    ccall((:mdb_txn_env, liblmdb), Ptr{MDB_env}, (Ptr{MDB_txn},), txn)
end

mdb_txn_env(txn) = checked_call(_mdb_txn_env, txn)

function _mdb_txn_id(txn)
    ccall((:mdb_txn_id, liblmdb), Csize_t, (Ptr{MDB_txn},), txn)
end

mdb_txn_id(txn) = checked_call(_mdb_txn_id, txn)

function _mdb_txn_commit(txn)
    ccall((:mdb_txn_commit, liblmdb), Cint, (Ptr{MDB_txn},), txn)
end

mdb_txn_commit(txn) = checked_call(_mdb_txn_commit, txn)

function _mdb_txn_abort(txn)
    ccall((:mdb_txn_abort, liblmdb), Cvoid, (Ptr{MDB_txn},), txn)
end

mdb_txn_abort(txn) = checked_call(_mdb_txn_abort, txn)

function _mdb_txn_reset(txn)
    ccall((:mdb_txn_reset, liblmdb), Cvoid, (Ptr{MDB_txn},), txn)
end

mdb_txn_reset(txn) = checked_call(_mdb_txn_reset, txn)

function _mdb_txn_renew(txn)
    ccall((:mdb_txn_renew, liblmdb), Cint, (Ptr{MDB_txn},), txn)
end

mdb_txn_renew(txn) = checked_call(_mdb_txn_renew, txn)

function _mdb_stat(txn, dbi, stat)
    ccall((:mdb_stat, liblmdb), Cint, (Ptr{MDB_txn}, MDB_dbi, Ptr{MDB_stat}), txn, dbi, stat)
end

mdb_stat(txn, dbi, stat) = checked_call(_mdb_stat, txn, dbi, stat)

function _mdb_dbi_flags(txn, dbi, flags)
    ccall((:mdb_dbi_flags, liblmdb), Cint, (Ptr{MDB_txn}, MDB_dbi, Ptr{Cuint}), txn, dbi, flags)
end

mdb_dbi_flags(txn, dbi, flags) = checked_call(_mdb_dbi_flags, txn, dbi, flags)

function _mdb_drop(txn, dbi, del)
    ccall((:mdb_drop, liblmdb), Cint, (Ptr{MDB_txn}, MDB_dbi, Cint), txn, dbi, del)
end

mdb_drop(txn, dbi, del) = checked_call(_mdb_drop, txn, dbi, del)

function _mdb_set_compare(txn, dbi, cmp)
    ccall((:mdb_set_compare, liblmdb), Cint, (Ptr{MDB_txn}, MDB_dbi, Ptr{Cvoid}), txn, dbi, cmp)
end

mdb_set_compare(txn, dbi, cmp) = checked_call(_mdb_set_compare, txn, dbi, cmp)

function _mdb_set_dupsort(txn, dbi, cmp)
    ccall((:mdb_set_dupsort, liblmdb), Cint, (Ptr{MDB_txn}, MDB_dbi, Ptr{Cvoid}), txn, dbi, cmp)
end

mdb_set_dupsort(txn, dbi, cmp) = checked_call(_mdb_set_dupsort, txn, dbi, cmp)

function _mdb_set_relfunc(txn, dbi, rel)
    ccall((:mdb_set_relfunc, liblmdb), Cint, (Ptr{MDB_txn}, MDB_dbi, Ptr{Cvoid}), txn, dbi, rel)
end

mdb_set_relfunc(txn, dbi, rel) = checked_call(_mdb_set_relfunc, txn, dbi, rel)

function _mdb_set_relctx(txn, dbi, ctx)
    ccall((:mdb_set_relctx, liblmdb), Cint, (Ptr{MDB_txn}, MDB_dbi, Ptr{Cvoid}), txn, dbi, ctx)
end

mdb_set_relctx(txn, dbi, ctx) = checked_call(_mdb_set_relctx, txn, dbi, ctx)

function _mdb_get(txn, dbi, key, data)
    ccall((:mdb_get, liblmdb), Cint, (Ptr{MDB_txn}, MDB_dbi, Ptr{MDB_val}, Ptr{MDB_val}), txn, dbi, key, data)
end

mdb_get(txn, dbi, key, data) = checked_call(_mdb_get, txn, dbi, key, data)

function _mdb_put(txn, dbi, key, data, flags)
    ccall((:mdb_put, liblmdb), Cint, (Ptr{MDB_txn}, MDB_dbi, Ptr{MDB_val}, Ptr{MDB_val}, Cuint), txn, dbi, key, data, flags)
end

mdb_put(txn, dbi, key, data, flags) = checked_call(_mdb_put, txn, dbi, key, data, flags)

function _mdb_del(txn, dbi, key, data)
    ccall((:mdb_del, liblmdb), Cint, (Ptr{MDB_txn}, MDB_dbi, Ptr{MDB_val}, Ptr{MDB_val}), txn, dbi, key, data)
end

mdb_del(txn, dbi, key, data) = checked_call(_mdb_del, txn, dbi, key, data)

function _mdb_cursor_open(txn, dbi, cursor)
    ccall((:mdb_cursor_open, liblmdb), Cint, (Ptr{MDB_txn}, MDB_dbi, Ptr{Ptr{MDB_cursor}}), txn, dbi, cursor)
end

mdb_cursor_open(txn, dbi, cursor) = checked_call(_mdb_cursor_open, txn, dbi, cursor)

function _mdb_cursor_close(cursor)
    ccall((:mdb_cursor_close, liblmdb), Cvoid, (Ptr{MDB_cursor},), cursor)
end

mdb_cursor_close(cursor) = checked_call(_mdb_cursor_close, cursor)

function _mdb_cursor_renew(txn, cursor)
    ccall((:mdb_cursor_renew, liblmdb), Cint, (Ptr{MDB_txn}, Ptr{MDB_cursor}), txn, cursor)
end

mdb_cursor_renew(txn, cursor) = checked_call(_mdb_cursor_renew, txn, cursor)

function _mdb_cursor_txn(cursor)
    ccall((:mdb_cursor_txn, liblmdb), Ptr{MDB_txn}, (Ptr{MDB_cursor},), cursor)
end

mdb_cursor_txn(cursor) = checked_call(_mdb_cursor_txn, cursor)

function _mdb_cursor_dbi(cursor)
    ccall((:mdb_cursor_dbi, liblmdb), MDB_dbi, (Ptr{MDB_cursor},), cursor)
end

mdb_cursor_dbi(cursor) = checked_call(_mdb_cursor_dbi, cursor)

function _mdb_cursor_get(cursor, key, data, op)
    ccall((:mdb_cursor_get, liblmdb), Cint, (Ptr{MDB_cursor}, Ptr{MDB_val}, Ptr{MDB_val}, MDB_cursor_op), cursor, key, data, op)
end

mdb_cursor_get(cursor, key, data, op) = checked_call(_mdb_cursor_get, cursor, key, data, op)

function _mdb_cursor_put(cursor, key, data, flags)
    ccall((:mdb_cursor_put, liblmdb), Cint, (Ptr{MDB_cursor}, Ptr{MDB_val}, Ptr{MDB_val}, Cuint), cursor, key, data, flags)
end

mdb_cursor_put(cursor, key, data, flags) = checked_call(_mdb_cursor_put, cursor, key, data, flags)

function _mdb_cursor_del(cursor, flags)
    ccall((:mdb_cursor_del, liblmdb), Cint, (Ptr{MDB_cursor}, Cuint), cursor, flags)
end

mdb_cursor_del(cursor, flags) = checked_call(_mdb_cursor_del, cursor, flags)

function _mdb_cursor_count(cursor, countp)
    ccall((:mdb_cursor_count, liblmdb), Cint, (Ptr{MDB_cursor}, Ptr{Csize_t}), cursor, countp)
end

mdb_cursor_count(cursor, countp) = checked_call(_mdb_cursor_count, cursor, countp)

function _mdb_cmp(txn, dbi, a, b)
    ccall((:mdb_cmp, liblmdb), Cint, (Ptr{MDB_txn}, MDB_dbi, Ptr{MDB_val}, Ptr{MDB_val}), txn, dbi, a, b)
end

mdb_cmp(txn, dbi, a, b) = checked_call(_mdb_cmp, txn, dbi, a, b)

function _mdb_dcmp(txn, dbi, a, b)
    ccall((:mdb_dcmp, liblmdb), Cint, (Ptr{MDB_txn}, MDB_dbi, Ptr{MDB_val}, Ptr{MDB_val}), txn, dbi, a, b)
end

mdb_dcmp(txn, dbi, a, b) = checked_call(_mdb_dcmp, txn, dbi, a, b)

# typedef int ( MDB_msg_func ) ( const char * msg , void * ctx )
const MDB_msg_func = Cvoid

function _mdb_reader_list(env, func, ctx)
    ccall((:mdb_reader_list, liblmdb), Cint, (Ptr{MDB_env}, Ptr{Cvoid}, Ptr{Cvoid}), env, func, ctx)
end

mdb_reader_list(env, func, ctx) = checked_call(_mdb_reader_list, env, func, ctx)

function _mdb_reader_check(env, dead)
    ccall((:mdb_reader_check, liblmdb), Cint, (Ptr{MDB_env}, Ptr{Cint}), env, dead)
end

mdb_reader_check(env, dead) = checked_call(_mdb_reader_check, env, dead)

const MDB_VERSION_MAJOR = 0

const MDB_VERSION_MINOR = 9

const MDB_VERSION_PATCH = 27

#const MDB_VERSION_FULL = MDB_VERINT(MDB_VERSION_MAJOR, MDB_VERSION_MINOR, MDB_VERSION_PATCH)

const MDB_VERSION_DATE = "October 26, 2020"

#const MDB_VERSION_STRING = MDB_VERFOO(MDB_VERSION_MAJOR, MDB_VERSION_MINOR, MDB_VERSION_PATCH, MDB_VERSION_DATE)

const MDB_FIXEDMAP = 0x01

const MDB_NOSUBDIR = 0x4000

const MDB_NOSYNC = 0x00010000

const MDB_RDONLY = 0x00020000

const MDB_NOMETASYNC = 0x00040000

const MDB_WRITEMAP = 0x00080000

const MDB_MAPASYNC = 0x00100000

const MDB_NOTLS = 0x00200000

const MDB_NOLOCK = 0x00400000

const MDB_NORDAHEAD = 0x00800000

const MDB_NOMEMINIT = 0x01000000

const MDB_REVERSEKEY = 0x02

const MDB_DUPSORT = 0x04

const MDB_INTEGERKEY = 0x08

const MDB_DUPFIXED = 0x10

const MDB_INTEGERDUP = 0x20

const MDB_REVERSEDUP = 0x40

const MDB_CREATE = 0x00040000

const MDB_NOOVERWRITE = 0x10

const MDB_NODUPDATA = 0x20

const MDB_CURRENT = 0x40

const MDB_RESERVE = 0x00010000

const MDB_APPEND = 0x00020000

const MDB_APPENDDUP = 0x00040000

const MDB_MULTIPLE = 0x00080000

const MDB_CP_COMPACT = 0x01

const MDB_SUCCESS = 0

const MDB_KEYEXIST = -30799

const MDB_NOTFOUND = -30798

const MDB_PAGE_NOTFOUND = -30797

const MDB_CORRUPTED = -30796

const MDB_PANIC = -30795

const MDB_VERSION_MISMATCH = -30794

const MDB_INVALID = -30793

const MDB_MAP_FULL = -30792

const MDB_DBS_FULL = -30791

const MDB_READERS_FULL = -30790

const MDB_TLS_FULL = -30789

const MDB_TXN_FULL = -30788

const MDB_CURSOR_FULL = -30787

const MDB_PAGE_FULL = -30786

const MDB_MAP_RESIZED = -30785

const MDB_INCOMPATIBLE = -30784

const MDB_BAD_RSLOT = -30783

const MDB_BAD_TXN = -30782

const MDB_BAD_VALSIZE = -30781

const MDB_BAD_DBI = -30780

const MDB_LAST_ERRCODE = MDB_BAD_DBI

# exports
const PREFIXES = ["mdb_", "MDB_","_mdb_"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
