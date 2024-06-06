import { makeAgoricChainStorageWatcher } from '@agoric/rpc';
import {
  agoricRegistryTypes,
  agoricConverters,
  makeAgoricWalletConnection,
} from '../../node_modules/@agoric/web-components/dist/index.js';
import { OfflineSigner, Registry } from '@cosmjs/proto-signing';
import {
  AminoTypes,
  defaultRegistryTypes,
  createBankAminoConverters,
  createAuthzAminoConverters,
  SigningStargateClient,
} from '@cosmjs/stargate';

export async function makeSmartWalletConnection({
  apiUrl,
  rpcUrl,
  chainName = 'agoriclocal',
  aminoSigner,
  address,
}: {
  apiUrl: string;
  rpcUrl: string;
  chainName: string;
  aminoSigner: OfflineSigner;
  address: string;
}) {
  const watcher = makeAgoricChainStorageWatcher(apiUrl, chainName);
  const signingStargateClient = await SigningStargateClient.connectWithSigner(
    rpcUrl,
    aminoSigner,
    {
      // @ts-expect-error Type 'AminoConverter | AminoConverter | "not_supported_by_chain"' is not assignable to type 'AminoConverter'.
      aminoTypes: new AminoTypes({
        ...agoricConverters,
        ...createBankAminoConverters(),
        ...createAuthzAminoConverters(),
      }),
      registry: new Registry([...defaultRegistryTypes, ...agoricRegistryTypes]),
    },
  );
  const agoricWalletConnection = await makeAgoricWalletConnection(
    watcher,
    rpcUrl,
    (e: unknown) => {
      console.error('wallet connection error', e);
    },
    // @ts-expect-error Type 'SigningStargateClient' is missing the following properties from type 'SigningStargateClient': tmClient, getTmClient, forceGetTmClient
    { address, client: signingStargateClient },
  );

  return agoricWalletConnection;
}
