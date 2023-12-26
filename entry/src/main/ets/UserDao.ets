import sql from "smartdb"

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

  @sql.SqlInsert("replace into db_user (id,name) values (#{user.id},#{user.name}) ")
  insertUser(@sql.Param("user") user: User): Promise<void> {
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
