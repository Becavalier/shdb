#!/bin/bash

#=================================================================
# SHDB
#
# Desc: A simple, lightweight local nosql db for shell, mainly for data persistence.
# Usage: 
#
# 	Install:
#
# 	bash ./shdb.sh install
#	
#	Use:
#
# 	shdb status
#	shdb set [key] [value]
#	shdb get [key]
#	shdb delete [key]
#	shdb uninstall
#
# Author: YHSPY
# License: MIT
#=================================================================

# Set global variables
BASE64_ENCODED=''

BASE64_DECODED=''

VERSION=0.1
RELEASE=2016/10/07

# Functions here
has_been_installed() {
	# Return 0 represent true
	[ -f ~/.shdb.master.conf ] && [ -f ~/.shdb.master.db ] && return 0 || return 1
}

clear_temp_file() {
	sudo rm -f /tmp/.shdb.tmp
}

base64_encode() {
	cat > /tmp/.shdb.tmp << EOF
${1}
EOF
	BASE64_ENCODED=$(base64 /tmp/.shdb.tmp)

	clear_temp_file
}

base64_decode() {
	cat > /tmp/.shdb.tmp << EOF
${1}
EOF
	BASE64_DECODED=$(base64 -d /tmp/.shdb.tmp)

	clear_temp_file
}

install() {
	if has_been_installed
	then
		report_error_msg ALREADY_INSTALLED
	else
		sudo echo SSDB DATEBASE FILE > ~/.shdb.master.db 
		sudo cat > ~/.shdb.master.conf << EOF
NAME=SHDB
VARSION=${VERSION}
AUTHOR=YHSPY
DATE=$(date)
EOF
		# Move to /usr/bin
		sudo cp ${0} /usr/bin/shdb
		sudo chmod +x /usr/bin/shdb
		report_info_msg INSTALLED

		#rm -f ${0}
	fi
}

uninstall() {
	if [ -f ~/.shdb.master.conf ] || [ -f ~/.shdb.master.db ] || [ -f /tmp/.shdb.tmp ]
	then
		sudo rm -f ~/.shdb.master.*
		sudo rm -f /tmp/.shdb.tmp
		sudo rm -f /usr/bin/shdb

		report_info_msg UNINSTALLED
	else
		report_error_msg NOT_INSTALLED
	fi
}

