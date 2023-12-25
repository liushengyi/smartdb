import {Sql} from './Sql'

export function SqlInsert(sql: string): MethodDecorator {
  return Sql(sql)
}