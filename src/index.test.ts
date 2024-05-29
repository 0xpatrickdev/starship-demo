import anyTest, { TestFn } from 'ava';

const test = anyTest as TestFn<Record<string, never>>;

test('hello world', async (t) => {
  t.pass();
});
