# Foglight API simple tool

This tool allow you to execute some simple http queries to Foglight server.

## How to obtain Foglight access token?
In Foglight console, click on Homes | Administration | User & Security | Manage Users groups, Roles | Select user and grant 'API Access' role.
Set Auth Token: select user and click on 'Set Auth Token'
Copy and paste token into config.env file in accesstoken variable.

## How to use?
* Modify config.env file with the correct foglight credentials: login, password, host, foglight accesstoken.
* Execuete api_foglight.sh


#Screenshots
![](image/instances.png)

![](image/alarms.png)
