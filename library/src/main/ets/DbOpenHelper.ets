import relationalStore from '@ohos.data.relationalStore';

export abstract class DbOpenHelper{

  abstract onCreate(db: relationalStore.RdbStore)

  abstract onUpgrade(db: relationalStore.RdbStore, oldVersion: number, newVersion: number)

}