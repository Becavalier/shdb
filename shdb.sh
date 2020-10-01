#!/bin/bash
set -e

#=============================================================
# SHDB
#
# A simple, lightweight key-value DB for shell programming.
#
#  Install:
#
#     make SIZE=10 (MB)
#    
#  Usage:
#
#     shdb status
#     shdb [-s|--shell] isset [key]
#     shdb [-s|--shell] set [key] [value]
#     shdb [-s|--shell] get [key]
#     shdb [-s|--shell] delete [key]
#     shdb [-s|--shell] count
#     shdb uninstall
#
# Author: YHSPY
# License: MIT
#=============================================================

# set global variables.
OS_TYPE=$(uname)
SUDO_USER=$(echo -n $SUDO_USER)
if [ -n "$SUDO_USER" ] ; then
     if [ "${OS_TYPE}" = "Linux" ] ; then
        HOME_DIR=$(getent passwd $SUDO_USER | cut -d: -f6)
     else
        HOME_DIR="/Users/$SUDO_USER"
     fi
else
    HOME_DIR=$(echo -n ~)
fi

BASE64_ENCODED=''
BASE64_DECODED=''

CONFIG_KEY=''
CONFIG_VAL=''

typeset -i DB_CURRENT_SIZE=0

typeset -i BOOL_TRUE=0
typeset -i BOOL_FALSE=1
typeset -i EXIT_NORMAL=0
typeset -i EXIT_ERROR=1

# set default setting pairs;
NAME="shdb"
INSTALL_DIR="/usr/local/bin/"
VERSION="1.4"
RELEASE="2020/10/01"
typeset -i AVSIZE=1000  # 1KB by default.

# set other configurations.
DB_CONF_FILE_NAME="${HOME_DIR}/.shdb.master.conf"
DB_DATA_FILE_NAME="${HOME_DIR}/.shdb.master.db"
DB_MAIN_ENTRY="${INSTALL_DIR}${NAME}"

# function definitions.
_func_has_installed() {
    if [ -f $DB_CONF_FILE_NAME ] && [ -f $DB_DATA_FILE_NAME ] ; then
        return $BOOL_TRUE
    else
        return $BOOL_FALSE
    fi
}