get() {
	if has_been_installed
	then
		base64_encode "$1"
		local SHDB_KEY=$BASE64_ENCODED

		# Find key in db

		sudo grep -w -n ${SHDB_KEY} ~/.shdb.master.db 1> /tmp/.shdb.tmp
		local GREP_INFO=$(cat /tmp/.shdb.tmp)

		clear_temp_file

		if [ -n "$GREP_INFO" ] 
		then
			local SHDB_VAL=${GREP_INFO##*:}
			base64_decode $SHDB_VAL
			if [ "$2" = --shell ]
			then
				printf "%s" $BASE64_DECODED
			else
				printf "%s\n" $BASE64_DECODED
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
		report_error_msg NOT_INSTALLED
	fi
}

set() {
	if has_been_installed
	then
		base64_encode "$1"
		local SHDB_KEY=$BASE64_ENCODED

		base64_encode "$2"
		local SHDB_VALUE=$BASE64_ENCODED

		# Find key in db
		sudo grep -w -n ${SHDB_KEY} ~/.shdb.master.db 1> /tmp/.shdb.tmp
		local GREP_INFO=$(cat /tmp/.shdb.tmp)

		clear_temp_file

		if [ -n "$GREP_INFO" ] 
		then
			local OLD_VAL=${GREP_INFO#*:}
			sudo sed -i -e "s#${OLD_VAL}#${SHDB_KEY}:${SHDB_VALUE}#g" ~/.shdb.master.db
		else
			sudo sed -i -e "$ a ${SHDB_KEY}:${SHDB_VALUE}" ~/.shdb.master.db
		fi

		if [ "$3" = --shell ]
		then
			exit 0
		else
			printf "%s\n" "{${1} => ${2}}" 
		fi
		
	else
		report_error_msg NOT_INSTALLED
	fi
}

delete() {
	if has_been_installed
	then
		base64_encode "$1"
		local SHDB_KEY=$BASE64_ENCODED

		# Find key in db
		sudo grep -w ${SHDB_KEY} ~/.shdb.master.db 1> /tmp/.shdb.tmp
		local GREP_INFO=$(cat /tmp/.shdb.tmp)

		clear_temp_file

		if [ -n "$GREP_INFO" ] 
		then
			sudo sed -i -e "s/${GREP_INFO}//g" ~/.shdb.master.db

			# Clear empty space in db
			sudo sed -i '/^$/d' ~/.shdb.master.db

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
		report_error_msg NOT_INSTALLED
	fi
}

print_status() {
	if has_been_installed
	then
		ls -al ~/.shdb.master.db 1> /tmp/.shdb.tmp
		local LS_INFO=$(cat /tmp/.shdb.tmp)

		local FILE_SIZE_S1=${LS_INFO#* }
		local FILE_SIZE_S2=${FILE_SIZE_S1#* }
		local FILE_SIZE_S3=${FILE_SIZE_S2#* }
		local FILE_SIZE_S4=${FILE_SIZE_S3#* }
		local FILE_SIZE_S5=${FILE_SIZE_S4% *}
		local FILE_SIZE_S6=${FILE_SIZE_S5% *}
		local FILE_SIZE_S7=${FILE_SIZE_S6% *}
		local FILE_SIZE_S8=${FILE_SIZE_S7% *}
		local FILE_SIZE=${FILE_SIZE_S8% *}

		clear_temp_file

		cat << EOF

[SHDB] v${VERSION}                      
Release Date: ${RELEASE}              
Author: YHSPY                       
DB Size: ${FILE_SIZE} byte

EOF
	else
		report_error_msg NOT_INSTALLED
	fi
}

report_error_msg() {
	case "$1" in 
		PARAMS_ERR ) 
			cat << EOF
[!shdb error!] [SHDB] Invalid parameters or format, please check and re-execute.
EOF
		;;
		ALREADY_INSTALLED ) 
			cat << EOF
[!shdb error!] [SHDB] Had already been installed.
EOF
		;;
		NOT_INSTALLED ) 
			cat << EOF
[!shdb error!] [SHDB] Had not been installed, please try this again after installing.
EOF
		;;
	esac
}

report_info_msg() {
	case "$1" in 
		UNINSTALLED ) 
			cat << EOF
[SHDB] Now has been uninstalled... success
EOF
		;;
		INSTALLED ) 
			cat << EOF
[SHDB] Now has been installed... success
EOF
		;;
	esac
}

console() {
	while :
	do
		printf "%s" "> "
		read ORDER
		cat > /tmp/.shdb.tmp << EOF
${ORDER}
EOF
		if [ -n "$(grep [[:space:]]*set[[:space:]][^[:space:]]*[[:space:]][^[:space:]]* /tmp/.shdb.tmp)" ]
		then
			local ORDER_COMMAND_LINE=$(cat /tmp/.shdb.tmp)
			local SHDORDER_COMMAND_LINE_S1=${ORDER_COMMAND_LINE#*set }
			local SHDB_KEY=${SHDORDER_COMMAND_LINE_S1%% *}
			local SHDB_VALUE=${SHDORDER_COMMAND_LINE_S1#${SHDB_KEY} }

			set $SHDB_KEY $SHDB_VALUE
		elif [ -n "$(grep "[[:space:]]*get[[:space:]][^[:space:]]*" /tmp/.shdb.tmp)" ]
		then
			local ORDER_COMMAND_LINE=$(cat /tmp/.shdb.tmp)
			local SHDB_KEY=${ORDER_COMMAND_LINE#*get }

			get $SHDB_KEY
		elif [ -n "$(grep "[[:space:]]*delete[[:space:]][^[:space:]]*" /tmp/.shdb.tmp)" ]
		then
			local ORDER_COMMAND_LINE=$(cat /tmp/.shdb.tmp)
			local SHDB_KEY=${ORDER_COMMAND_LINE#*delete }

			delete $SHDB_KEY
		elif [ "$ORDER" = "exit" ]
		then
			break
		else
			report_error_msg PARAMS_ERR
		fi
	done
}


# Set system global variable
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
				report_error_msg PARAMS_ERR
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
			* )
				report_error_msg PARAMS_ERR
			;;
		esac
	else
		report_error_msg PARAMS_ERR
	fi
else
	if [ $# -eq 3 ]
	then
		case "$1" in
			set )
				set "${2}" "${3}"
			;;
			* )
				report_error_msg PARAMS_ERR
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
			* )
				report_error_msg PARAMS_ERR
			;;
		esac
	elif [ $# -eq 1 ]
	then
		case "$1" in
			install )
				install
			;;
			status )
				print_status
			;;
			uninstall )
				uninstall
			;;
			console )
				console
			;;
			* )
				report_error_msg PARAMS_ERR 
			;;
		esac
	else
		print_status
	fi
fi

IFS=$PRE_IFS

exit 0
