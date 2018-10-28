#!/bin/bash

datediff() {
  local ldate=`date +"%m-%d-%Y"`
  y=${ldate##[0-9]*-}
  m=${ldate%%-[0-9]*}
  d=${ldate#[0-9]*-}
  d=${d%-[0-9]*}
  d1="$m/$d/$y"
  y=${end##[0-9]*-}
  m=${end%%-[0-9]*}
  d=${end#[0-9]*-}
  d=${d%-[0-9]*}
  d2="$m/$d/$y"
  d1=$(date -d "$d1" +%s)
  d2=$(date -d "$d2" +%s)
  echo $(( (d2 - d1) / 86400 ))
}
endDate(){
  local d1=$date
  if ! [ -z = "$4"]
    then
      y=${d1##[0-9]*-}
      m=${d1%%-[0-9]*}
      d=${d1#[0-9]*-}
      d=${d%-[0-9]*}
      d2="$m-$d-$((y+1))"
    else
      d2=$4
  fi
  echo -n -e "end_date:$d2\n" >> $number_of_visits
  echo "End date: $d2"
}

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
number_of_visits="$SCRIPTPATH/number_of_visits"
if ! [ -f "$number_of_visits" ]
then
  touch $number_of_visits
  echo "visits:0">$number_of_visits
fi

case "$1" in

  set) echo "visits:$2">$number_of_visits
      echo "You have $2 visits"
      date=`date +"%m-%d-%Y"`
      if ! [ -z "$3" ]
        then
          date="$3"
      fi
      echo -n -e "start_date:$date\n" >> "$number_of_visits"
      echo "Start date: $date"
      endDate;;
  status) head=$(head -n1 $number_of_visits);
          num=${head#visits:}
          echo "$num trains left";
          lastVisit=$(tail -n1 $number_of_visits);
          end=`cat  $number_of_visits | head -n 3 | tail -n 1`
          if [ "$end" = "$lastVisit" ]
          then
            echo "You have no visits"
          else
            end=${end#end_date:}
            last=${lastVisit#*\ }
            numlast=${lastVisit%%\ *}
            d=$(datediff)
            echo "Last visit was: $last."
            echo "It was $numlast times."
            echo "Remain $d days."
          fi
          if [ "$2" = "all" ]
          then
            echo "Your visits:"
            a=0
            while IFS='' read -r line || [[ -n "$line" ]]; do
              if (("$a">2))
              then
                last=${line#*\ }
                numlast=${line%%\ *}
                visits="visits"
                if [ "$numlast" = "1" ]
                then
                  visits="visit"
                fi
                echo "$last: $numlast $visits."
              else
                a="$a"+1
              fi
            done < "$number_of_visits"
          fi;;
  dec)    num=$(head -n1 $number_of_visits);
          num=${num#visits:}
          dec=1
          if ! [ -z "$2" ]
          then
            dec="$2"
          fi
          date=`date +"%m-%d-%Y"`
          if ! [ -z "$3" ]
          then
            date="$3"
          fi
          if [ "$num" = "oo" ]
          then
            echo -n -e "$dec $date\n" >> $number_of_visits
            echo "GOOD JOB!"
          else
            sed -i "1s/.*/visits:$((num-dec))/" $number_of_visits
            echo -n -e "$dec $date\n" >> $number_of_visits
            echo "GOOD JOB!"
            echo "$((num-$dec)) trains left"
          fi;;
  inc)    num=$(head -n1 $number_of_visits);
          num=${num#visits:}
          inc=1
          if ! [ -z "$2" ]
          then
            inc="$2"
          fi
          sed -i "1s/.*/$((num+$inc))/" $number_of_visits;
          echo "$((num+$inc)) trains left";;
esac


#y=${date##[0-9]*-}
#m=${date%%-[0-9]*}
#d=${date#[0-9]*-}
#d=${d%-[0-9]*}
#reg='^[0-9]+$'

#if ! [[ $num =~ $reg ]]
#then
  #>number_of_visits
#fi
#echo "$num"
