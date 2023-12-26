import DbHelper from '../DbHelper'
import Logger from '../Logger'
import DbUtil from '../DbUtil'

export function Sql(sql: string): MethodDecorator {
  return DbUtil.handleSql(sql, (newSql) => {
    return new Promise(async (resolve, reject) => {
      try {
        let rdbStore = await DbHelper.getRdbStore()
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