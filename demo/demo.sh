#!/bin/bash

# Validate if a key had been stored in SHDB
if shdb -s get count
then
    echo "Already exist."
else
    echo "Undefined."
fi


# Store a key in SHDB
if shdb -s set count 1
then 
    # Get a key's value
    echo $(shdb -s get count)

    # Delete a key-value pair
    if shdb -s delete count
    then
        echo "Deleted"
    fi
fi
