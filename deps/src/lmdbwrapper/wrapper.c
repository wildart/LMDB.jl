#include "errno.h"
#include "stdlib.h"
#include "string.h"
#include "lmdb.h"

MDB_env* mdb_env_create_default() {
    MDB_env *env;
    int rc = mdb_env_create(&env);
    if(rc == ENOMEM)
        env = NULL;
    return env;
}

MDB_txn* mdb_txn_start(MDB_env *env, MDB_txn *parent, unsigned int flags) {
    MDB_txn *txn;
    int rc = mdb_txn_begin(env, parent, flags, &txn);
    if(!rc)
        txn = NULL;
    return txn;
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

void* mdb_kv_get(MDB_txn *txn, MDB_dbi dbi, size_t key_size, void *key_data, size_t *data_size, int* rc) {
    void *data_data;

    MDB_val key, data;
    key.mv_size = key_size;
    key.mv_data = key_data;
    *rc = mdb_get(txn, dbi, &key, &data);
    if (rc) {
        *data_size = data.mv_size;
        data_data = malloc(data.mv_size);
        memcpy(data_data, data.mv_data, data.mv_size);
    }
    return data_data;
}