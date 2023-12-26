import sql from 'smartdb'
import { User, userDao } from '../UserDao'

@Entry
@Component
struct Index {
  insertId: number = 2000

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
        Button("插入数据").onClick(() => {
          try {
            this.insert()
          } catch (e) {
            sql.Logger.error(e)
          }
        })
        Button("插入User").onClick(() => {
          try {
            this.insertUser()
          } catch (e) {
            sql.Logger.error(e)
          }
        })
        Button("插入数据(事务)").onClick(() => {
          try {
            this.insertTr()
          } catch (e) {
            sql.Logger.error(e)
          }
        })
      }.width('100%').margin({ bottom: '10vp' })

      Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
        Button("查找单一数据").onClick(() => {
          userDao.findUser(this.insertId).then((result) => {
            sql.Logger.info(JSON.stringify(result))
          })
        })
        Button("查找单一数据name").onClick(() => {
          userDao.findUserName(this.insertId).then((result) => {
            sql.Logger.info(JSON.stringify(result))
          })
        })
      }.width('100%').margin({ bottom: '10vp' })

      Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
        Button("查找所有数据").onClick(() => {
          userDao.findAll().then((result) => {
            sql.Logger.info(JSON.stringify(result))
          })
        })
        Button("查找所有数据id").onClick(() => {
          userDao.findAllIds().then((result) => {
            sql.Logger.info(JSON.stringify(result))
          })
        })
        Button("查找所有数据count").onClick(() => {
          userDao.findAllCount().then((result) => {
            sql.Logger.info(JSON.stringify(result))
          })
        })
      }.width('100%').margin({ bottom: '10vp' })

      Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
        Button("删除所有数据").onClick(() => {
          userDao.deleteAll().then((result) => {
            sql.Logger.info("删除成功")
          })
        })
      }.width('100%').margin({ bottom: '10vp' })
    }
  }

  randomGenInsertId() {
    this.insertId = Math.floor(Math.random() * 100_000_100)
  }

  async insert() {
    this.randomGenInsertId()
    sql.Logger.info("开始插入：" + this.insertId)
    await userDao.insert(this.insertId, "name" + this.insertId)
    sql.Logger.info("插入成功")

    this.randomGenInsertId()
    sql.Logger.info("开始插入：" + this.insertId)
    let insertId2 = await userDao.insertReturnRowId("name" + this.insertId)
    sql.Logger.info("插入成功:" + insertId2)
  }

  async insertUser() {
    this.randomGenInsertId()
    sql.Logger.info("开始插入：" + this.insertId)
    let insertId = await userDao.insertUser(new User(this.insertId, "name" + this.insertId))
    sql.Logger.info("插入成功:" + insertId)
  }

  @sql.Transactional()
  async insertTr() {
    this.randomGenInsertId()
    sql.Logger.info("开始插入：" + this.insertId)
    await userDao.insert(this.insertId, "name" + this.insertId)

    this.randomGenInsertId()
    sql.Logger.info("开始插入2：" + this.insertId)
    await userDao.insert(this.insertId, "name" + this.insertId)
    throw new Error("插入错误")
  }
}