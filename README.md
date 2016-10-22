# SHDB

## Description
A simple and lightweight local key-value pair db for shell script, mainly for data persistence.

Please do not compare SHDB with MySQL, Redis and any other DB programs. SHDB is mainly used on Shell programming, it is easy and simple, only support key-value pair storing, just for shell script programming.


## Features

* Do not occupy any CPU or Memory when in idle moment.
* Written in pure shell, lightweight and easy to use.
* Support persistent data storing.
* Support console mode for quick operation in CLI mode.

## Installation Instruction

### Clone with SSH
>* `git clone git@github.com:Becavalier/SHDB.git`

### Clone with HTTPS
>* `git clone https://github.com/Becavalier/SHDB.git`

### Installation
Install SHDB use defualt settings:
>* `make` 

Specify the maximum availabe storage size of SHDB:

>* `make SIZE=1` 

Parameter `SIZE=1` means set the maximum availabe storage size of SHDB as 1MB. (the maximum size is no more than 1024MB)

## Quick Test

>* `make test`

## How to Use

![image](https://github.com/Becavalier/SHDB/blob/master/imgs/screenshot.jpg?raw=true)

### Normal CLI Mode
>* `shdb status`
>* `shdb [-s|--shell] isset [key]`
>* `shdb [-s|--shell] set [key] [value]`
>* `shdb [-s|--shell] get [key]`
>* `shdb [-s|--shell] delete [key]`
>* `shdb uninstall`

### Console Mode

Use `shdb console` to enter the Console mode.

>* `isset [key]`
>* `set [key] [value]`
>* `get [key]`
>* `delete [key]`
>* `exit`

### Shell Mode

Please use this mode's syntax in shell programming, demo used for instance.

>* `shdb [-s|--shell] isset [key]`
>* `shdb [-s|--shell] set [key] [value]`
>* `shdb [-s|--shell] get [key]`
>* `shdb [-s|--shell] delete [key]`

## TODO
* ~~Adapter to blank spaces in content.~~
* ~~Optimize storing engin as block storing style.~~
* ~~Long length content support.~~
* Add new ability to get db storing items' count.
* Add new ability to choose storing engins (File / [GDBM](http://www.gnu.org.ua/software/gdbm/manual.html)).

## Author
@YHSPY

## License
MIT
