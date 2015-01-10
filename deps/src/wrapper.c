#include "stdlib.h"
#include "lmdb.h"

MDB_env* mdb_env_create_default() {
    MDB_env *env;
    int rc = mdb_env_create(&env);
    if(rc)
        env = NULL;
    return env;
}

MDB_txn* mdb_txn_start(MDB_env *env, unsigned int flags, int* ret) {
    MDB_txn *txn;
    int rc = mdb_txn_begin(env, NULL, flags, &txn);
    if(rc)
        txn = NULL;
    *ret = rc;
    return txn;
}

MDB_cursor* mdb_cursor_start(MDB_txn *txn, MDB_dbi dbi, int* ret) {
    MDB_cursor *cursor;
    int rc = mdb_cursor_open(txn, dbi, &cursor);
    if(rc)
        cursor = NULL;
    *ret = rc;
    return cursor;
}

MDB_val* mdb_make_val(size_t mv_size, void *mv_data) {
    MDB_val *val;
    val = calloc(1, sizeof(MDB_val));
    val->mv_size = mv_size;
    val->mv_data = mv_data;
    return val;
}

int mdb_kv_put(MDB_txn *txn, MDB_dbi dbi, size_t key_size, void *key_data, size_t data_size, void *data_data, unsigned int flags) {
    MDB_val key, data;
    key.mv_size = key_size;
    key.mv_data = key_data;
    data.mv_size = data_size;
    data.mv_data = data_data;
    int rc = mdb_put(txn, dbi, &key, &data, flags);
    return rc;
}

unsigned char* mdb_kv_get(MDB_txn *txn, MDB_dbi dbi, size_t key_size, void *key_data, size_t *data_size, int* rc) {
    unsigned char *data_data;

    MDB_val key, data;
    key.mv_size = key_size;
    key.mv_data = key_data;
    *rc = mdb_get(txn, dbi, &key, &data);
    if (rc) {
        *data_size = data.mv_size;
        data_data = data.mv_data;
    }
    return data_data;
}

int mdb_cursor_kv_put(MDB_cursor *cursor, size_t key_size, void *key_data, size_t data_size, void *data_data, unsigned int flags) {
    MDB_val key, data;
    key.mv_size = key_size;
    key.mv_data = key_data;
    data.mv_size = data_size;
    data.mv_data = data_data;
    int rc = mdb_cursor_put(cursor, &key, &data, flags);
    return rc;
}