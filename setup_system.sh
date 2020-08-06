#!/usr/bin/env bash
_eosio_version=2.0
_eosio_loc=${HOME}/eosio/${_eosio_version}
PATH=${_eosio_loc}/bin:${PATH}
_contract_loc=${HOME}/eosio/eosio.contracts.rentbw/

declare -i _rc

SYSTEM_ACCOUNT_PRIVATE_KEY="5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3"
SYSTEM_ACCOUNT_PUBLIC_KEY="EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV"
wallet_name="RM"

source ./_unlock_wallet.sh
create_or_unlock_wallet ${wallet_name}

add_private_key ${wallet_name} "SYSTEM" ${SYSTEM_ACCOUNT_PUBLIC_KEY} ${SYSTEM_ACCOUNT_PRIVATE_KEY}

#cleos -u https://api.testnet.eos.io get code -c eosio.wasm -a eosio.abi --wasm eosio

curl --request POST \
     --url http://127.0.0.1:8888/v1/producer/schedule_protocol_feature_activations \
     -d '{"protocol_features_to_activate": ["0ec7e080177b2c02b278d5088611686b49d739925a92d9bfcacd7fc6b74053bd"]}'
sleep 2s

set_key ${wallet_name} "eosio.token"  ${SYSTEM_ACCOUNT_PUBLIC_KEY} ${SYSTEM_ACCOUNT_PRIVATE_KEY}
set_key ${wallet_name} "eosio.rex"  ${SYSTEM_ACCOUNT_PUBLIC_KEY} ${SYSTEM_ACCOUNT_PRIVATE_KEY}
set_key ${wallet_name} "eosio.ram"  ${SYSTEM_ACCOUNT_PUBLIC_KEY} ${SYSTEM_ACCOUNT_PRIVATE_KEY}
accounts="eosio.bpay eosio.bios eosio.msig eosio.names eosio.ramfee eosio.saving eosio.stake eosio.vpay eosio.wrap"

for k in $accounts
do
set_key ${wallet_name} ${k} ${SYSTEM_ACCOUNT_PUBLIC_KEY} ${SYSTEM_ACCOUNT_PRIVATE_KEY}
done
sleep 2s
cleos set contract eosio ./ eosio.wasm eosio.abi
sleep 2s

# GET_SENDER
cleos push action eosio activate '["f0af56d2c5a48d60a4a5b5c903edfb7db3a736a94ed589d0b797df33ff9d3e1d"]' -p eosio
# FORWARD_SETCODE
cleos push action eosio activate '["2652f5f96006294109b3dd0bbde63693f55324af452b799ee137a81a905eed25"]' -p eosio
# ONLY_BILL_FIRST_AUTHORIZER
cleos push action eosio activate '["8ba52fe7a3956c5cd3a656a3174b931d3bb2abb45578befc59f283ecd816a405"]' -p eosio
# RESTRICT_ACTION_TO_SELF
cleos push action eosio activate '["ad9e3d8f650687709fd68f4b90b41f7d825a365b02c23a636cef88ac2ac00c43"]' -p eosio
# DISALLOW_EMPTY_PRODUCER_SCHEDULE
cleos push action eosio activate '["68dcaa34c0517d19666e6b33add67351d8c5f69e999ca1e37931bc410a297428"]' -p eosio
 # FIX_LINKAUTH_RESTRICTION
cleos push action eosio activate '["e0fb64b1085cc5538970158d05a009c24e276fb94e1a0bf6a528b48fbc4ff526"]' -p eosio
 # REPLACE_DEFERRED
cleos push action eosio activate '["ef43112c6543b88db2283a2e077278c315ae2c84719a8b25f25cc88565fbea99"]' -p eosio
# NO_DUPLICATE_DEFERRED_ID
cleos push action eosio activate '["4a90c00d55454dc5b059055ca213579c6ea856967712a56017487886a4d4cc0f"]' -p eosio
# ONLY_LINK_TO_EXISTING_PERMISSION
cleos push action eosio activate '["1a99a59d87e06e09ec5b028a9cbb7749b4a5ad8819004365d02dc4379a8b7241"]' -p eosio
# RAM_RESTRICTIONS
cleos push action eosio activate '["4e7bf348da00a945489b2a681749eb56f5de00b900014e137ddae39f48f69d67"]' -p eosio
# WEBAUTHN_KEY
cleos push action eosio activate '["4fca8bd82bbd181e714e283f83e1b45d95ca5af40fb89ad3977b653c448f78c2"]' -p eosio
# WTMSIG_BLOCK_SIGNATURES
cleos push action eosio activate '["299dcb6af692324b899b39f16d5a530a33062804e41f09dc97e9f156b4476707"]' -p eosio
sleep 2s

cleos push action eosio setpriv \["eosio.token",1\] -p eosio
cleos push action eosio setpriv \["eosio.rex",1\] -p eosio
cleos push action eosio setpriv \["eosio.ram",1\] -p eosio
for k in $accounts
do
cleos push action eosio setpriv \["${k}",1\] -p eosio
done
cleos set contract eosio.token ${_contract_loc}/build/contracts/eosio.token/ -p eosio.token

cleos push action eosio.token create '["eosio", "10000000000.0000 SYS",0,0,0]' -p eosio.token
cleos push action eosio.token issue '["eosio","1000000000.0000 SYS", "issue"]' -p eosio
cleos push action eosio init '["0", "4,SYS"]' -p eosio

#exit

cleos set contract eosio ${_contract_loc}/build/contracts/eosio.system/ -p eosio
sleep 2s

#cleos system newaccount eosio --transfer ${k} ${SYSTEM_ACCOUNT_PUBLIC_KEY} --stake-net "10000000.0000 SYS" --stake-cpu "10000000.0000 SYS" --buy-ram-kbytes 8192

