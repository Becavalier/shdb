# SHDB

### Description
A simple and lightweight local nosql db for shell script, mainly for data persistence.

* Do not occupy any CPU or Memory when in idle moment.
* Lightweight and easy to use.
* Support persistent data storing.
* Support console mode for quick operation on SHDB.

### Install:

>* sudo bash ./dist/shdb.sh install

### How to Use:

#### Normal CLI Mode
>* `shdb status`
>* `shdb set [key] [value]`
>* `shdb get [key]`
>* `shdb delete [key]`
>* `shdb uninstall`

#### Console Mode

Use `shdb console` to enter the Console mode.

>* `set [key] [value]`
>* `get [key]`
>* `delete [key]`
>* `exit`

#### Shell Mode

Please use this mode's syntax in shell programming, demo used for instnce.

>* `shdb [-s|--shell] set [key] [value]`
>* `shdb [-s|--shell] get [key]`
>* `shdb [-s|--shell] delete [key]`

### Author
YHSPY
### License
MIT
