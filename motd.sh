#!/bin/bash

clear

function color (){
  echo "\e[$1m$2\e[0m"
}

function extend (){
  local str="$1"
  let spaces=74-${#1}
  while [ $spaces -gt 0 ]; do
    str="$str "
    let spaces=spaces-1
  done
  echo "$str"
}

function center (){
  local str="$1"
  let spacesLeft=(92-${#1})/2
  let spacesRight=92-spacesLeft-${#1}
  while [ $spacesLeft -gt 0 ]; do
    str=" $str"
    let spacesLeft=spacesLeft-1
  done

  while [ $spacesRight -gt 0 ]; do
    str="$str "
    let spacesRight=spacesRight-1
  done

  echo "$str"
}

function sec2time (){
  local input=$1

  if [ $input -lt 60 ]; then
    echo "$input seconds"
  else
    ((days=input/86400))
    ((input=input%86400))
    ((hours=input/3600))
    ((input=input%3600))
    ((mins=input/60))

    local daysPlural="s"
    local hoursPlural="s"
    local minsPlural="s"

    if [ $days -eq 1 ]; then
      daysPlural=""
    fi

    if [ $hours -eq 1 ]; then
      hoursPlural=""
    fi

    if [ $mins -eq 1 ]; then
      minsPlural=""
    fi

    echo "$days day$daysPlural, $hours hour$hoursPlural, $mins minute$minsPlural"
  fi
}

borderColor=35
headerLeafColor=32
headerRaspberryColor=31
greetingsColor=36
statsLabelColor=33

borderLine="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
borderTopLine=$(color $borderColor "┏$borderLine┓")
borderBottomLine=$(color $borderColor "┗$borderLine┛")
borderBar=$(color $borderColor "┃")
borderEmptyLine="$borderBar                                                                                                  $borderBar"

# Header
header="$borderTopLine\n$borderEmptyLine\n"
header="$header$borderBar$(color $headerLeafColor "          .~~.   .~~.                                                                             ")$borderBar\n"
header="$header$borderBar$(color $headerLeafColor "         '. \ ' ' / .'                                                                            ")$borderBar\n"
header="$header$borderBar$(color $headerRaspberryColor "          .~ .~~~..~.                      _                          _                           ")$borderBar\n"
header="$header$borderBar$(color $headerRaspberryColor "         : .~.'~'.~. :     ___ ___ ___ ___| |_ ___ ___ ___ _ _    ___|_|                          ")$borderBar\n"
header="$header$borderBar$(color $headerRaspberryColor "        ~ (   ) (   ) ~   |  _| .'|_ -| . | . | -_|  _|  _| | |  | . | |      			   ")$borderBar\n"
header="$header$borderBar$(color $headerRaspberryColor "       ( : '~'.~.'~' : )  |_| |__,|___|  _|___|___|_| |_| |_  |  |  _|_|      			   ")$borderBar\n"
header="$header$borderBar$(color $headerRaspberryColor "        ~ .~ (   ) ~. ~               |_|                 |___|  |_|          			   ")$borderBar\n"
header="$header$borderBar$(color $headerRaspberryColor "         (  : '~' :  )                                                        			   ")$borderBar\n"
header="$header$borderBar$(color $headerRaspberryColor "          '~ .~~~. ~'                                                         			   ")$borderBar\n"
header="$header$borderBar$(color $headerRaspberryColor "              '~'                                                             			   ")$borderBar"

me=$(whoami)

# Greetings
greetings="$borderBar$(color $greetingsColor "$(center "Welcome back, $me!")")      $borderBar\n"
greetings="$greetings$borderBar$(color $greetingsColor "$(center "$(date +"%A, %d %B %Y, %T")")")      $borderBar"

# System information
read lastlogin  <<< $(last $me -2 | awk 'NR==2 { print $4", "$6 " of " $5 " from " $7 " to " $9 " from " $3 " for " $10 " minutes" }')

# get the load averages
read one five fifteen rest < /proc/loadavg

label1="$(extend "$lastlogin")"
label1="$borderBar  $(color $statsLabelColor "Last Login..........:") $label1$borderBar"

uptime="$(sec2time $(cut -d "." -f 1 /proc/uptime))"
uptime="$uptime ($(date -d "@"$(grep btime /proc/stat | cut -d " " -f 2) +"%d-%m-%Y %H:%M:%S"))"

label2="$(extend "$uptime")"
label2="$borderBar  $(color $statsLabelColor "Uptime..............:") $label2$borderBar"

label3="$(extend "$(ps ax | wc -l | tr -d " ")")"
label3="$borderBar  $(color $statsLabelColor "Running Processes...:") $label3$borderBar"

label4="$(extend "${one}, ${five}, ${fifteen} (1, 5, 15 min)")"
label4="$borderBar  $(color $statsLabelColor "Average Load........:") $label4$borderBar"

cpumem=$(vcgencmd get_mem arm | awk '{print substr($1,5) }')
gpumem=$(vcgencmd get_mem gpu | awk '{print substr($1,5) }')

label5="$(extend "CPU(ARM): $cpumem - GPU: $gpumem")"
label5="$borderBar  $(color $statsLabelColor "CPU/GPU Memory Split:") $label5$borderBar"

label6="$(extend "$(free -m | awk 'NR==2 { printf "Total: %sMB, Used: %sMB, Free: %sMB",$2,$3,$4; }')")"
label6="$borderBar  $(color $statsLabelColor "Memory..............:") $label6$borderBar"

label7="$(extend "$(df -h ~ | awk 'NR==2 { printf "Total: %sB, Used: %sB, Free: %sB",$2,$3,$4; }')")"
label7="$borderBar  $(color $statsLabelColor "Home space..........:") $label7$borderBar"

label8="$(extend "$(/opt/vc/bin/vcgencmd measure_temp | cut -c "6-9")ºC")"
label8="$borderBar  $(color $statsLabelColor "CPU Temperature.....:") $label8$borderBar"

localip=$(ip route get 8.8.8.8 | head -1 | cut -d' ' -f7)
publicip=$(wget -q -O - http://icanhazip.com/ | tail)
label9="$(extend "$localip and $publicip")"
label9="$borderBar  $(color $statsLabelColor "IP Addresses........:") $label9$borderBar"

stats="$label1\n$label2\n$label3\n$label4\n$label5\n$label6\n$label7\n$label8\n$label9"

# Print motd
echo -e "$header\n$borderEmptyLine\n$greetings\n$borderEmptyLine\n$stats\n$borderEmptyLine\n$borderBottomLine"
