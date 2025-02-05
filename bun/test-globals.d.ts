declare global {
  // const suite: typeof import('bun:test')['suite']
  const test: typeof import('bun:test')['test']
  const describe: typeof import('bun:test')['describe']
  const it: typeof import('bun:test')['it']
  // const expectTypeOf: typeof import('bun:test')['expectTypeOf']
  // const assertType: typeof import('bun:test')['assertType']
  const expect: typeof import('bun:test')['expect']
  // const assert: typeof import('bun:test')['assert']
  // const vitest: typeof import('bun:test')['bun:test']
  // const vi: typeof import('bun:test')['vitest']
  const beforeAll: typeof import('bun:test')['beforeAll']
  const afterAll: typeof import('bun:test')['afterAll']
  const beforeEach: typeof import('bun:test')['beforeEach']
  const afterEach: typeof import('bun:test')['afterEach']
  // const onTestFailed: typeof import('bun:test')['onTestFailed']
  // const onTestFinished: typeof import('bun:test')['onTestFinished']
}
export {}
