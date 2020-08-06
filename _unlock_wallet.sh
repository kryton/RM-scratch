#!/usr/bin/env bash

unlock_wallet()
{
    wallet_name=$1
    wallet_file=$2
    cleos wallet unlock -n "${wallet_name}" --password < "${wallet_file}"
}

create_or_unlock_wallet()
{
    wallet_name=$1
    wallet_file="$(dirname "$0")/default_wallet_${wallet_name}_password.txt"
    # List wallets currently loaded in keosd.
    is_unlocked=$(cleos wallet list | grep ${wallet_name} | grep '*')

    if [[ -z "${is_unlocked}"  ]]; then
        echo "Starting the wallet..."

        # The wallet either does not exist or is not loaded yet.
        # Let's try to load it first.
        if ! [[ -f "${wallet_file}" ]] || ! unlock_wallet ${wallet_name} "${wallet_file}"; then
            # Create the wallet.

            create_result=$(cleos wallet create -n "${wallet_name}" --to-console )
            wallet_password=$(echo ${create_result} | cut -d '"' -f 2)
            if [[ ! -z "$wallet_password" ]] ; then
                echo "Wallet password: ${wallet_password}"
                echo $wallet_password > ${wallet_file}
            else
                echo "failed to generate password. Script error. _unlock_wallet.sh"
                read -n 1 -r -s -p $'Press enter to continue...\n'
            fi
        fi
    fi
}

add_private_key()
{
    wallet_name=$1
    key_name=$2
    public_key=$3
    private_key=$4
    declare -i _rc

    _res=$( cleos wallet import -n "${wallet_name}" --private-key 2>&1 <<< ${private_key} )
    _rc=$?
    if [ ${_rc} -ne 0 ]; then
        _ff=$(echo ${_res} | grep "Key already in wallet")
        _rc=$?

        if [ ${_rc} -ne 0 ]; then
            echo ${_res}
            return ${_rc}
        else
            echo "already set"
            key_file="$(dirname "$0")/key_${key_name}.txt"
            echo ${public_key} > ${key_file}
            return 0
        fi
    else
        key_file="$(dirname "$0")/key_${key_name}.txt"
        echo ${public_key} > ${key_file}
        echo ${_res}
        return 0
    fi

}

gen_key() {
    wallet_name=$1
    key_name=$2

    key_file="$(dirname "$0")/key_${key_name}.txt"
    public=""

    if [ -f "${key_file}" ]; then
        >&2 echo "key ${key_name} exists. skipping"
        public=$(cat ${key_file})
    else
        declare -a arr

        keys=$(cleos create key --to-console)
        readarray arr <<< ${keys}
        private=$(cut <<< ${arr[0]} -d ":" -f2)
        public=$(cut <<< ${arr[1]} -d ":" -f2)

        add_private_key ${wallet_name} ${key_name} ${public} ${private}
    fi
    cleos create account eosio ${key_name} ${public} ${public}

}
set_key() {
    wallet_name=$1
    key_name=$2
    public_key=$3
    private_key=$4

    key_file="$(dirname "$0")/key_${key_name}.txt"
    rm -f ${key_file}

    add_private_key ${wallet_name} ${key_name} ${public_key} ${private_key}
    echo ${public_key} > ${key_file}

    cleos create account eosio ${key_name} ${public_key}  ${public_key}

}

function check_feature()
{
    feature_name=$1
    digest=$2
    if [ ! -f "features.json" ]; then
        curl -sS --url http://127.0.0.1:8888/v1/producer/get_supported_protocol_features -o ./features.json
    fi
    output=$(jq "map(select(.feature_digest == \"$digest\" and
            .subjective_restrictions.enabled == true)) | length" < "./features.json")

    if [ "$?" != "0" ] || [ "$output" = "0" ]; then
        echo
        echo "The $feature_name feature isn't supported. It needs to be enabled and activated first" >&2
        exit 2
    fi
}
