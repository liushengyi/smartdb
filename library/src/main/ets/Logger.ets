import hilog from '@ohos.hilog';

const DEFAULT_TAG: string = 'samrtdb';

class Logger {
  private domain: number;

  constructor(tag: string = DEFAULT_TAG, domain: number = 0xFF00) {
    this.domain = domain;
  }

  debug(message: any, ...args: any[]): void {
    hilog.debug(this.domain, DEFAULT_TAG, message.toString(), args);
  }

  info(message: any, ...args: any[]): void {
    hilog.info(this.domain, DEFAULT_TAG, message.toString(), args);
  }

  warn(message: any, ...args: any[]): void {
    hilog.warn(this.domain, DEFAULT_TAG, message.toString(), args);
  }

  error(message: any, ...args: any[]): void {
    if(message instanceof Error){
      message=`${message.message} ${message.stack}`
    }
    hilog.error(this.domain, DEFAULT_TAG, message.toString(), args);
  }

  d(tag: string, message: any, ...args: any[]): void {
    hilog.debug(this.domain, tag, message.toString(), args);
  }

  i(tag: string, message: any, ...args: any[]): void {
    hilog.info(this.domain, tag, message.toString(), args);
  }

  w(tag: string, message: any, ...args: any[]): void {
    hilog.warn(this.domain, tag, message.toString(), args);
  }

  e(tag: string, message: any, ...args: any[]): void {
    if(message instanceof Error){
      message=`${message.message} ${message.stack}`
    }
    hilog.error(this.domain, tag, message.toString(), args);
  }

}

export default new Logger();