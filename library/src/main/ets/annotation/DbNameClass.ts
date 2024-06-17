import "reflect-metadata"
import DbUtil from '../DbUtil'
import  Logger from "../Logger"

/**
 * 定义数据库名（支持多数据源）
 * @param name
 * @returns
 * @param name 创建时传入的key或者数据库名
 * @returns
 */
export function DbNameClass(name: string = "default"): ClassDecorator  {
  return (target) => {
    Reflect.defineMetadata(DbUtil.DB_NAME, name, target)
  }
}