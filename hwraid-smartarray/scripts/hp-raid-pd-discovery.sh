#!/usr/bin/env bash

data="/tmp/hp-raid-data-harvester.out"

if [ -f "$data" ]; then
  pd_list=$(sed -n -e '/pd section begin/,/pd section end/p' "$data" | grep -w 'pd begin' | awk '{print $4 ":" $5}')
else
  echo "$data not found."
  exit 1
fi

if [[ $1 = raw ]]; then
  for line in ${pd_list}; do
    echo "$line"
  done
  exit 0
fi

echo -n '{"data":['
for pd in $pd_list; do
  echo -n "{\"{#CONTROLLER}\": \"$(echo "$pd" | cut -d ':' -f 1)\", \"{#PD}\": \"$(echo "$pd" | cut -d ':' -f 2-4)\"},"
done | sed -e 's|},$|}|'
echo -n ']}'
