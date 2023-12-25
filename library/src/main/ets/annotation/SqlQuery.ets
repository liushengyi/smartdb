import DbHelper from '../DbHelper'
import Logger from '../Logger'
import DbUtil from '../DbUtil'

export function SqlQuery(sql: string): MethodDecorator {
  return DbUtil.handleSql(sql, (newSql, target, propertyKey) => {
    return new Promise((resolve, reject) => {
      DbHelper.getRdbStore().then((store) => {
        store.querySql(newSql).then((result) => {
          resolve(DbUtil.parseResult(result, target, propertyKey))
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
