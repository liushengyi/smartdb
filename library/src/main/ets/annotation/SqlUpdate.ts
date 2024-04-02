import {Sql} from './Sql'

export function SqlUpdate(sql: string): MethodDecorator {
  return Sql(sql)
}