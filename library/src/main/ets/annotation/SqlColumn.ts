import { ColumnType } from '../ColumnType'
import "reflect-metadata"
import DbUtil from '../DbUtil'

export function SqlColumn(type: ColumnType): PropertyDecorator {
  return (target, propertyKey) => {
    Reflect.defineMetadata(DbUtil.COLUMN_TYPE, type, target, propertyKey)
  }
}