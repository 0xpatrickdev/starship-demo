#!/bin/bash

set -eux

DENOM="${DENOM:=uosmo}"
COINS="${COINS:=100000000000000000uosmo}"
CHAIN_ID="${CHAIN_ID:=osmosis}"
CHAIN_BIN="${CHAIN_BIN:=osmosisd}"
CHAIN_DIR="${CHAIN_DIR:=$HOME/.osmosisd}"

KEYS_JSON_STRING='{"genesis":[{"name":"genesis","type":"local","mnemonic":"razor dog gown public private couple ecology paper flee connect local robot diamond stay rude join sound win ribbon soup kidney glass robot vehicle"}],"validators":[{"name":"validator","type":"local","mnemonic":"issue have volume expire shoe year finish poem alien urban license undo rural endless food host opera fix forum crack wide example firm learn"}],"faucet":[{"name":"faucet","type":"local","mnemonic":"chimney become stuff spoil resource supply picture divorce casual curve check web valid survey zebra various pet sphere timber friend faint blame mansion film"}],"keys":[{"name":"test1","type":"local","mnemonic":"opinion knife other balcony surge more bamboo canoe romance ask argue teach anxiety adjust spike mystery wolf alone torch tail six decide wash alley"},{"name":"test2","type":"local","mnemonic":"logic help only text door wealth hurt always remove glory viable income agent olive trial female couch old offer crash menu zero pencil thrive"},{"name":"test3","type":"local","mnemonic":"middle weather hip ghost quick oxygen awful library broken chicken tackle animal crunch appear fee indoor fitness enough orphan trend tackle faint eyebrow all"}],"relayers":[{"name":"relayer1","type":"local","mnemonic":"pen quit web pill hunt hobby tonight base wine black era cereal veteran trouble december method diet orbit copper nephew into badge olympic repair"},{"name":"relayer2","type":"local","mnemonic":"spatial major zebra crew space file thunder fatigue wool viable cry kiss wedding dumb eager dream soon north coral suffer salt mutual kitten surface"},{"name":"relayer3","type":"local","mnemonic":"cruise topic shrug relax update slot marble valid chat upset offer cruise list frog machine fossil help dentist hard thunder dial wink light long"},{"name":"relayer4","type":"local","mnemonic":"carpet maid isolate side tonight crash doctor awkward balcony lift brand can affair address cube box print senior organ city ride argue board depth"},{"name":"relayer5","type":"local","mnemonic":"dad rural bridge own habit menu balance loan height rotate suit gym antenna convince traffic carry orphan service tower fatigue lady van prepare glide"}],"relayers_cli":[{"name":"relayer-cli-1","type":"local","mnemonic":"marine suspect wood vague vast pet cargo tenant oyster tuna news river follow chicken shoulder ceiling guess never help dismiss grape scheme oyster produce"},{"name":"relayer-cli-2","type":"local","mnemonic":"resemble pear bulb portion refuse off hundred kit flame hurry evidence fringe fetch kite strike actual naive stamp burden oak punch fault approve message"},{"name":"relayer-cli-3","type":"local","mnemonic":"cycle opinion segment gas season exclude artist cliff believe seminar salute bicycle math puzzle wreck minor country rough choose escape access warm expect february"},{"name":"relayer-cli-4","type":"local","mnemonic":"essay lobster image grain faculty vocal glass merry fish resist hub game suffer rose fence vocal network absurd demise demise repair museum envelope abstract"},{"name":"relayer-cli-5","type":"local","mnemonic":"adjust stove name refuse vehicle hip alpha steel dynamic alley ride segment exhibit pony abuse figure type close direct animal bomb food glass seed"}]}'

#KEYS_CONFIG="${KEYS_CONFIG:=configs/keys.json}"

FAUCET_ENABLED="${FAUCET_ENABLED:=true}"
NUM_VALIDATORS="${NUM_VALIDATORS:=1}"
NUM_RELAYERS="${NUM_RELAYERS:=0}"

echo "CHAIN ID $CHAIN_ID"

# check if the binary has genesis subcommand or not, if not, set CHAIN_GENESIS_CMD to empty
CHAIN_GENESIS_CMD=$($CHAIN_BIN 2>&1 | grep -q "genesis-related subcommands" && echo "genesis" || echo "")

echo "$KEYS_JSON_STRING" | jq -r '.genesis[0].mnemonic' | $CHAIN_BIN init $CHAIN_ID --chain-id $CHAIN_ID --recover

