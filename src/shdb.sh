#!/bin/bash

#=================================================================
# SHDB
#
# Desc: A simple, lightweight local nosql db for shell, mainly for data persistence.
# Usage: 
#
# 	Install:
#
# 	bash bin/shdb.sh install
#	
#	Use:
#
# 	shdb status
#   shdb [-s|--shell] isset [key]
#	shdb [-s|--shell] set [key] [value]
#	shdb [-s|--shell] get [key]
#	shdb [-s|--shell] delete [key]
#	shdb uninstall
#
# Author: YHSPY
# License: MIT
#=================================================================

# Set global variables
BASE64_ENCODED=''
BASE64_DECODED=''

CONFIG_KEY=''
CONFIG_VAL=''

DB_SIZE=0

# Set default setting key-value pairs
VERSION=1.0
RELEASE=2016/10/18
AVSIZE=1048576

# Set key files' name
DB_CONF_FILE_NAME=".shdb.master.conf"
DB_DATA_FILE_NAME=".shdb.master.db"
DB_TEMP_FILE_NAME=".shdb.tmp"

# Functions here
_func_has_been_installed() {
	# Return 0 represent true
	[ -f ~/$DB_CONF_FILE_NAME ] && [ -f ~/$DB_DATA_FILE_NAME ] && return 0 || return 1
}

_func_clear_temp() {
	sudo rm -f /tmp/$DB_TEMP_FILE_NAME
}

