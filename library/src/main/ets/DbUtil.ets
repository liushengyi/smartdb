import Logger from './Logger'
import relationalStore from '@ohos.data.relationalStore'
import { ColumnType } from './ColumnType'
import "reflect-metadata"


export default  class DbUtil {

  static ENTRY_NAME = '_table'
  static COLUMN_TYPE = '_type'
  static RETURN_TYPE_KEY = 'design:returntype'

  static handleSql(sql: string, result: (newSql, target, propertyKey) => Promise<any>) {
    return (target, propertyKey, descriptor) => {
      descriptor.value = function (...args) {
        let newSql = sql
        if (args.length > 0) {
          args.forEach((value, index) => {
            let param = Reflect.getMetadata(index, target, propertyKey)
            if (param) {
              if (DbUtil.isNumber(value) || DbUtil.isBool(value)) {
                newSql = newSql.replace(`#{${param}}`, value.toString())
              } else {
                newSql = newSql.replace(`#{${param}}`, `'${value}'`)
              }
            }
          })
        }
        Logger.debug("%s.%s sql: %s", target.constructor.name, propertyKey, newSql)
        return result(newSql, target, propertyKey)
      }
    }
  }

  static parseResult(resultSet: relationalStore.ResultSet, target, propertyKey): any {
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
}


