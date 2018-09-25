#!/bin/bash

#=================================================================
# SHDB
#
# Desc: A simple, lightweight local nosql db for shell, mainly for data persistence.
# Usage: 
#
# 	Install:
#
# 	make SIZE=10
#	
#	Use:
#
# 	shdb status
#   shdb [-s|--shell] isset [key]
#	shdb [-s|--shell] set [key] [value]
#	shdb [-s|--shell] get [key]
#	shdb [-s|--shell] delete [key]
#	shdb [-s|--shell] count
#	shdb uninstall
#
# Author: YHSPY
# License: MIT
#=================================================================

# set global variables;
OS_TYPE=$(uname)
HOME_DIR=$(echo -n ~)

BASE64_ENCODED=''
BASE64_DECODED=''

CONFIG_KEY=''
CONFIG_VAL=''

DB_SIZE=0

# set default setting key-value pairs;
NAME="shdb"
INSTALL_DIR="/usr/local/bin/"
VERSION="1.2"
RELEASE="2018/09/23"
AVSIZE=1048576

# set key files' name;
DB_CONF_FILE_NAME="${HOME_DIR}/.shdb.master.conf"
DB_DATA_FILE_NAME="${HOME_DIR}/.shdb.master.db"
DB_TEMP_FILE_NAME="/tmp/.shdb.tmp"
DB_MAIN_ENTRY="${INSTALL_DIR}${NAME}"

# functions here;
_func_has_been_installed() {
	# return 0 represent true;
	[ -f $DB_CONF_FILE_NAME ] && [ -f $DB_DATA_FILE_NAME ] && return 0 || return 1
}

_func_clear_temp() {
	rm -f $DB_TEMP_FILE_NAME
}

