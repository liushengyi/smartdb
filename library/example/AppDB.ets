import sql from 'smartdb';
import { userDao } from './UserDao';
import relationalStore from '@ohos.data.relationalStore';
import hilog from '@ohos.hilog';

class AppDB {
  static DB_VERSION: number = 3

  initDb(context: Context) {
    sql.dbHelper.initDb(context, "test.db", AppDB.DB_VERSION, new AppDbOpenHelper())
    sql.Logger.setLogLevel(hilog.LogLevel.DEBUG)
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

export default new AppDB()