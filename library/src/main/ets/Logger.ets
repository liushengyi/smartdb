import hilog from '@ohos.hilog';

const DEFAULT_TAG: string = 'samrtdb';

class Logger {
  private domain: number;
  private logLevel: hilog.LogLevel = hilog.LogLevel.DEBUG

  constructor(domain: number = 0xFF00) {
    this.domain = domain;
  }

  setLogLevel(level: hilog.LogLevel) {
    this.logLevel = level
  }

  debug(message: any, ...args: any[]): void {
    if (!this.checkLogLevel(hilog.LogLevel.DEBUG)) {
      return
    }
    hilog.debug(this.domain, DEFAULT_TAG, message.toString(), args);
  }

  info(message: any, ...args: any[]): void {
    if (!this.checkLogLevel(hilog.LogLevel.INFO)) {
      return
    }
    hilog.info(this.domain, DEFAULT_TAG, message.toString(), args);
  }

  warn(message: any, ...args: any[]): void {
    if (!this.checkLogLevel(hilog.LogLevel.WARN)) {
      return
    }
    hilog.warn(this.domain, DEFAULT_TAG, message.toString(), args);
  }

  error(message: any, ...args: any[]): void {
    if (!this.checkLogLevel(hilog.LogLevel.ERROR)) {
      return
    }
    if (message instanceof Error) {
      message = `${message.message} ${message.stack}`
    }
    hilog.error(this.domain, DEFAULT_TAG, message.toString(), args);
  }

  d(tag: string, message: any, ...args: any[]): void {
    if (!this.checkLogLevel(hilog.LogLevel.DEBUG)) {
      return
    }
    hilog.debug(this.domain, tag, message.toString(), args);
  }

  i(tag: string, message: any, ...args: any[]): void {
    if (!this.checkLogLevel(hilog.LogLevel.INFO)) {
      return
    }
    hilog.info(this.domain, tag, message.toString(), args);
  }

  w(tag: string, message: any, ...args: any[]): void {
    if (!this.checkLogLevel(hilog.LogLevel.WARN)) {
      return
    }
    hilog.warn(this.domain, tag, message.toString(), args);
  }

  e(tag: string, message: any, ...args: any[]): void {
    if (!this.checkLogLevel(hilog.LogLevel.ERROR)) {
      return
    }
    if (message instanceof Error) {
      message = `${message.message} ${message.stack}`
    }
    hilog.error(this.domain, tag, message.toString(), args);
  }

  private checkLogLevel(level: hilog.LogLevel): boolean {
    return this.logLevel >= level
  }
}

export default new Logger();