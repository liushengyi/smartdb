import Logger from './Logger'
import relationalStore from '@ohos.data.relationalStore'
import { ColumnType } from './ColumnType'
import "reflect-metadata"
import { DbHelper, getDbHelper } from './DbHelper'


export default class DbUtil {
  static ENTRY_NAME = 'smartdb:table'
  static COLUMN_TYPE = 'smartdb:type'
  static RETURN_TYPE_KEY = 'smartdb:returntype'
  static DB_NAME = 'smartdb:dbname'

  static handleSql(sql: string, result: (newSql, target, propertyKey) => Promise<any>) {
    return (target, propertyKey, descriptor) => {
      descriptor.value = function (...args) {
        let newSql = sql
        if (args.length > 0) {
          args.forEach((paramValue, index) => {
            let paramName = Reflect.getMetadata(index, target, propertyKey)
            let rawParam = Reflect.getMetadata(DbUtil.getRawMetadataKey(index), target, propertyKey)
            if (paramName) {
              if (DbUtil.isNumber(paramValue) || DbUtil.isBool(paramValue) || rawParam) {
                newSql = DbUtil.replaceAllParam(newSql, paramName, paramValue.toString())
              } else if (DbUtil.isObject(paramValue)) {
                Object.keys(paramValue).forEach((property) => {
                  let propertyValue = paramValue[`${property}`]
                  if (DbUtil.isNumber(propertyValue) || DbUtil.isBool(propertyValue)) {
                    newSql = DbUtil.replaceAllParam(newSql, `${paramName}.${property}`, propertyValue)
                  } else {
                    newSql = DbUtil.replaceAllParam(newSql, `${paramName}.${property}`, `'${propertyValue}'`)
                  }
                })
              } else {
                newSql = DbUtil.replaceAllParam(newSql, paramName, `'${paramValue}'`)
              }
            }
          })
        }
        Logger.debug(`${target.constructor.name}.${propertyKey} sql: ${newSql}`)
        return result(newSql, target, propertyKey)
      }
    }
  }

  private static replaceAllParam(str: string, value: string, newValue: any) {
    return str.replace(new RegExp(`#\\{${value}\\}`, "g"), newValue)
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