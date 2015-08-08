# API-INDEX


## MODULE: LMDB

---

## Methods [Exported]

[abort(txn::LMDB.Transaction)](LMDB.md#method__abort.1)  Abandon all the operations of the transaction instead of saving them

[close(cur::LMDB.Cursor)](LMDB.md#method__close.1)  Close a cursor

[close(env::LMDB.Environment)](LMDB.md#method__close.2)  Close the environment and release the memory map

[close(env::LMDB.Environment,  dbi::LMDB.DBI)](LMDB.md#method__close.3)  Close a database handle

[commit(txn::LMDB.Transaction)](LMDB.md#method__commit.1)  Commit all the operations of a transaction into the database

[count(cur::LMDB.Cursor)](LMDB.md#method__count.1)  Return count of duplicates for current key

[create()](LMDB.md#method__create.1)  Create an LMDB environment handle

[create(f::Function)](LMDB.md#method__create.2)  Wrapper of `create` for `do` construct

[delete!(cur::LMDB.Cursor)](LMDB.md#method__delete.1)  Delete current key/data pair to which the cursor refers

[delete!(txn::LMDB.Transaction,  dbi::LMDB.DBI,  key,  val)](LMDB.md#method__delete.2)  Delete items from a database

[drop(txn::LMDB.Transaction,  dbi::LMDB.DBI)](LMDB.md#method__drop.1)  Empty or delete+close a database.

[getindex(env::LMDB.Environment,  option::Symbol)](LMDB.md#method__getindex.1)  Get environment flags and parameters

[get{T}(cur::LMDB.Cursor,  key,  ::Type{T})](LMDB.md#method__get.1)  Retrieve by cursor.

[get{T}(cur::LMDB.Cursor,  key,  ::Type{T},  op::LMDB.CursorOps)](LMDB.md#method__get.2)  Retrieve by cursor.

[get{T}(txn::LMDB.Transaction,  dbi::LMDB.DBI,  key,  ::Type{T})](LMDB.md#method__get.3)  Get items from a database

[info(env::LMDB.Environment)](LMDB.md#method__info.1)  Return information about the LMDB environment.

[isflagset(value,  flag)](LMDB.md#method__isflagset.1)   Check if binary flag is set in provided value

[isopen(cur::LMDB.Cursor)](LMDB.md#method__isopen.1)  Check if cursor is open

[isopen(dbi::LMDB.DBI)](LMDB.md#method__isopen.2)  Check if database is open

[isopen(env::LMDB.Environment)](LMDB.md#method__isopen.3)  Check if environment is open

[isopen(txn::LMDB.Transaction)](LMDB.md#method__isopen.4)  Check if transaction is open.

[open(env::LMDB.Environment,  path::AbstractString)](LMDB.md#method__open.1)  Open an environment handle

[open(f::Function,  txn::LMDB.Transaction)](LMDB.md#method__open.2)  Wrapper of DBI `open` for `do` construct

[open(f::Function,  txn::LMDB.Transaction,  dbi::LMDB.DBI)](LMDB.md#method__open.3)  Wrapper of Cursor `open` for `do` construct

[open(f::Function,  txn::LMDB.Transaction,  dbname::AbstractString)](LMDB.md#method__open.4)  Wrapper of DBI `open` for `do` construct

[open(txn::LMDB.Transaction)](LMDB.md#method__open.5)  Open a database in the environment

[open(txn::LMDB.Transaction,  dbi::LMDB.DBI)](LMDB.md#method__open.6)  Create a cursor

[open(txn::LMDB.Transaction,  dbname::AbstractString)](LMDB.md#method__open.7)  Open a database in the environment

[path(env::LMDB.Environment)](LMDB.md#method__path.1)  Return the path that was used in `open`

[put!(cur::LMDB.Cursor,  key,  val)](LMDB.md#method__put.1)  Store by cursor.

[put!(txn::LMDB.Transaction,  dbi::LMDB.DBI,  key,  val)](LMDB.md#method__put.2)  Store items into a database

[renew(txn::LMDB.Transaction)](LMDB.md#method__renew.1)  Renew a read-only transaction

[renew(txn::LMDB.Transaction,  cur::LMDB.Cursor)](LMDB.md#method__renew.2)  Renew a cursor

[reset(txn::LMDB.Transaction)](LMDB.md#method__reset.1)  Reset a read-only transaction

[set!(env::LMDB.Environment,  flag::UInt32)](LMDB.md#method__set.1)  Set environment flags

[setindex!(env::LMDB.Environment,  val::UInt32,  option::Symbol)](LMDB.md#method__setindex.1)  Set environment flags and parameters

[start(env::LMDB.Environment)](LMDB.md#method__start.1)  Create a transaction for use with the environment

[sync(env::LMDB.Environment)](LMDB.md#method__sync.1)  Flush the data buffers to disk

[sync(env::LMDB.Environment,  force::Bool)](LMDB.md#method__sync.2)  Flush the data buffers to disk

[unset!(env::LMDB.Environment,  flag::UInt32)](LMDB.md#method__unset.1)  Unset environment flags

---

## Types [Exported]

[LMDB.Cursor](LMDB.md#type__cursor.1)  A handle to a cursor structure for navigating through a database.

[LMDB.DBI](LMDB.md#type__dbi.1)  A handle for an individual database in the DB environment.

[LMDB.Environment](LMDB.md#type__environment.1)  A DB environment supports multiple databases, all residing in the same shared-memory map.

[LMDB.LMDBError](LMDB.md#type__lmdberror.1)  LMDB exception type

[LMDB.Transaction](LMDB.md#type__transaction.1)  A database transaction. Every operation requires a transaction handle.

---

## Methods [Internal]

[dbi(cur::LMDB.Cursor)](LMDB.md#method__dbi.1)  Return the cursor's database

[errormsg(err::Int32)](LMDB.md#method__errormsg.1)  Return a string describing a given error code

[flags(txn::LMDB.Transaction,  dbi::LMDB.DBI)](LMDB.md#method__flags.1)  Retrieve the DB flags for a database handle

[txn(cur::LMDB.Cursor)](LMDB.md#method__txn.1)  Return the cursor's transaction

[version()](LMDB.md#method__version.1)  Return the LMDB library version and version information

---

## Types [Internal]

[LMDB.EnvironmentInfo](LMDB.md#type__environmentinfo.1)  Information about the environment

[LMDB.MDBValue](LMDB.md#type__mdbvalue.1)  Generic structure used for passing keys and data in and out of the database.