# Add genesis keys to the keyring and self delegate initial coins
echo "Adding key...." $(echo "$KEYS_JSON_STRING" | jq -r '.genesis[0].name')
echo "$KEYS_JSON_STRING" | jq -r '.genesis[0].mnemonic' | $CHAIN_BIN keys add $(echo "$KEYS_JSON_STRING" | jq -r '.genesis[0].name') --recover --keyring-backend="test"
$CHAIN_BIN $CHAIN_GENESIS_CMD add-genesis-account $($CHAIN_BIN keys show -a $(echo "$KEYS_JSON_STRING" | jq -r '.genesis[0].name') --keyring-backend="test") $COINS --keyring-backend="test"

# Add faucet key to the keyring and self delegate initial coins
echo "Adding key...." $(echo "$KEYS_JSON_STRING" | jq -r '.faucet[0].name')
echo "$KEYS_JSON_STRING" | jq -r '.faucet[0].mnemonic' | $CHAIN_BIN keys add $(echo "$KEYS_JSON_STRING" | jq -r '.faucet[0].name') --recover --keyring-backend="test"
$CHAIN_BIN $CHAIN_GENESIS_CMD add-genesis-account $($CHAIN_BIN keys show -a $(echo "$KEYS_JSON_STRING" | jq -r '.faucet[0].name') --keyring-backend="test") $COINS --keyring-backend="test"

if [[ $FAUCET_ENABLED == "false" && $NUM_RELAYERS -gt "-1" ]];
then
  ## Add relayers keys and delegate tokens
  for i in $(seq 0 $NUM_RELAYERS);
  do
    # Add relayer key and delegate tokens
    RELAYER_KEY_NAME="$(echo "$KEYS_JSON_STRING" | jq -r ".relayers[$i].name")"
    echo "Adding relayer key.... $RELAYER_KEY_NAME"
    echo "$KEYS_JSON_STRING" | jq -r ".relayers[$i].mnemonic" | $CHAIN_BIN keys add $RELAYER_KEY_NAME --recover --keyring-backend="test"
    $CHAIN_BIN $CHAIN_GENESIS_CMD add-genesis-account $($CHAIN_BIN keys show -a $RELAYER_KEY_NAME --keyring-backend="test") $COINS --keyring-backend="test"
    # Add relayer-cli key and delegate tokens
    RELAYER_CLI_KEY_NAME="$(echo "$KEYS_JSON_STRING" | jq -r ".relayers_cli[$i].name")"
    RELAYER_CLI_MNEMONIC="$(echo "$KEYS_JSON_STRING" | jq -r ".relayers_cli[$i].mnemonic")"
    if [[ -n "$RELAYER_CLI_MNEMONIC" ]]; then
      echo "Adding relayer-cli key.... $RELAYER_CLI_KEY_NAME"
      echo "$RELAYER_CLI_MNEMONIC" | $CHAIN_BIN keys add $RELAYER_CLI_KEY_NAME --recover --keyring-backend="test"
      $CHAIN_BIN $CHAIN_GENESIS_CMD add-genesis-account $($CHAIN_BIN keys show -a $RELAYER_CLI_KEY_NAME --keyring-backend="test") $COINS --keyring-backend="test"
    else
      echo "Skipping relayer-cli key $RELAYER_CLI_KEY_NAME due to missing mnemonic"
    fi
  done
fi

## if facuet not enabled then add validator and relayer with index as keys and into gentx
if [[ $FAUCET_ENABLED == "false" && $NUM_VALIDATORS -gt "1" ]];
then
  ## Add validators key and delegate tokens
  for i in $(seq 0 $NUM_VALIDATORS);
  do
    VAL_KEY_NAME="$(echo "$KEYS_JSON_STRING" | jq -r '.validators[0].name')-$i"
    echo "Adding validator key.... $VAL_KEY_NAME"
    echo "$KEYS_JSON_STRING" | jq -r '.validators[0].mnemonic' | $CHAIN_BIN keys add $VAL_KEY_NAME --index $i --recover --keyring-backend="test"
    $CHAIN_BIN $CHAIN_GENESIS_CMD add-genesis-account $($CHAIN_BIN keys show -a $VAL_KEY_NAME --keyring-backend="test") $COINS --keyring-backend="test"
  done
fi

echo "Creating gentx..."
COIN=$(echo $COINS | cut -d ',' -f1)
AMT=$(echo ${COIN//[!0-9]/} | sed -e "s/0000$//")
$CHAIN_BIN $CHAIN_GENESIS_CMD gentx $(jq -r ".genesis[0].name" $KEYS_CONFIG) $AMT$DENOM --keyring-backend="test" --chain-id $CHAIN_ID

echo "Output of gentx"
cat $CHAIN_DIR/config/gentx/*.json | jq

echo "Running collect-gentxs"
$CHAIN_BIN $CHAIN_GENESIS_CMD collect-gentxs

ls $CHAIN_DIR/config
