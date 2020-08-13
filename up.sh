#!/usr/bin/env bash
_eosio_version=2.0
_eosio_loc=${HOME}/eosio/${_eosio_version}
PATH=${_eosio_loc}/bin:${PATH}

current=$(nodeos -v 2>&1 | grep -i -c -E "^v(2\.[0-9]|[3-9])")
if [ "$current" = "0" ]; then
    echo "Your nodeos is old. Minimum required version is 2.0" >&2
    exit 1
fi
if [ -f "nodeos.pid" ]; then
    declare -i _pid=$(cat nodeos.pid)
    kill -9 ${_pid}
fi
echo "Starting EOSIO/NODEOS chain..."
nohup nodeos -e -p eosio \
--data-dir blockchain \
--http-validate-host=false \
--plugin eosio::producer_api_plugin \
--plugin eosio::chain_api_plugin \
--plugin eosio::state_history_plugin \
--trace-history \
--chain-state-history \
--state-history-endpoint=0.0.0.0:9999 \
--disable-replay-opts \
--http-server-address=0.0.0.0:8888 \
--access-control-allow-origin=* \
--contracts-console \
--max-transaction-time=100000 \
--verbose-http-errors \
--wasm  eos-vm-jit 2>&1 > nodeos.log &
echo $! > nodeos.pid
tail nodeos.log
