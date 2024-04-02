import {Sql} from './Sql'

export function SqlDelete(sql: string): MethodDecorator {
  return Sql(sql)
}