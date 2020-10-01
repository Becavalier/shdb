# SHDB

## Description
A simple and lightweight key-value pair DB for shell programming.

## Instructions

### Installation

Install SHDB with defualt settings:
>* `make` 

Specify the maximum available storage size for SHDB:

>* `make SIZE=10` 

\* `SIZE=10` means setting the maximum available storage to 10MB. (the maximum size cannot exceed 1024MB)

## Quick Test

>* `shdb test`

## How to Use

### Normal CLI Mode
>* `shdb status`
>* `shdb [-s|--shell] isset [key]`
>* `shdb [-s|--shell] set [key] [value]`
>* `shdb [-s|--shell] get [key]`
>* `shdb [-s|--shell] delete [key]`
>* `shdb [-s|--shell] count`
>* `shdb uninstall`

### REPL Mode

Use `shdb console` to enter the "REPL" mode.

>* `isset [key]`
>* `set [key] [value]`
>* `get [key]`
>* `delete [key]`
>* `count`
>* `exit`

### Shell Programming Mode

Please use the below syntax in shell programming:

>* `shdb [-s|--shell] isset [key]`
>* `shdb [-s|--shell] set [key] [value]`
>* `shdb [-s|--shell] get [key]`
>* `shdb [-s|--shell] delete [key]`
>* `shdb [-s|--shell] count`


## Issue
Please create an issue if you have any compatibility issues.

## Author
@YHSPY

## License
MIT
