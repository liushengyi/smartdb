import "reflect-metadata"

export function Param(name: string): ParameterDecorator {
  return (target, propertyKey, parameterIndex) => {
    // Logger.debug("%s.%s  param: %s  index: %d", target.constructor.name, propertyKey, name, parameterIndex)
    Reflect.defineMetadata(parameterIndex, name, target, propertyKey)
  }
}