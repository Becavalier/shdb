#!/bin/bash

# Run this demo like "bash demo.sh [value]"

if [ -n "$1" ]
then
    VALUE="$1"
else
    VALUE="SHDB"
fi

sleep 3

echo "[Operation] Let's detect if a key 'count' had been set in SHDB ..."

# Validate if a key had been stored in SHDB
if shdb -s isset count
then
    echo "[Result] Already set."
else
    echo "[Result] Not set yet."
fi

sleep 3

echo "[Operation] Let's reset/set a key 'count' with a value in SHDB ..."

# Set a key in SHDB
if shdb -s set count "${VALUE}"
then
    echo "[Result] Set count successful."
else
    echo "[Result] Set count failed."
fi

sleep 3

echo "[Operation] Let's get a key 'count' of its value in SHDB ..."

if shdb -s isset count
then
    echo The value of count is $(shdb -s get count)
else
    echo "[Result] Get count value failed."
fi

sleep 3

echo "[Operation] Let's delete a key 'count' in SHDB ..."

if shdb -s isset count
then
    if shdb -s delete count
    then
        echo "[Result] Delete count successful."
    else
        echo "[Result] Delete count failed."
    fi 
else
    echo "[Result] Unset count yet."
fi
