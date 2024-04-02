export function PromiseNull<T>() {
  return new Promise<T>((resolve, reject) => {
    resolve(null)
  })
}