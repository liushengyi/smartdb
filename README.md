# smartdb

## 简介

> SmartDB (Room 鸿蒙版本)持久性库在 SQLite 的基础上提供了一个抽象层，让用户能够在充分利用 SQLite 的强大功能的同时，获享更强健的数据库访问机制

## 下载安装

```
ohpm install @ohos/smartdb --save
```

## 使用
### 1 创建UserDao
```ts
import sql from "@ohos/smartdb"

export class User {
  @sql.SqlColumn(sql.ColumnType.INTEGER)
  id: number
  @sql.SqlColumn(sql.ColumnType.TEXT)
  name: string

  constructor(id: number, name: string) {
    this.id = id
    this.name = name
  }
}

class UserDao {
  constructor() {
  }

  @sql.Sql("create table if not exists db_user ( id INTEGER PRIMARY KEY ,name TEXT not null)")
  createDb(): Promise<void> {
    return sql.PromiseNull()
  }

  @sql.SqlInsert("replace into db_user (id,name) values (#{id},#{name}) ")
  insert(@sql.Param("id") id: number, @sql.Param("name") name: string): Promise<void> {
    return sql.PromiseNull()
  }

  @sql.SqlQuery("select * from db_user where id=#{id}")
  @sql.ReturnType(User)
  findUser(@sql.Param("id") id: number): Promise<User> {
    return sql.PromiseNull()
  }

  @sql.SqlQuery("select name from db_user where id=#{id}")
  @sql.ReturnType(String)
  findUserName(@sql.Param("id") id: number): Promise<string> {
    return sql.PromiseNull()
  }

  @sql.SqlQuery("select * from db_user")
  @sql.ReturnType([User])
  findAll(): Promise<Array<User>> {
    return sql.PromiseNull()
  }

  @sql.SqlQuery("select id from db_user")
  @sql.ReturnType([Number])
  findAllIds(): Promise<Array<number>> {
    return sql.PromiseNull()
  }
  @sql.SqlQuery("select count(*) from db_user")
  @sql.ReturnType(Number)
  findAllCount(): Promise<Number> {
    return sql.PromiseNull()
  }

  @sql.SqlDelete("delete from db_user ")
  deleteAll(): Promise<void> {
    return sql.PromiseNull()
  }

}

export const userDao = new UserDao()

```
### 2 创建数据库管理
```ts
import sql from '@ohos/smartdb';
import { userDao } from './UserDao';
import relationalStore from '@ohos.data.relationalStore';

class AppDB {
  static DB_VERSION: number = 3

  initDb(context: Context) {
    sql.dbHelper.initDb(context, "test.db", AppDB.DB_VERSION, new AppDbOpenHelper())
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

```
### 3 UIAbility里初始化
```ets
import appDB from '../AppDB';

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    appDB.initDb(this.context)
  }
```

### 4 使用sql
```ets
import { userDao } from '../UserDao'
userDao.insert(100, "name100")
```