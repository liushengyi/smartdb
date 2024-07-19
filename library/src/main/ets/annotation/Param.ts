import "reflect-metadata"
import DbUtil from "../DbUtil"

/**
 * 参数
 * @param name 参数名
 * @param raw 是否显示原始数据（不对字符串类型添加""）
 * @returns
 */
export function Param(name: string, raw: boolean = false): ParameterDecorator {
  return (target, propertyKey, parameterIndex) => {
    // Logger.debug("%s.%s  param: %s  index: %d", target.constructor.name, propertyKey, name, parameterIndex)
    Reflect.defineMetadata(parameterIndex, name, target, propertyKey)
    Reflect.defineMetadata(DbUtil.getRawMetadataKey(parameterIndex), raw, target, propertyKey)
  }
}

