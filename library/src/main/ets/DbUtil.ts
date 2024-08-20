import Logger from './Logger'
import { ColumnType } from './ColumnType'
import "reflect-metadata"
import { DbHelper, getDbHelper } from './DbHelper'
import { relationalStore } from '@kit.ArkData'

const REGEX_PARAMS = /#\{[^}]+\}/g

export default class DbUtil {
  static ENTRY_NAME = 'smartdb:table'
  static COLUMN_TYPE = 'smartdb:type'
  static RETURN_TYPE_KEY = 'smartdb:returntype'
  static DB_NAME = 'smartdb:dbname'

  static handleSql(sql: string, result: (newSql: string, bindArgs: Array<relationalStore.ValueType>, target, propertyKey) => Promise<any>) {
    return (target, propertyKey, descriptor) => {
      descriptor.value = function (...args) {
        let newSql = sql
        let bindArgs = []
        if (args.length > 0) {
          let sqlParams = DbUtil.parseSqlParams(sql)
          let params = DbUtil.parseParams(args, target, propertyKey)

          for (let i = 0; i < sqlParams.length; i++) {
            let sqlParam: SqlParamInfo = sqlParams[i]
            for (let j = 0; j < params.length; j++) {
              let param: ParamInfo = params[j]
              let paramValue = param.value
              if (DbUtil.isObject(paramValue)) {
                let objKeys = Object.keys(paramValue)
                for (let k = 0; k < objKeys.length; k++) {
                  let objKey = objKeys[k]
                  if (sqlParam.prop === `${param.name}.${objKey}`) {
                    bindArgs.push(paramValue[`${objKey}`])
                    //替换第一个为"？"
                    newSql = newSql.replace(sqlParam.propRaw, "?")
                    break
                  }
                }
              } else {
                //raw参数不使用bindArgs
                if (param.raw) {
                  continue
                }
                if (sqlParam.prop === param.name) {
                  bindArgs.push(param.value)
                  //替换第一个为"？"
                  newSql = newSql.replace(sqlParam.propRaw, "?")
                  break
                }
              }
            }
          }

          //处理raw参数
          for (let j = 0; j < params.length; j++) {
            let param: ParamInfo = params[j]
            if (param.raw) {
              newSql = DbUtil.replaceAllParam(newSql, param.name, param.value.toString())
            }
          }
        }
        Logger.debug(`${target.constructor.name}.${propertyKey} sql: ${newSql} bindArgs: ${bindArgs.toString()}`)
        return result(newSql, bindArgs, target, propertyKey)
      }
    }
  }

  private static replaceAllParam(str: string, value: string, newValue: any) {
    return str.replace(new RegExp(`#\\{${value}\\}`, "g"), newValue)
  }

  /**
   * 解析sql语句中的参数
   * @param sql
   * @returns
   */
  private static parseSqlParams(sql: string): SqlParamInfo[] {
    let paramInfos: SqlParamInfo[] = []
    let match
    let index = 0
    while ((match = REGEX_PARAMS.exec(sql)) !== null) {
      let m: string = match[0]
      let p: SqlParamInfo = {
        index: index,
        propRaw: m,
        prop: m.replace("#{", "").replace("}", "")
      }
      paramInfos.push(p)
      index++
    }
    return paramInfos
  }

  /**
   * 解析参数信息
   * @param args
   * @param target
   * @param propertyKey
   * @returns
   */
  private static parseParams(args: any[], target, propertyKey): ParamInfo[] {
    let paramInfos: ParamInfo[] = []
    args.forEach((paramValue, index) => {
      let paramName = Reflect.getMetadata(index, target, propertyKey)
      let rawParam = Reflect.getMetadata(DbUtil.getRawMetadataKey(index), target, propertyKey)
      let p: ParamInfo = {
        name: paramName,
        value: paramValue,
        raw: rawParam
      }
      paramInfos.push(p)
    })
    return paramInfos
  }

  static getDbHelperByDecorator(target, propertyKey): DbHelper {
    let dbNameKey = Reflect.getMetadata(DbUtil.DB_NAME, target, propertyKey)
    if (dbNameKey == null || dbNameKey == undefined) {
      dbNameKey = Reflect.getMetadata(DbUtil.DB_NAME, target.constructor)
    }
    if (dbNameKey == null || dbNameKey == undefined) {
      dbNameKey = "default"
    }
    Logger.debug(`当前数据库：${dbNameKey}`)
    let dbHelper = getDbHelper(dbNameKey)
    if (dbHelper == undefined) {
      throw new Error(`请先初始化db: ${dbNameKey}`)
    }
    return dbHelper
  }

