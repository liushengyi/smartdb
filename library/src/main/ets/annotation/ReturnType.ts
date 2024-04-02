import DbUtil from '../DbUtil';
import "reflect-metadata"

export function ReturnType(type): MethodDecorator {
  return (target, propertyKey, descriptor) => {
    Reflect.defineMetadata(DbUtil.RETURN_TYPE_KEY, type, target, propertyKey);
  }
}

export function ReturnListType(type): MethodDecorator {
  return (target, propertyKey, descriptor) => {
    Reflect.defineMetadata(DbUtil.RETURN_TYPE_KEY, [type], target, propertyKey);
  }
}