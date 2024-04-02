/**
 * 在方法中开启事务
 * 注解的方法必须是 async方法
 * @returns
 */
import DbHelper from '../DbHelper'
import Logger from '../Logger'

export function Transactional(): MethodDecorator {
  return (target, propertyKey, descriptor) => {
    let original = descriptor.value
    // @ts-ignore
    descriptor.value = async function (...args) {
      DbHelper.beginTransaction()
      try {
        // @ts-ignore
        let result = await original.call(this, ...args);
        DbHelper.commit()
        return result
      } catch (e) {
        Logger.error(e)
        DbHelper.rollBack()
        throw e
      }
    }
  }
}