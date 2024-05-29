import anyTest, { TestFn } from 'ava';
import { setup } from './setup.js';

const test = anyTest as TestFn<Record<string, never>>;

test('assets can be retrieved from config', async (t) => {
  const { useChain } = await setup();

  t.like(useChain('osmosis').chainInfo.nativeAssetList.assets, [
    {
      base: 'uosmo',
    },
    {
      base: 'uion',
    },
  ]);

  t.like(useChain('cosmos').chainInfo.nativeAssetList.assets, [
    {
      base: 'uatom',
    },
  ]);
});

test('staking info can be retrieved from config', async (t) => {
  const { useChain } = await setup();

  t.like(useChain('osmosis').chain.staking, {
    staking_tokens: [{ denom: 'uosmo' }],
    lock_duration: { time: '1209600s' },
  });

  t.like(useChain('cosmos').chain.staking, {
    staking_tokens: [{ denom: 'uatom' }],
    lock_duration: { time: '1209600s' },
  });
});