_func_get_db_system_item() {
	if _func_has_been_installed
	then
		# Find key in db configuration file
		sudo grep -w -n "${CONFIG_KEY}" ~/$DB_CONF_FILE_NAME 1> /tmp/$DB_TEMP_FILE_NAME
		local GREP_INFO=$(cat /tmp/$DB_TEMP_FILE_NAME)

		_func_clear_temp

		if [ -n "$GREP_INFO" ] 
		then
			CONFIG_VAL=${GREP_INFO##*=}
		fi
	else
		_func_report_error_msg NOT_INSTALLED
	fi
}

_func_base64_encode() {
	# Optimize according to RFC-822
	sudo su -c "echo -n '${1}' | base64 > /tmp/$DB_TEMP_FILE_NAME"

	sudo sed -i ':a;N;$!ba;s/\n/ /g' /tmp/$DB_TEMP_FILE_NAME
	sudo sed -i 's/ \+//g' /tmp/$DB_TEMP_FILE_NAME

	BASE64_ENCODED=$(sudo cat /tmp/$DB_TEMP_FILE_NAME)

	_func_clear_temp
}

_func_base64_decode() {
	cat > /tmp/$DB_TEMP_FILE_NAME << EOF
${1}
EOF
	BASE64_DECODED=$(sudo base64 -d /tmp/$DB_TEMP_FILE_NAME)

	_func_clear_temp
}

_func_update_db_size_2bytes() {
	if _func_has_been_installed
	then
		du -b ~/$DB_DATA_FILE_NAME 1> /tmp/$DB_TEMP_FILE_NAME

		local DU_INFO=$(cat /tmp/$DB_TEMP_FILE_NAME)
		local FILE_SIZE=${DU_INFO%	*}

		_func_clear_temp

		DB_SIZE=$FILE_SIZE
	else
		_func_report_error_msg NOT_INSTALLED
	fi
}

install() {
	if _func_has_been_installed
	then
		_func_report_error_msg ALREADY_INSTALLED
	else
		# Checklist
		#  
		if [ $# -eq 2 ] 
		then
			if [ "${1}" = "--size" ] || [ "${1}" = "-s" ]
			then
				local AVSIZE_VAL=${2}

				if [ $AVSIZE_VAL -eq 0 ] || [ $AVSIZE_VAL -ge 1025 ]
				then
					_func_report_error_msg PARAMS_ERR
					exit 1
				else
					AVSIZE_VAL=$(($AVSIZE_VAL*1048576))
					AVSIZE=$AVSIZE_VAL
				fi
			fi
		fi
		sudo printf "[SSDB DATEBASE FILE]\n|" > ~/$DB_DATA_FILE_NAME 
		sudo cat > ~/$DB_CONF_FILE_NAME << EOF
[SSDB CONFIGURATION FILE]

NAME=SHDB
VARSION=${VERSION}
RELEASE=${RELEASE}
AUTHOR=YHSPY
AVSIZE=${AVSIZE}
DATE=$(date)
EOF
		# Move to /usr/bin
		sudo cp -f ${0} /usr/bin/shdb
		sudo chmod +x /usr/bin/shdb

		_func_report_info_msg INSTALLED

		#rm -f ${0}
	fi
}

uninstall() {
	if [ -f ~/$DB_CONF_FILE_NAME ] || [ -f ~/$DB_DATA_FILE_NAME ] || [ -f /tmp/$DB_TEMP_FILE_NAME ]
	then
		sudo rm -f ~/.shdb.master.*
		sudo rm -f /tmp/$DB_TEMP_FILE_NAME
		sudo rm -f /usr/bin/shdb

		_func_report_info_msg UNINSTALLED
	else
		_func_report_error_msg NOT_INSTALLED
	fi
}

isset() {
	if _func_has_been_installed
	then
		_func_base64_encode "$1"
		local SHDB_KEY=$BASE64_ENCODED

		# Find key in db
		sudo grep -o "|${SHDB_KEY}[^|]*|" ~/$DB_DATA_FILE_NAME 1> /tmp/$DB_TEMP_FILE_NAME
		local GREP_INFO=$(cat /tmp/$DB_TEMP_FILE_NAME)

		_func_clear_temp

		if [ -n "$GREP_INFO" ] 
		then
			if [ "$2" = --shell ]
			then
				exit 0
			else
				printf "%s\n" [True]
			fi
		else
			if [ "$2" = --shell ]
			then
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

	if [ $DB_SIZE -ge $CONFIG_VAL ]
	then
		_func_report_error_msg DB_OVERFLOW
		exit 1
	fi
	
	if _func_has_been_installed
	then
		_func_base64_encode "$1"
		local SHDB_KEY=$BASE64_ENCODED

		_func_base64_encode "$2"
		local SHDB_VALUE=$BASE64_ENCODED

		# Find key in db
		sudo grep -o "|${SHDB_KEY}[^|]*|" ~/$DB_DATA_FILE_NAME 1> /tmp/$DB_TEMP_FILE_NAME
		local GREP_INFO=$(cat /tmp/$DB_TEMP_FILE_NAME)

		_func_clear_temp

		if [ -n "$GREP_INFO" ] 
		then
			sudo sed -i -e "s#${GREP_INFO}#|${SHDB_KEY}:${SHDB_VALUE}|#g" ~/$DB_DATA_FILE_NAME
		else
			sudo su -c "echo -n '${SHDB_KEY}:${SHDB_VALUE}|' >> $(echo ~)/$DB_DATA_FILE_NAME"
		fi

		if [ "$3" = --shell ]
		then
			exit 0
		else
			printf "%s\n" "[OK]" 
		fi
		
	else
		_func_report_error_msg NOT_INSTALLED
	fi
}

get() {
	if _func_has_been_installed
	then
		_func_base64_encode "$1"
		local SHDB_KEY=$BASE64_ENCODED

		# Find key in db
		sudo grep -o "|${SHDB_KEY}[^|]*|" ~/$DB_DATA_FILE_NAME 1> /tmp/$DB_TEMP_FILE_NAME
		local GREP_INFO=$(cat /tmp/$DB_TEMP_FILE_NAME)

		_func_clear_temp

		if [ -n "$GREP_INFO" ] 
		then
			local SHDB_VAL_TEMP=${GREP_INFO##*:}
			local SHDB_VAL=${SHDB_VAL_TEMP%%|*}

			_func_base64_decode $SHDB_VAL

			if [ "$2" = --shell ]
			then
				printf "%s" "$BASE64_DECODED"
			else
				printf "%s\n" "$BASE64_DECODED"
			fi
		else
			if [ "$2" = --shell ]
			then
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

		# Find key in db
		sudo grep -o "|${SHDB_KEY}[^|]*|" ~/$DB_DATA_FILE_NAME 1> /tmp/$DB_TEMP_FILE_NAME
		local GREP_INFO=$(cat /tmp/$DB_TEMP_FILE_NAME)

		_func_clear_temp

		if [ -n "$GREP_INFO" ] 
		then
			sudo sed -i -e "s/${GREP_INFO}/|/g" ~/$DB_DATA_FILE_NAME

			if [ "$2" = --shell ]
			then
				exit 0
			else
				printf "[Deleted]\n"
			fi
		else
			if [ "$2" = --shell ]
			then
				exit 1
			else
				printf "[Empty]\n"
			fi
		fi
	else
		_func_report_error_msg NOT_INSTALLED
	fi
}

_func_print_status() {
	if _func_has_been_installed
	then
		du -h ~/$DB_DATA_FILE_NAME 1> /tmp/$DB_TEMP_FILE_NAME

		local DU_INFO=$(cat /tmp/$DB_TEMP_FILE_NAME)
		local FILE_SIZE=${DU_INFO%	*}

		_func_clear_temp

		# Get maximum avaliable size
		CONFIG_KEY='AVSIZE'

		_func_get_db_system_item

		# Format size to 'MB'
		local DB_MAXIMUM_SIZE=$CONFIG_VAL
		DB_MAXIMUM_SIZE=$(($DB_MAXIMUM_SIZE/1048576))

		cat << EOF

[SHDB]      
-----------------     
Release Version: ${VERSION} 
Release Date: ${RELEASE}              
Author: YHSPY                       
DB Current Size: ${FILE_SIZE}
DB Maximum Size: ${DB_MAXIMUM_SIZE}MB
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
[shdb INFO] SHDB now has been uninstalled from your system... success
EOF
		;;
		INSTALLED ) 
			cat << EOF
[shdb INFO] SHDB now has been installed on your system... success
EOF
		;;
	esac
}

console() {
	while :
	do
		printf "%s" "shdb > "
		read ORDER
		cat > /tmp/$DB_TEMP_FILE_NAME << EOF
${ORDER}
EOF
		if [ -n "$(grep [[:space:]]*set[[:space:]][^[:space:]]*[[:space:]][^[:space:]]* /tmp/$DB_TEMP_FILE_NAME)" ]
		then
			local ORDER_COMMAND_LINE=$(cat /tmp/$DB_TEMP_FILE_NAME)
			local SHDORDER_COMMAND_LINE_S1=${ORDER_COMMAND_LINE#*set }
			local SHDB_KEY=${SHDORDER_COMMAND_LINE_S1%% *}
			local SHDB_VALUE=${SHDORDER_COMMAND_LINE_S1#${SHDB_KEY} }

			set "$SHDB_KEY" "$SHDB_VALUE"
		elif [ -n "$(grep "[[:space:]]*get[[:space:]][^[:space:]]*" /tmp/$DB_TEMP_FILE_NAME)" ]
		then
			local ORDER_COMMAND_LINE=$(cat /tmp/$DB_TEMP_FILE_NAME)
			local SHDB_KEY=${ORDER_COMMAND_LINE#*get }

			get "$SHDB_KEY"
		elif [ -n "$(grep "[[:space:]]*delete[[:space:]][^[:space:]]*" /tmp/$DB_TEMP_FILE_NAME)" ]
		then
			local ORDER_COMMAND_LINE=$(cat /tmp/$DB_TEMP_FILE_NAME)
			local SHDB_KEY=${ORDER_COMMAND_LINE#*delete }

			delete "$SHDB_KEY"
		elif [ -n "$(grep "[[:space:]]*isset[[:space:]][^[:space:]]*" /tmp/$DB_TEMP_FILE_NAME)" ]
		then
			local ORDER_COMMAND_LINE=$(cat /tmp/$DB_TEMP_FILE_NAME)
			local SHDB_KEY=${ORDER_COMMAND_LINE#*isset }

			isset "$SHDB_KEY"
		elif [ "$ORDER" = "exit" ]
		then
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
if [ "$1" = "-s" ] || [ "$1" = "--shell" ]
then
	if [ $# -eq 4 ]
	then
		case "$2" in
			set )
				set "${3}" "${4}" --shell
			;;
			* )
				_func_report_error_msg PARAMS_ERR
			;;
		esac
	elif [ $# -eq 3 ]
	then 
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
	else
		_func_report_error_msg PARAMS_ERR
	fi
else
	if [ $# -eq 3 ]
	then
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
	elif [ $# -eq 2 ]
	then 
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
	elif [ $# -eq 1 ]
	then
		case "$1" in
			install )
				install
			;;
			status )
				_func_print_status
			;;
			uninstall )
				uninstall
			;;
			console )
				console
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
