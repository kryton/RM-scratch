#!/usr/bin/env bash
_eosio_version=2.0
_eosio_loc=${HOME}/eosio/${_eosio_version}
_contract_loc=${HOME}/eosio/eosio.contracts.rentbw/
PATH=${_eosio_loc}/bin:${PATH}

wallet_name="RM"

source ./_unlock_wallet.sh
create_or_unlock_wallet ${wallet_name}

#gen_key ${wallet_name} "testerbios"

check_feature only_bill_first_authorizer       "8ba52fe7a3956c5cd3a656a3174b931d3bb2abb45578befc59f283ecd816a405"

cleos set contract eosio.bios ${_contract_loc}/build/contracts/eosio.bios/
cleos push action eosio setpriv '["eosio.msig",1]' -p eosio
cleos set contract eosio.msig ${_contract_loc}/build/contracts/eosio.msig/
cleos set contract eosio.wrap ${_contract_loc}/build/contracts/eosio.wrap/ -p eosio.wrap
