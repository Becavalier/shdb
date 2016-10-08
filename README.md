# SHDB

### Description
A simple and lightweight local nosql db for shell script, mainly for data persistence.

Please do not compare SHDB with MySQL, Redis and any other DB programs. SHDB is mainly used on Shell programming, and also written in Shell, all this features are suitable for Shell programming.


### Features

* Do not occupy any CPU or Memory when in idle moment.
* Written in pure shell, lightweight and easy to use.
* Support persistent data storing.
* Support console mode for quick operation on SHDB.

### Installation

>* sudo bash ./bin/shdb.sh install

### How to Use

#### Normal CLI Mode
>* `shdb status`
>* `shdb [-s|--shell] isset [key]`
>* `shdb [-s|--shell] set [key] [value]`
>* `shdb [-s|--shell] get [key]`
>* `shdb [-s|--shell] delete [key]`
>* `shdb uninstall`

#### Console Mode

Use `shdb console` to enter the Console mode.

>* `isset [key]`
>* `set [key] [value]`
>* `get [key]`
>* `delete [key]`
>* `exit`

#### Shell Mode

Please use this mode's syntax in shell programming, demo used for instnce.

>* `shdb [-s|--shell] isset [key]`
>* `shdb [-s|--shell] set [key] [value]`
>* `shdb [-s|--shell] get [key]`
>* `shdb [-s|--shell] delete [key]`

### TODO
* ~~Adapter to blank spaces in content.~~
* Long length content support.

### Author
@YHSPY

### License
MIT
