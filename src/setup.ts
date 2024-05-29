import { useRegistry, useChain, ConfigContext } from 'starshipjs';
import { dirname, join } from 'path';

const configFile = join(
  dirname(new URL(import.meta.url).pathname),
  '../starship.yaml',
);

/**
 * @example
 * ```js
 * const { creditFromFaucet } = useChain('osmosis');
 * await creditFromFaucet('osmo1234');
 * ```
 */
export const setup = async () => {
  // Set the configuration file in StarshipJS
  ConfigContext.setConfigFile(configFile);

  ConfigContext.setRegistry(await useRegistry(ConfigContext.configFile!));

  return { useChain };
};
