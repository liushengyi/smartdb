import DbHelper from '../DbHelper'
import DbUtil from '../DbUtil'
import Logger from '../Logger'
import relationalStore from '@ohos.data.relationalStore'

/**
 * 数据插入
 * @param sql 插入sql
 * @param genId（table:表名；id:自增id名） 获取自增id配置
 * @returns
 */
export function SqlInsert(sql: string, genId?: {
  table: string,
  id: string
}): MethodDecorator {
  return DbUtil.handleSql(sql, (newSql) => {
    return new Promise(async (resolve, reject) => {
      let resultSet: relationalStore.ResultSet = null
      try {
        let rdbStore = await DbHelper.getRdbStore()
        await rdbStore.executeSql(newSql)
        if (genId && genId.table && genId.id) {
          resultSet = await rdbStore.querySql(`SELECT max(${genId.id}) from ${genId.table}`)
          resultSet.goToFirstRow()
          resolve(resultSet.getLong(0))
        } else {
          // @ts-ignore
          resolve()
        }
      } catch (e) {
        Logger.error(e)
        reject(e)
      } finally {
        if (resultSet) {
          resultSet.close()
        }
      }
    })
  })
}