_func_get_db_system_item() {
	if _func_has_been_installed ;then
		# find key in db configuration file;
		local GREP_INFO=$(grep -w -n "${CONFIG_KEY}" $DB_CONF_FILE_NAME)

		_func_clear_temp

		if [ -n "$GREP_INFO" ] ;then
			CONFIG_VAL=${GREP_INFO##*=}
		fi
	else
		_func_report_error_msg NOT_INSTALLED
	fi
}

_func_base64_encode() {
	# optimize according to RFC-822;
	echo -n $1 | base64 > $DB_TEMP_FILE_NAME

	sed -i.tmp ':a;N;$!ba;s/\n/ /g' "${DB_TEMP_FILE_NAME}"
	sed -i.tmp 's/ \+//g' "${DB_TEMP_FILE_NAME}"

	BASE64_ENCODED=$(cat $DB_TEMP_FILE_NAME)

	_func_clear_temp
}

_func_base64_decode() {
	cat > $DB_TEMP_FILE_NAME << EOF
${1}
EOF
	if [ "${OS_TYPE}" = "Linux" ] ;then
		BASE64_DECODED=$(base64 -d $DB_TEMP_FILE_NAME)
	else 
		BASE64_DECODED=$(base64 -D $DB_TEMP_FILE_NAME)
	fi

	_func_clear_temp
}

_func_update_db_size_2bytes() {
	if _func_has_been_installed ;then
		local DU_INFO
		if [ "${OS_TYPE}" = "Linux" ] ;then
			DU_INFO=$(du --apparent-size --block-size=1 $DB_DATA_FILE_NAME)
		else
			DU_INFO=$(du -k $DB_DATA_FILE_NAME)
		fi
		local FILE_SIZE=${DU_INFO%	*}

		_func_clear_temp

		DB_SIZE=$FILE_SIZE
	else
		_func_report_error_msg NOT_INSTALLED
	fi
}

install() {
	if _func_has_been_installed ;then
		_func_report_error_msg ALREADY_INSTALLED
	else
		# checklist;
		if [ $# -eq 2 ] ;then
			if [ "${1}" = "--size" ] || [ "${1}" = "-s" ] ;then
				local AVSIZE_VAL=${2}

				if [ $AVSIZE_VAL -eq 0 ] || [ $AVSIZE_VAL -ge 1025 ] ;then
					_func_report_error_msg PARAMS_ERR
					exit 1
				else
					AVSIZE_VAL=$(($AVSIZE_VAL*1048576))
					AVSIZE=$AVSIZE_VAL
				fi
			fi
		fi
		printf "[SSDB DATEBASE FILE]\n" > $DB_DATA_FILE_NAME 
		cat > $DB_CONF_FILE_NAME << EOF
[SSDB CONFIGURATION FILE]

NAME=SHDB
VARSION=${VERSION}
RELEASE=${RELEASE}
AUTHOR=YHSPY
AVSIZE=${AVSIZE}
DATE=$(date)
EOF
		# move to /usr/local/bin;
		cp -f ${0} $DB_MAIN_ENTRY
		chmod +x $DB_MAIN_ENTRY

		_func_report_info_msg INSTALLED

		# rm -f ${0}
	fi
}

update() {
	if _func_has_been_installed ;then
		# update source file;
		cp -f ${0} $DB_MAIN_ENTRY
		chmod +x $DB_MAIN_ENTRY
	else
		_func_report_info_msg NOT_INSTALLED
	fi
}

uninstall() {
	if [ -f $DB_CONF_FILE_NAME ] || [ -f $DB_DATA_FILE_NAME ] || [ -f $DB_TEMP_FILE_NAME ] ;then
		rm -f $DB_CONF_FILE_NAME
		rm -f $DB_TEMP_FILE_NAME
		rm -f $DB_DATA_FILE_NAME
		rm -f $DB_MAIN_ENTRY

		_func_report_info_msg UNINSTALLED
	else
		_func_report_error_msg NOT_INSTALLED
	fi
}

isset() {
	if _func_has_been_installed ;then
		_func_base64_encode "$1"
		local SHDB_KEY=$BASE64_ENCODED

		# find key in db;
		local GREP_INFO=$(grep -o "|${SHDB_KEY}[^|]*|" $DB_DATA_FILE_NAME)

		_func_clear_temp

		if [ -n "$GREP_INFO" ] ;then
			if [ "$2" = --shell ] ;then
				exit 0
			else
				printf "%s\n" [True]
			fi
		else
			if [ "$2" = --shell ] ;then
				exit 1
			else
				printf "%s\n" [False]
			fi
		fi
	else
		_func_report_error_msg NOT_INSTALLED
	fi
}

set() {
	CONFIG_KEY='AVSIZE'

	_func_get_db_system_item
	
	_func_update_db_size_2bytes

	if [ $DB_SIZE -ge $CONFIG_VAL ] ;then
		_func_report_error_msg DB_OVERFLOW
		exit 1
	fi
	
	if _func_has_been_installed ;then
		_func_base64_encode "$1"
		local SHDB_KEY=$BASE64_ENCODED

		_func_base64_encode "$2"
		local SHDB_VALUE=$BASE64_ENCODED

		# find key in db;
		local GREP_INFO=$(grep -o "|${SHDB_KEY}[^|]*|" $DB_DATA_FILE_NAME)

		_func_clear_temp

		if [ -n "$GREP_INFO" ] ;then
			sed -i.db -e "s#${GREP_INFO}#|${SHDB_KEY}:${SHDB_VALUE}|#" ${DB_DATA_FILE_NAME}
		else
			echo "|${SHDB_KEY}:${SHDB_VALUE}|" >> $DB_DATA_FILE_NAME
		fi

		if [ "$3" = --shell ] ;then
			exit 0
		else
			printf "%s\n" "[OK]" 
		fi
		
	else
		_func_report_error_msg NOT_INSTALLED
	fi
}

get() {
	if _func_has_been_installed ;then
		_func_base64_encode "$1"
		local SHDB_KEY=$BASE64_ENCODED

		# find key in db;
		local GREP_INFO=$(grep -o "|${SHDB_KEY}[^|]*|" $DB_DATA_FILE_NAME)

		_func_clear_temp

		if [ -n "$GREP_INFO" ] ;then
			local SHDB_VAL_TEMP=${GREP_INFO##*:}
			local SHDB_VAL=${SHDB_VAL_TEMP%%|*}

			_func_base64_decode $SHDB_VAL

			if [ "$2" = --shell ] ;then
				printf "%s" "$BASE64_DECODED"
			else
				printf "%s\n" "$BASE64_DECODED"
			fi
		else
			if [ "$2" = --shell ] ;then
				exit 1
			else
				printf "[Empty]\n"
			fi
		fi
	else
		_func_report_error_msg NOT_INSTALLED
	fi
}

delete() {
	if _func_has_been_installed
	then
		_func_base64_encode "$1"
		local SHDB_KEY=$BASE64_ENCODED

		# find key in db;
		local GREP_INFO=$(grep -o "|${SHDB_KEY}[^|]*|" $DB_DATA_FILE_NAME)

		_func_clear_temp

		if [ -n "$GREP_INFO" ] ;then
			sed -i.db -e "s/${GREP_INFO}//" $DB_DATA_FILE_NAME

			if [ "$2" = --shell ] ;then
				exit 0
			else
				printf "[Deleted]\n"
			fi
		else
			if [ "$2" = --shell ] ;then
				exit 1
			else
				printf "[Empty]\n"
			fi
		fi
	else
		_func_report_error_msg NOT_INSTALLED
	fi
}

count() {
	if _func_has_been_installed ;then
		local COUNT_TEMP=$(grep -o "|" $DB_DATA_FILE_NAME | grep -c "|")
		local COUNT_ITEM=$(($COUNT_TEMP/2))

		if [ "$1" = --shell ] ;then
			printf "$COUNT_ITEM"
		else
			printf "[Count] $COUNT_ITEM\n"
		fi
	fi
}

test() {
	local VALUE="SHDB"

	printf "\n"
	sleep 2

	echo "[operation] Let's detect if a key 'count' had been set in SHDB ..."

	# Validate if a key had been stored in SHDB
	if shdb -s isset count ;then
		echo "[result] Already set... succeed"
	else
		echo "[result] isset... succeed"
	fi

	printf "\n"
	sleep 2

	echo "[operation] Let's reset/set a key 'count' with a value in SHDB ..."

	# Set a key in SHDB
	if shdb -s set count "${VALUE}" ;then
		echo "[result] set... succeed"
	else
		echo "[result] set... failed"
	fi

	printf "\n"
	sleep 2

	echo "[operation] Let's get a key 'count' of its value in SHDB ..."

	if shdb -s isset count ;then
		echo "[result] get... succeed"
	else
		echo "[result] get... failed"
	fi

	printf "\n"
	sleep 2

	echo "[operation] Let's delete a key 'count' in SHDB ..."

	if shdb -s isset count ;then
		if shdb -s delete count ;then
			echo "[result] delete... succeed"
		else
			echo "[result] delete... failed"
		fi 
	else
		echo "[result] Unset count yet."
	fi

	printf "\n"
}

_func_print_status() {
	if _func_has_been_installed ;then
		local DU_INFO=$(du -h $DB_DATA_FILE_NAME)
		local FILE_SIZE=${DU_INFO%	*}

		_func_clear_temp

		# get maximum avaliable size;
		CONFIG_KEY='AVSIZE'

		_func_get_db_system_item

		# format size to 'MB';
		local DB_MAXIMUM_SIZE=$CONFIG_VAL
		DB_MAXIMUM_SIZE=$(($DB_MAXIMUM_SIZE/1048576))

		cat << EOF

[SHDB]      
-----------------     

Release Version: ${VERSION} 
Release Date: ${RELEASE}                                    
DB Current Size: ${FILE_SIZE}
DB Maximum Size: ${DB_MAXIMUM_SIZE}MB

-----------------     
Copyright: YHSPY
-----------------    

EOF
	else
		_func_report_error_msg NOT_INSTALLED
	fi
}

_func_report_error_msg() {
	case "$1" in 
		PARAMS_ERR ) 
			cat << EOF
[shdb ERR] Wrong number or format of arguments for this command... error
EOF
		;;
		ALREADY_INSTALLED ) 
			cat << EOF
[shdb ERR] SHDB had already been installed before... error
EOF
		;;
		NOT_INSTALLED ) 
			cat << EOF
[shdb ERR] Please install SHDB first before execute this command... error
EOF
		;;
		DB_OVERFLOW ) 
			cat << EOF