_func_retrieve_db_system_item() {
    if _func_has_installed ; then
        # find value in db configuration file.
        local _GREP_INFO=$(grep -w -n "$1" $DB_CONF_FILE_NAME)

        if [ -n "$_GREP_INFO" ] ; then
            CONFIG_VAL=${_GREP_INFO##*=}
        fi
    else
        _func_report_error NOT_INSTALLED
    fi
}

_func_base64_encode() {
    BASE64_ENCODED=$(echo -n "$1" | base64)
}

_func_base64_decode() {
    BASE64_DECODED=$(echo -n "$1" | base64 --decode)
}

_func_calc_db_size() {
    if _func_has_installed ; then
        local _DU_INFO
        if [ "${OS_TYPE}" = "Linux" ] ; then
            _DU_INFO=$(du --apparent-size --block-size=1 $DB_DATA_FILE_NAME)
        else
            _DU_INFO=$(du -k $DB_DATA_FILE_NAME)
        fi
        DB_CURRENT_SIZE=${_DU_INFO%%	*}
    else
        _func_report_error NOT_INSTALLED
    fi
}

install() {
    if _func_has_installed ; then
        _func_report_error ALREADY_INSTALLED
    else
        # checklist.
        if [ $# -eq 2 ] ; then
            if [ "${1}" = "--size" ] || [ "${1}" = "-s" ] ; then
                local AVSIZE_VAL=${2}
                if [ $AVSIZE_VAL -eq 0 ] || [ $AVSIZE_VAL -ge 1025 ] ; then
                    _func_report_error PARAMS_ERR
                    exit $EXIT_ERROR
                else
                    AVSIZE=$(($AVSIZE_VAL * 1000))
                fi
            fi
        fi
        printf "[SHDB DATEBASE FILE]\n" > $DB_DATA_FILE_NAME 
        cat > $DB_CONF_FILE_NAME << EOF
[SHDB CONFIGURATION FILE]

NAME=shdb
VARSION=${VERSION}
RELEASE=${RELEASE}
AUTHOR=YHSPY
AVSIZE=${AVSIZE}
DATE=$(date)
EOF
        # move to /usr/local/bin, and grant exection privilege.
        cp -f ${0} $DB_MAIN_ENTRY
        chmod +x $DB_MAIN_ENTRY

        _func_report_info INSTALLED
    fi
}

update() {
    if _func_has_installed ; then
        if [ "${0}" != "$DB_MAIN_ENTRY" ] ; then
            # update source file.
            cp -f ${0} $DB_MAIN_ENTRY
            chmod +x $DB_MAIN_ENTRY
            _func_report_info UPDATED
        fi
    else
        _func_report_info NOT_INSTALLED
    fi
}

uninstall() {
    rm -f $DB_CONF_FILE_NAME
    rm -f $DB_DATA_FILE_NAME
    rm -f $DB_MAIN_ENTRY

    _func_report_info UNINSTALLED
}

isset() {
    if _func_has_installed ; then
        _func_base64_encode "$1"
        
        # find k-v in db.
        local GREP_INFO=$(grep -o "|${BASE64_ENCODED}[^|]*|" $DB_DATA_FILE_NAME)

        if [ -n "$GREP_INFO" ] ; then
            if [ "$2" = --shell ] ; then
                exit $EXIT_NORMAL
            else
                printf "%s\n" [True]
            fi
        else
            if [ "$2" = --shell ] ; then
                exit $EXIT_ERROR
            else
                printf "%s\n" [False]
            fi
        fi
    else
        _func_report_error NOT_INSTALLED
    fi
}

set() {
    _func_retrieve_db_system_item AVSIZE
    _func_calc_db_size

    if [ $DB_CURRENT_SIZE -ge $CONFIG_VAL ] ; then
        _func_report_error DB_OVERFLOW
        exit $EXIT_ERROR
    fi
    
    if _func_has_installed ; then
        _func_base64_encode $1
        local _SHDB_KEY=$BASE64_ENCODED

        _func_base64_encode $2
        local _SHDB_VAL=$BASE64_ENCODED

        # find existing item in db.
        local _GREP_INFO=$(grep -o "|${_SHDB_KEY}[^|]*|" $DB_DATA_FILE_NAME)

        if [ -n "$_GREP_INFO" ] ; then
            if [ "${OS_TYPE}" = "Linux" ] ; then
                sed -i -e "s#${_GREP_INFO}#|${_SHDB_KEY}:${_SHDB_VAL}|#" ${DB_DATA_FILE_NAME}
            else
                sed -i "" -e "s#${_GREP_INFO}#|${_SHDB_KEY}:${_SHDB_VAL}|#" ${DB_DATA_FILE_NAME}
            fi
        else
            echo "|${_SHDB_KEY}:${_SHDB_VAL}|" >> $DB_DATA_FILE_NAME
        fi

        if [ "$3" = --shell ] ; then
            exit $EXIT_NORMAL
        else
            printf "%s\n" "[OK]" 
        fi
    else
        _func_report_error NOT_INSTALLED
    fi
}

get() {
    if _func_has_installed ; then
        _func_base64_encode $1
        local _SHDB_KEY=$BASE64_ENCODED

        # find existing item in db.
        local _GREP_INFO=$(grep -o "|${_SHDB_KEY}[^|]*|" $DB_DATA_FILE_NAME)

        if [ -n "$_GREP_INFO" ] ; then
            local _SHDB_VAL_TEMP=${_GREP_INFO##*:}
            local _SHDB_VAL=${_SHDB_VAL_TEMP%%|*}

            _func_base64_decode $_SHDB_VAL

            if [ "$2" = --shell ] ; then
                printf "%s" "$BASE64_DECODED"
            else
                printf "%s\n" "$BASE64_DECODED"
            fi
        else
            if [ "$2" = --shell ] ; then
                exit $EXIT_ERROR
            else
                printf "[Empty]\n"
            fi
        fi
    else
        _func_report_error NOT_INSTALLED
    fi
}

delete() {
    if _func_has_installed ; then
        _func_base64_encode $1
        local _SHDB_KEY=$BASE64_ENCODED

        # find existing item in db.
        local _GREP_INFO=$(grep -o "|${_SHDB_KEY}[^|]*|" $DB_DATA_FILE_NAME)

        if [ -n "$_GREP_INFO" ] ; then
            if [ "${OS_TYPE}" = "Linux" ] ; then
                sed -i -e "/${_GREP_INFO}/d" $DB_DATA_FILE_NAME
            else
                sed -i "" -e "/${_GREP_INFO}/d" $DB_DATA_FILE_NAME
            fi

            if [ "$2" = --shell ] ; then
                exit $EXIT_NORMAL
            else
                printf "[Deleted]\n"
            fi
        else
            if [ "$2" = --shell ] ; then
                exit $EXIT_ERROR
            else
                printf "[Empty]\n"
            fi
        fi
    else
        _func_report_error NOT_INSTALLED
    fi
}

count() {
    if _func_has_installed ; then
        local _COUNT_TEMP=$(grep -o "|" $DB_DATA_FILE_NAME | grep -c "|")
        local _COUNT_ITEM=$(($_COUNT_TEMP / 2))

        if [ "$1" = --shell ] ; then
            printf "$_COUNT_ITEM"
        else
            printf "[Count] $_COUNT_ITEM\n"
        fi
    fi
}

test() {
    local _KEY="SHDB"

    printf "\n"

    echo "[isset] Let's find if the KV \"count\" has been stored in SHDB ..."
 
    if shdb -s isset count ; then
        echo "[result] Already exist... succeed"
    else
        echo "[result] (succeed)"
    fi

    printf "\n"
    sleep 1

    echo "[set] Let's reset/set the KV \"count\" with a value in SHDB ..."

    # Set a key in SHDB
    if shdb -s set count "${_KEY}" ; then
        echo "[result] (succeed)"
    else
        echo "[result] (failed)"
    fi

    printf "\n"
    sleep 1

    echo "[get] Let's get the value of KV \"count\" from SHDB ..."

    if shdb -s isset count ; then
        local _VAL=$(shdb -s get count)
        echo "[result] ${_VAL} (succeed)"
    else
        echo "[result] (failed)"
    fi

    printf "\n"
    sleep 1

    echo "[delete] Let's delete the KV \"count\" in SHDB ..."

    if shdb -s isset count ; then
        if shdb -s delete count ; then
            echo "[result] (succeed)"
        else
            echo "[result] (failed)"
        fi 
    fi

    printf "\n"
}

_func_print_status() {
    if _func_has_installed ; then
        _func_retrieve_db_system_item AVSIZE
        
        local _FILE_SIZE=$(du -h $DB_DATA_FILE_NAME)
        local _DB_MAXIMUM_SIZE=$CONFIG_VAL
        _DB_MAXIMUM_SIZE=$(($_DB_MAXIMUM_SIZE))

        cat << EOF

[SHDB]      
-----------------     

Release Version: ${VERSION} 
Release Date: ${RELEASE}                                    
DB Current Size: ${_FILE_SIZE}
DB Maximum Size: ${_DB_MAXIMUM_SIZE}K

EOF
    else
        _func_report_error NOT_INSTALLED
    fi
}

_func_report_error() {
    case "$1" in 
        PARAMS_ERR ) 
            cat << EOF
[shdb ERR] Invalid command or arguments... error
EOF
        ;;
        ALREADY_INSTALLED ) 
            cat << EOF
[shdb ERR] SHDB has already been installed... error
EOF
        ;;
        NOT_INSTALLED ) 
            cat << EOF
[shdb ERR] Core files missing, please re-install SHDB... error
EOF
        ;;
        DB_OVERFLOW ) 
            cat << EOF
