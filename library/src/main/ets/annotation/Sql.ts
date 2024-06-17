import Logger from '../Logger'
import DbUtil from '../DbUtil'

export function Sql(sql: string): MethodDecorator {
  return DbUtil.handleSql(sql, (newSql, target, propertyKey) => {
    return new Promise(async (resolve, reject) => {
      try {
        let dbHelper = DbUtil.getDbHelperByDecorator(target, propertyKey)
        let rdbStore = await dbHelper.getRdbStore()
        await rdbStore.executeSql(newSql)
        // @ts-ignore
        resolve()
      } catch (e) {
        Logger.error(e)
        reject(e)
      }
    })
  })
}