  static parseResult(resultSet: relationalStore.ResultSet, target, propertyKey): any {
    try {
      let hasResult = resultSet.goToFirstRow()
      let returnType = Reflect.getMetadata(DbUtil.RETURN_TYPE_KEY, target, propertyKey)
      if (returnType == null) {
        returnType = String
      }

      if (!hasResult) {
        if (Array.isArray(returnType)) {
          return []
        } else {
          return null;
        }
      }

      if (DbUtil.isArray(returnType)) {
        let entryType = returnType[0]
        let result = []
        let basicType = DbUtil.isBasicType(entryType)
        for (let i = 0; i < resultSet.rowCount; i++) {
          if (basicType) {
            result.push(DbUtil.readBasicType(resultSet, entryType))
          } else {
            result.push(DbUtil.readEntry(resultSet, entryType))
          }
          resultSet.goToNextRow()
        }
        return result
      } else if (DbUtil.isBasicType(returnType)) {
        return DbUtil.readBasicType(resultSet, returnType)
      } else {
        return DbUtil.readEntry(resultSet, returnType)
      }
    } finally {
      resultSet.close()
    }
  }

  static readBasicType(resultSet: relationalStore.ResultSet, returnType) {
    if (DbUtil.isString(returnType)) {
      return resultSet.getString(0)
    } else if (DbUtil.isNumber(returnType)) {
      return resultSet.getLong(0)
    } else if (DbUtil.isBool(returnType)) {
      return resultSet.getLong(0) ? true : false
    }
    return null
  }

  static readEntry(resultSet: relationalStore.ResultSet, entryType) {
    let entry = new entryType()
    let columnNames = resultSet.columnNames
    columnNames.forEach((columnName) => {
      let columnType: ColumnType = Reflect.getMetadata(DbUtil.COLUMN_TYPE, entry, columnName)
      if (columnType == null) {
        columnType = ColumnType.TEXT
      }
      switch (columnType) {
        case ColumnType.TEXT:
          entry[columnName] = resultSet.getString(resultSet.getColumnIndex(columnName))
          break
        case ColumnType.INTEGER:
          entry[columnName] = resultSet.getLong(resultSet.getColumnIndex(columnName))
          break
        case ColumnType.FLOAT:
          entry[columnName] = resultSet.getDouble(resultSet.getColumnIndex(columnName))
          break
        case ColumnType.BOOL:
          entry[columnName] = resultSet.getDouble(resultSet.getColumnIndex(columnName)) ? true : false
          break
        case ColumnType.BLOB:
          entry[columnName] = resultSet.getBlob(resultSet.getColumnIndex(columnName))
          break
      }
    })
    return entry
  }

  static getRawMetadataKey(parameterIndex) {
    return `raw_${parameterIndex}`
  }

  private static isArray(entryType) {
    return Array.isArray(entryType)
  }

  private static isBasicType(entryType) {
    return DbUtil.isString(entryType) || DbUtil.isNumber(entryType) || DbUtil.isBool(entryType)
  }

  private static isString(entryType) {
    return typeof entryType === 'string' || (typeof entryType === 'function' && entryType.name === 'String')
  }

  private static isNumber(entryType) {
    return typeof entryType === 'number' || (typeof entryType === 'function' && entryType.name === 'Number')
  }

  private static isBool(entryType) {
    return typeof entryType === 'boolean' || (typeof entryType === 'function' && entryType.name === 'Boolean')
  }

  private static isObject(entryType) {
    return typeof entryType === 'object'
  }
}

/**
 * sql语句中参数信息
 */
class SqlParamInfo {
  /**
   * 参数序列
   */
  index: number
  /**
   * 匹配的参数raw:  #{aa}
   */
  propRaw: string
  /**
   * 匹配的参数值： aa
   */
  prop: string
}

/**
 * 传参信息
 */
class ParamInfo {
  /**
   * 参数名
   */
  name: string
  /**
   * 参数值
   */
  value: any
  /**
   * 是否显示原始数据
   */
  raw: boolean
}
