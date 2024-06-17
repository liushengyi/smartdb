import sql from 'smartdb';
import { userDao } from './UserDao';
import { userDao2 } from './UserDao2';
import relationalStore from '@ohos.data.relationalStore';
import hilog from '@ohos.hilog';

class AppDB {
  static DB_VERSION: number = 3

  initDb(context: Context) {
    sql.Logger.setLogLevel(hilog.LogLevel.DEBUG)
    sql.dbHelper.initDb(context, "test.db", AppDB.DB_VERSION, new AppDbOpenHelper())
    sql.createDbHelper("test2").initDb(context, "test2.db", AppDB.DB_VERSION, new AppDbOpenHelper2())
  }
}

class AppDbOpenHelper extends sql.DbOpenHelper {
  constructor() {
    super()
  }

  async onCreate(db: relationalStore.RdbStore) {
    //用户表
    await userDao.createDb()
  }

  async onUpgrade(db: relationalStore.RdbStore, oldVersion: number, newVersion: number) {
    if (oldVersion <= 2) {
      //升级操作
    }
  }
}

class AppDbOpenHelper2 extends sql.DbOpenHelper {
  constructor() {
    super()
  }

  async onCreate(db: relationalStore.RdbStore) {
    //用户表
    await userDao2.createDb()
  }

  async onUpgrade(db: relationalStore.RdbStore, oldVersion: number, newVersion: number) {
    if (oldVersion <= 2) {
      //升级操作
    }
  }
}

export default new AppDB()