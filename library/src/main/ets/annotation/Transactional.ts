/**
 * 在方法中开启事务
 * 注解的方法必须是 async方法
 * @returns
 */
import Logger from '../Logger'
import DbUtil from "../DbUtil"

export function Transactional(): MethodDecorator {
  return (target, propertyKey, descriptor) => {
    let original = descriptor.value
    // @ts-ignore
    descriptor.value = async function (...args) {
      let dbHelper = DbUtil.getDbHelperByDecorator(target, propertyKey)
      dbHelper.beginTransaction()
      try {
        // @ts-ignore
        let result = await original.call(this, ...args);
        dbHelper.commit()
        return result
      } catch (e) {
        Logger.error(e)
        dbHelper.rollBack()
        throw e
      }
    }
  }
}