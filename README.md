# sap-hana-cloud-trial
Management script for experimenting with SAP HANA Cloud DB Trial using Eclipse via Tunnels with the goal of using the Eclipse-based modelling tools for cloud based HANA DBs

## Overview
SAP offers trial versions of their cloud based HANA DB which will automatically stop running after 12 Hours and are deleted after a week, but they come free of charge and are therefore very usefull for experiments or in teaching settings.

This repository

## Configuration
### Prerequesits
 - Eclipse 2018-12 R from https://www.eclipse.org/downloads/packages/release/2018-12/r
 - Modelling tools for Eclipse from https://tools.hana.ondemand.com/2018-12/
 - ``` /tools``` directory from the SAP Cloud Platform Neo Environment SDK Version ```Java Web Tomcat 8``` from https://tools.hana.ondemand.com/#cloud containing the ```neo``` command line tool
 
### Configuration values for the script itself
``` powershell
$CloudHost = 'hanatrial.ondemand.com';
$database = ''; # database name
$user = ''; # sap cloud user or email
$subaccount = ''; # database sub account, usually <user>trial
$password = ''; # password 

$neo = ''; # Path to the neo SDK's neo.bat from https://tools.hana.ondemand.com/#cloud
$eclipse = ''; # Path to a compatble eclipse's version of eclipse.exe
$env:JAVA_HOME = ''; # Path to Java, works with Java 8, but not with Java 11. 
```
## Usage
Starting the script will
1. Query if the configured database is already running
2. Start the database if it is not running and wait for it to come online
3. Create a new tunnel to the database on ```localhost:30015``` with InstanceId ```00```
4. Start eclipse
5. Wait for eclipse to close
6. Close the tunnel and shut down the database
 
