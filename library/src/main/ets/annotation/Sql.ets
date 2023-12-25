import DbHelper from '../DbHelper'
import Logger from '../Logger'
import DbUtil from '../DbUtil'

export function Sql(sql: string): MethodDecorator {
  return DbUtil.handleSql(sql, (newSql) => {
    return new Promise((resolve, reject) => {
      DbHelper.getRdbStore().then((store) => {
        store.executeSql(newSql).then(() => {
          // @ts-ignore
          resolve()
        }).catch((e) => {
          Logger.error(e)
          reject(e)
        })
      }).catch((e) => {
        Logger.error(e)
        reject(e)
      })
    })
  })
}