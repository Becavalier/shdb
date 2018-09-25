# SHDB

## Description
A simple and lightweight local key-value pair db for shell script, mainly for data persistence.

Please do not compare SHDB with MySQL, Redis and any other DB programs. SHDB is mainly used on Shell programming, it is easy and simple, only support key-value pair storing, just for shell script programming.


## Features

* Do not occupy any CPU or Memory resource when in idle moment.
* Written in pure shell, lightweight and easy to use.
* Support persistent data storing.
* Support console mode for quick operation in REPL mode.

## Installation Instruction

### Installation
Install SHDB with defualt settings:
>* `make` 

Specify the maximum availabe storage size of SHDB:

>* `make SIZE=1` 

*Parameter `SIZE=1` means set the maximum availabe storage size of SHDB as 1MB. (the maximum size is no more than 1024MB)

## Quick Test

>* `sudo shdb test`

## How to Use

### Normal CLI Mode
>* `shdb status`
>* `shdb [-s|--shell] isset [key]`
>* `shdb [-s|--shell] set [key] [value]`
>* `shdb [-s|--shell] get [key]`
>* `shdb [-s|--shell] delete [key]`
>* `shdb [-s|--shell] count`
>* `shdb uninstall`

### Console Mode

Use `shdb console` to enter the "Console" mode.

>* `isset [key]`
>* `set [key] [value]`
>* `get [key]`
>* `delete [key]`
>* `count`
>* `exit`

### Shell Mode

Please use this mode's syntax in shell programming, "demo.sh" used for instance.

>* `shdb [-s|--shell] isset [key]`
>* `shdb [-s|--shell] set [key] [value]`
>* `shdb [-s|--shell] get [key]`
>* `shdb [-s|--shell] delete [key]`
>* `shdb [-s|--shell] count`

## TODO
- [x] Adapter to blank spaces in content.
- [x] Optimize storing engin as block storing style.
- [x] Long length content support.
- [x] Add new ability to get db storing items' count.

## Issue
Please submit an issue if you have got any compatibility problems, thanks.

## Author
@YHSPY

## License
MIT
