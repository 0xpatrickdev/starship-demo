import anyTest, { LogFn, TestFn } from 'ava';
import { setup } from './setup.js';
import { createWallet } from './tools/wallet.js';
import { makeQueryClient } from './tools/query.js';

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

test('create a wallet and get tokens', async (t) => {
  const { useChain } = await setup();

  const prefix = useChain('osmosis').chain.bech32_prefix;
  const wallet = await createWallet(prefix);
  const addr = (await wallet.getAccounts())[0].address;
  t.regex(addr, /^osmo1/);
  t.log('Made temp wallet:', addr);

  const apiUrl = useChain('osmosis').getRestEndpoint();
  const queryClient = makeQueryClient(apiUrl);
  t.log('Made query client');

  const { balances } = await queryClient.queryBalances(addr);
  t.log('Beginning balances:', balances);
  t.deepEqual(balances, []);

  const osmosisFaucet = useChain('osmosis').creditFromFaucet;
  await osmosisFaucet(addr);
  await sleep(1000, t.log); // needed to avoid race condition

  const { balances: updatedBalances } = await queryClient.queryBalances(addr);
  t.like(updatedBalances, [{ denom: 'uosmo', amount: '10000000000' }]);
  t.log('Updated balances:', updatedBalances);

  const bondDenom =
    useChain('osmosis').chain.staking?.staking_tokens?.[0].denom;
  if (!bondDenom) throw new Error('Bond denom not found.');
  const { balance } = await queryClient.queryBalance(addr, bondDenom);
  t.deepEqual(balance, { denom: bondDenom, amount: '10000000000' });
});

const sleep = (ms: number, log?: LogFn) =>
  new Promise((resolve) => {
    if (log) log(`Sleeping for ${ms}ms...`);
    setTimeout(resolve, ms);
  });

test.todo('sign and broadcast a wallet transaction');