[shdb ERR] SHDB had exceeded the maximum storage size you ever set... error
EOF
		;;
	esac
}

_func_report_info_msg() {
	case "$1" in 
		UNINSTALLED ) 
			cat << EOF
[shdb INFO] SHDB now has been uninstalled from your system... succeed
EOF
		;;
		INSTALLED ) 
			cat << EOF
[shdb INFO] SHDB now has been installed on your system... succeed
EOF
		;;
	esac
}

console() {
	while :
	do
		printf "%s" "shdb > "
		read ORDER
		cat > $DB_TEMP_FILE_NAME << EOF
${ORDER}
EOF
		if [ -n "$(grep [[:space:]]*set[[:space:]][^[:space:]]*[[:space:]][^[:space:]]* $DB_TEMP_FILE_NAME)" ] ;then
			local ORDER_COMMAND_LINE=$(cat $DB_TEMP_FILE_NAME)
			local SHDORDER_COMMAND_LINE_S1=${ORDER_COMMAND_LINE#*set }
			local SHDB_KEY=${SHDORDER_COMMAND_LINE_S1%% *}
			local SHDB_VALUE=${SHDORDER_COMMAND_LINE_S1#${SHDB_KEY} }

			set "$SHDB_KEY" "$SHDB_VALUE"
		elif [ -n "$(grep "[[:space:]]*get[[:space:]][^[:space:]]*" $DB_TEMP_FILE_NAME)" ] ;then
			local ORDER_COMMAND_LINE=$(cat $DB_TEMP_FILE_NAME)
			local SHDB_KEY=${ORDER_COMMAND_LINE#*get }

			get "$SHDB_KEY"
		elif [ -n "$(grep "[[:space:]]*delete[[:space:]][^[:space:]]*" $DB_TEMP_FILE_NAME)" ] ;then
			local ORDER_COMMAND_LINE=$(cat $DB_TEMP_FILE_NAME)
			local SHDB_KEY=${ORDER_COMMAND_LINE#*delete }

			delete "$SHDB_KEY"
		elif [ -n "$(grep "[[:space:]]*isset[[:space:]][^[:space:]]*" $DB_TEMP_FILE_NAME)" ] ;then
			local ORDER_COMMAND_LINE=$(cat $DB_TEMP_FILE_NAME)
			local SHDB_KEY=${ORDER_COMMAND_LINE#*isset }

			isset "$SHDB_KEY"
		elif [ "$ORDER" = "count" ] ;then
			count
		elif [ "$ORDER" = "exit" ] ;then
			break
		else
			_func_report_error_msg PARAMS_ERR
		fi
	done
}


# Reset system global variable
PRE_IFS=$IFS

IFS=" "


# Deal with parameters
if [ "$1" = "-s" ] || [ "$1" = "--shell" ] ;then
	if [ $# -eq 4 ] ;then
		case "$2" in
			set )
				set "${3}" "${4}" --shell
			;;
			* )
				_func_report_error_msg PARAMS_ERR
			;;
		esac
	elif [ $# -eq 3 ] ;then 
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
				_func_report_error_msg PARAMS_ERR
			;;
		esac
	elif [ $# -eq 2 ] ;then
		case "$2" in
			count )
				count --shell
			;;
		esac
	else
		_func_report_error_msg PARAMS_ERR
	fi
else
	if [ $# -eq 3 ] ;then
		case "$1" in
			set )
				set "${2}" "${3}"
			;;
			install )
				install "${2}" "${3}"
			;;
			* )
				_func_report_error_msg PARAMS_ERR
			;;
		esac
	elif [ $# -eq 2 ] ;then 
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
				_func_report_error_msg PARAMS_ERR
			;;
		esac
	elif [ $# -eq 1 ] ;then
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
				_func_report_error_msg PARAMS_ERR 
			;;
		esac
	else
		_func_print_status
	fi
fi

IFS=$PRE_IFS

exit 0
