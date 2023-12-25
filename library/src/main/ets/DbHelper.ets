import relationalStore from '@ohos.data.relationalStore';
import Logger from './Logger'
import dataPreferences from '@ohos.data.preferences';
import { DbOpenHelper } from './DbOpenHelper';

class DbHelper {
  dbContext: Context;
  dbName: string = '';
  dbVersion: number = 0
  rdbStore: relationalStore.RdbStore

  async initDb(context: Context, dbName: string, dbVersion: number, dbOpenHelper: DbOpenHelper) {
    if (dbVersion <= 0) {
      throw new Error("dbVersion must > 0");
    }
    this.dbContext = context;
    this.dbName = dbName;
    this.dbVersion = dbVersion
    if (this.rdbStore) {
      this.rdbStore = null
    }
    let dbPreferenceKey = `smartdb_preference`
    let dbVersionKey = `smartdb_version_${dbName}`
    let preferences = await dataPreferences.getPreferences(context, dbPreferenceKey)
    let oldVersion = (await preferences.get(dbVersionKey, 0)) as number

    if (this.dbVersion < oldVersion) {
      this.dbVersion = oldVersion
    }

    await this.getRdbStore()

    if (oldVersion != this.dbVersion) {
      await dbOpenHelper.onCreate(this.rdbStore)
      if (oldVersion < this.dbVersion) {
        this.beginTransaction()
        await dbOpenHelper.onUpgrade(this.rdbStore, oldVersion, this.dbVersion)
        this.commit()
      }
      await preferences.put(dbVersionKey, this.dbVersion)
      await preferences.flush()
    }
  }

  getRdbStore(): Promise<relationalStore.RdbStore> {
    return new Promise((resolve, reject) => {
      if (this.rdbStore) {
        resolve(this.rdbStore)
      } else {
        relationalStore.getRdbStore(this.dbContext, {
          name: this.dbName,
          securityLevel: relationalStore.SecurityLevel.S1
        }).then((store) => {
          this.rdbStore = store
          resolve(store)
        }).catch((e) => {
          Logger.error(e)
          reject(e)
        })
      }
    })
  }

  beginTransaction() {
    if (this.rdbStore) {
      Logger.debug("transaction begin")
      this.rdbStore.beginTransaction()
    }
  }

  commit() {
    if (this.rdbStore) {
      Logger.debug("transaction commit")
      this.rdbStore.commit()
    }
  }

  rollBack() {
    if (this.rdbStore) {
      Logger.debug("transaction rollBack")
      this.rdbStore.rollBack()
    }
  }
}

export default new DbHelper()
