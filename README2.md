```bash
make setup-deps
```

Enable Kubernetes in Docker Desktop 

```bash
kind create cluster --name starship
```


```bash
make install

# list of all the contexts
kubectl config get-contexts
 
# set the context to docker-desktop
kubectl config use-context docker-desktop

# check nodes
kubectl get nodes
```

```bash
kubectl get pods

kubectl logs osmosis-1-genesis-0
kubectl logs gaia-1-genesis-0
kubectl logs hermes-osmos-gaia-0
kubectl logs explorer-767f58dcb-prszl
```

```bash
# expose ports to your host
make port-forward

# stop port forwarding
make stop
```


```bash
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"denom":"uatom","address":"cosmos12mcuu0n4haqq6yew3ay62zc8fyd0jncnu4lxtp"}' \
  http://localhost:8083/credit

curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"denom":"uosmo","address":"osmo12mcuu0n4haqq6yew3ay62zc8fyd0jncn5wvkan"}' \
  http://localhost:8082/credit
```


http://localhost:8081/chains/osmosis-1/keys
http://localhost:8081/chains/gaia-1/keys


```json
{
  "genesis": [
    {
      "name": "val0",
      "type": "local",
      "mnemonic": "razor dog gown public private couple ecology paper flee connect local robot diamond stay rude join sound win ribbon soup kidney glass robot vehicle"
    }
  ],
  "validators": [
    {
      "name": "val1",
      "type": "local",
      "mnemonic": "issue have volume expire shoe year finish poem alien urban license undo rural endless food host opera fix forum crack wide example firm learn"
    },
    {
      "name": "val2",
      "type": "local",
      "mnemonic": "broccoli robot upon blush rabbit squeeze fruit still lady antique detect can spice clay magic monster zebra solution dry salute stay wet arena matrix"
    },
    {
      "name": "val3",
      "type": "local",
      "mnemonic": "tornado modify spring arm title double bulk other recall decide table fun caught buyer bring once knife sphere arctic text zoo swim visual patient"
    },
    {
      "name": "val4",
      "type": "local",
      "mnemonic": "warm marine rent lift siege tool artwork home curious film blade trophy flush angry exact athlete edge combine weasel hour marriage grocery lake famous"
    }
  ],
  "keys": [
    {
      "name": "test1",
      "type": "local",
      "mnemonic": "opinion knife other balcony surge more bamboo canoe romance ask argue teach anxiety adjust spike mystery wolf alone torch tail six decide wash alley"
    },
    {
      "name": "test2",
      "type": "local",
      "mnemonic": "logic help only text door wealth hurt always remove glory viable income agent olive trial female couch old offer crash menu zero pencil thrive"
    },
    {
      "name": "test3",
      "type": "local",
      "mnemonic": "middle weather hip ghost quick oxygen awful library broken chicken tackle animal crunch appear fee indoor fitness enough orphan trend tackle faint eyebrow all"
    }
  ],
  "relayers": [
    {
      "name": "rly1",
      "type": "local",
      "mnemonic": "pen quit web pill hunt hobby tonight base wine black era cereal veteran trouble december method diet orbit copper nephew into badge olympic repair"
    },
    {
      "name": "rly2",
      "type": "local",
      "mnemonic": "rally area annual range egg solid paper kick cabbage relax grow ginger axis tone penalty swing marine endless vendor dinner guilt echo stable system"
    }
  ]
}
```

```bash
agd query ibc connection connections
connections:
- client_id: 07-tendermint-1
  counterparty:
    client_id: 07-tendermint-2
    connection_id: connection-1
    prefix:
      key_prefix: aWJj
  delay_period: "0"
  id: connection-0
  state: STATE_OPEN
  versions:
  - features:
    - ORDER_ORDERED
    - ORDER_UNORDERED
    identifier: "1"
height:
  revision_height: "21485"
  revision_number: "0"
pagination:
  next_key: null
  total: "0"
```
