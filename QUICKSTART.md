# Getting Started

## 1. First Time

1. Ensure all dependencies are installed - 
```bash
make setup-deps
```

2. Ensure Kubernetes is enabled in Docker

<img src="./docker-desktop-kubernetes.png" width="480px"></img>

3. If on Mac silicon, ensure Rosetta emulation is enabled.

4. Install Hermes, ensure it's in PATH (separate from Starship, but necessary for this demo)

```bash
# assumes rust is installed
cargo install ibc-relayer-cli --bin hermes --locked

# confirm hermes is installed
hermes version
> hermes 
```
[More detailed hermes install instructions](https://hermes.informal.systems/quick-start/installation.html#install-via-cargo)


## 2. Start Starship Service
```bash
# start the service with helm
helm install -f configs/starship.yaml starship-getting-started starship/devnet --version 0.1.48
```

```bash
# ensure the pods started
watch kubectl get pods
```

```bash
# forward ports
make port-forward
```

## 3. Start Agoric Chain

```bash
cd ~/agoric-sdk/packages/cosmic-swingset
make scenario2-setup scenario2-run-chain
```

## 4. Fund Relayer
```bash
cd ~/agoric-sdk/packages/cosmic-swingset
make ACCT_ADDR=agoric1gtkg0g6x8lqc734ht3qe2sdkrfugpdp2h7fuu0 FUNDS=2000000ubld fund-acct
```

## 5. Add keys to hermes
```bash
hermes keys add --chain agoriclocal --mnemonic-file keys/user-1.key
hermes keys add --chain osmosis-test --mnemonic-file keys/osmosis-1.key
```

## 6. Add clients, connection, and start Hermes
```bash
# create clients
hermes --config ./config.toml create client --host-chain agoriclocal --reference-chain osmosis-test
hermes --config ./config.toml create client --host-chain osmosis-test --reference-chain agoriclocal
# create connection between them
hermes --config ./config.toml create connection --a-chain agoriclocal --b-chain osmosis-test
# when successful, start client
hermes --config ./config.toml start
```

## 7. Start ag-solo + REPL 
```bash
cd ~/agoric-sdk/packages/cosmic-swingset
make scenario2-run-client
```

## 8. Create Account in REPL
```bash
agoric open --repl

# in REPL:
E(home.agoricNames).lookup('instance', 'stakeAtom')
E(home.zoe).getPublicFacet(history[n])
pf = history[n]
E(pf).providePort()
E(pf).provideAccount('main', 'connection-1', 'connection-0')
```


## Stop Starship Service
```bash
helm delete starship-getting-started
make stop-forward

# or, in one step:
make stop
```
