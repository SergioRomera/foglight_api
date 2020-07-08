#!/bin/sh
. ./config.env

log=./log/
database_name=api-foglight.db
sqlfile=api-foglight.sql

function dwt() { 
  #echo "\033[0;31;40m"$(date "+%Y%m%d-%H%M%S")"\033[0m" 
  d=$(date "+%Y%m%d-%H%M%S")
  printf "\033[0;34;40m$d\033[0m" 
}

function login_to_foglight()
{
  access_string="username=${user}&pwd=${password}&access-token=${accesstoken}"
  curl http://${host}:${port}/api/v1/security/login \
  -H "Accept: application/json" \
  -d "$access_string" >/dev/null 2>&1 > $tmp/login.json
  
  token=`jq '.data.token' $tmp/login.json`
  echo $token > $tmp/token.tmp
  sed 's/"//g' $tmp/token.tmp > $tmp/token
  token=`cat $tmp/token`
  logged="OK"
  }

function get_token()
{
  tput cup 1 0
  printf $token
}

function topology() {

  curl -G http://${host}:${port}/api/v1/topology/$key_filter \
  -H "Accept: application/json" \
  --header "username: $user" \
  --header "pwd: $password" \
  --header "access-token: $token" >/dev/null 2>&1 > $tmp/topology.json

  jq -C '.[]' $tmp/topology.json > $tmp/topology_filtered.json
  
  more $tmp/topology_filtered.json

}

function create_tmp ()
{
  if [ ! -d $tmp ]; then
    mkdir $tmp
  fi
}

function filter()
{
  tput cup 3 0
  printf "Filter:                                                                           "
  tput cnorm
  tput cup 3 0
  printf "Filter: "
  read key_filter
  #tput civis
}

function url_query() {

  http_query="http://${host}:${port}/${api_version}/${api_query}"
  #http_query="curl -G http://${host}:${port}/${api_version}/${api_query} -H \"Accept: application/json\" " \
  #            "--header \"username: ${user}\" --header \"pwd: ${password}\"" \
  #            "--header \"access-token: ${token}\""
  tput cup 4 0
  printf "                                                                                                            "
  curl_query="curl -G \"http://${host}:${port}/${api_version}/${api_query}\" \\
  -H \"Accept: application/json\" \\
  --header \"username: $user\" \\
  --header \"pwd: $password\" \\
  --header \"access-token: $token\""

  tput cup 4 0
  printf "http query: $http_query"
  tput cup 5 0
  printf "curl query: $curl_query"
  curl -G "http://${host}:${port}/${api_version}/${api_query}" \
  -H "Accept: application/json" \
  --header "username: $user" \
  --header "pwd: $password" \
  --header "access-token: $token" >/dev/null 2>&1 > $tmp/api_query.json

  jq -C '.[]' $tmp/api_query.json | grep -i -E "$key_filter" > $tmp/api_query_filtered.json
  
  tput cup 11 0
  more +2 -30 $tmp/api_query_filtered.json

  # l=7
  # c=0
  # l_max=30
  # while IFS= read -r line
  # do
    # tput cup $l $c
    # echo "$line"
    # l=$(($l+1))
    # tput cup $l $c
    # if [ "$l_max" = "$l" ]; then
      # sleep 1
      # #read -p "$*"
      # clear_screen
      # l=7;c=0
    # fi
  # done < $tmp/api_query_filtered.json

}

function menu()
{
  l=0
  c=0
  tput cup $l 0
  printf "Q|ESC:${c_header}Quit${c_r} l:${c_header}Login${c_r} h:${c_header}Hosts${c_r} "
  printf "a:${c_header}Alarms${c_r} i:${c_header}Instances${c_r} "
  printf "c:${c_header}Cartridges${c_b_default} g:${c_header}Agents${c_b_default} "
  printf "t:${c_header}Type Instances${c_b_default} "
  printf "f:${c_b_green}Filter${c_r} j:${c_b_green}JSON Filter${c_b_default} Option:"
  l=$(($l+1));tput cup $l 0;printf "${c_green}Connected:${c_r} $logged ${c_green}Login:${c_r} $user ${c_green}Token:${c_r} $token "
  l=$(($l+1));tput cup $l 0;printf "Host: $host Port: $port API version: $api_version                                 "
  l=$(($l+1));tput cup $l 0;printf "Filter: $key_filter JSON Filter: $json_key_filter                                             "
  l=$(($l+1));tput cup $l 0;printf "http query: $http_query"
  l=$(($l+1));tput cup $l 0;printf "curl query: $curl_query"
  l=$(($l+5));tput cup $l 0;printf "****************************************************************************"
  tput cup 11 0
}

clear_screen() {
  # tput cup 3 0
  # l=3
  
  # while [ $l -lt $lines ]
  # do
    # tput cup $l 0
    # printf ' %.0s' {1..2000}
    # l=$(($l+1))
  # done
  clear
  menu
}

function main()
{
  tput reset
  tput civis # cursor invisible

  lines=$(tput lines)
  columns=$(tput cols)

  create_tmp
  
  while [ true ]
  do
    
    menu
    #clear_screen
    tput civis
    #tput cup 0 100;printf "Option:"
    read -t 1 -n 1 key
    tput cup 5 0
    
    case $key in
         
      l)
      clear_screen
      login_to_foglight;;
      
      f)
      clear_screen
      filter;;
      
      h)
      clear_screen
      api_query="type/Host/"
      url_query;;
      
      a)
      clear_screen
      api_query="alarm/current"
      url_query;;
      

      g)
      clear_screen
      api_query="agent/allAgents/"
      url_query;;

      c)
      clear_screen
      api_query="cartridge/allCartridges"
      url_query;;
      
      i)
      clear_screen
      api_query="type/Host/instances"
      url_query;;

      # d)
      # clear_screen
      # api_query="topology/"
      # url_query;;

      
      t)
      clear_screen
      api_query="type/Host/instances?maxDepth=1&showLinks=true&excludePropertyPatterns=.*Alarm.*,.*State.*"
      url_query;;

      $'\x1b'|q) # ESC 
      tput cnorm;
      first_exec=1
      clear
      exit;;

    esac
    
  done
}

token=""
key=0
key_filter=""
json_key_filter=""
menu="m"
logged="KO"

http_query=""

main