[shdb ERR] SHDB has exceeded the maximum storage size... error
EOF
        ;;
    esac
}

_func_report_info() {
    case "$1" in 
        UNINSTALLED ) 
            cat << EOF
[shdb INFO] SHDB uninstall... succeed
EOF
        ;;
        INSTALLED ) 
            cat << EOF
[shdb INFO] SHDB install... succeed
EOF
        ;;
        UPDATED ) 
            cat << EOF
[shdb INFO] SHDB update... succeed
EOF
        ;;
    esac
}

console() {
    while :
    do
        printf "%s" "shdb > "
        read ORDER
        if [ -n "$(echo -n "${ORDER}" | grep [[:space:]]*set[[:space:]][^[:space:]]*[[:space:]][^[:space:]]*)" ] ; then
            local _SHDB_CMD=${ORDER#*set }
            local _SHDB_KEY=${_SHDB_CMD%% *}
            local _SHDB_VALUE=${_SHDB_CMD#${SHDB_KEY} }

            set "$_SHDB_KEY" "$_SHDB_VALUE"
        elif [ -n "$(echo -n "${ORDER}" | grep "[[:space:]]*get[[:space:]][^[:space:]]*")" ] ; then
            local _SHDB_KEY=${ORDER#*get }

            get "$_SHDB_KEY"
        elif [ -n "$(echo -n "${ORDER}" | grep "[[:space:]]*delete[[:space:]][^[:space:]]*")" ] ; then
            local _SHDB_KEY=${ORDER#*delete }

            delete "$_SHDB_KEY"
        elif [ -n "$(echo -n "${ORDER}" | grep "[[:space:]]*isset[[:space:]][^[:space:]]*")" ] ; then
            local _SHDB_KEY=${ORDER#*isset }

            isset "$_SHDB_KEY"
        elif [ "$ORDER" = "count" ] ; then
            count
        elif [ "$ORDER" = "exit" ] ; then
            break
        else
            _func_report_error PARAMS_ERR
        fi
    done
}

# save "Interal Field Separator".
PRE_IFS=$IFS
IFS=" "

# paly with parameters.
if [ "$1" = "-s" ] || [ "$1" = "--shell" ] ; then
    if [ $# -eq 4 ] ; then
        case "$2" in
            set )
                set "${3}" "${4}" --shell
            ;;
            * )
                _func_report_error PARAMS_ERR
            ;;
        esac
    elif [ $# -eq 3 ] ; then 
        case "$2" in
            get )
                get "${3}" --shell
            ;;
            delete )
                delete "${3}" --shell
            ;;
            isset )
                isset "${3}" --shell
            ;;
            * )
                _func_report_error PARAMS_ERR
            ;;
        esac
    elif [ $# -eq 2 ] ; then
        case "$2" in
            count )
                count --shell
            ;;
        esac
    else
        _func_report_error PARAMS_ERR
    fi
else
    if [ $# -eq 3 ] ; then
        case "$1" in
            set )
                set "${2}" "${3}"
            ;;
            install )
                install "${2}" "${3}"
            ;;
            * )
                _func_report_error PARAMS_ERR
            ;;
        esac
    elif [ $# -eq 2 ] ; then 
        case "$1" in
            get )
                get "${2}"
            ;;
            delete )
                delete "${2}"
            ;;
            isset )
                isset "${2}"
            ;;
            * )
                _func_report_error PARAMS_ERR
            ;;
        esac
    elif [ $# -eq 1 ] ; then
        case "$1" in
            install )
                install
            ;;
            update )
                update
            ;;
            status )
                _func_print_status
            ;;
            count )
                count
            ;;
            uninstall )
                uninstall
            ;;
            console )
                console
            ;;
            test )
                test
            ;;
            * )
                _func_report_error PARAMS_ERR 
            ;;
        esac
    else
        _func_print_status
    fi
fi

IFS=$PRE_IFS

exit $EXIT_NORMAL
