#!/usr/bin/env bash
echo "This will wipe your RM wallet, and ALL your keys"
read -n 1 -r -s -p $'Press enter to continue...\n'
rm $HOME/eosio-wallet/RM.wallet
rm ./default_wallet_RM_password.txt
rm ./key_*.txt
pkill keosd