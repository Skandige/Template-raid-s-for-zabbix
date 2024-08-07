#!/usr/bin/env bash

PATH=/etc:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

data=$(cat /tmp/megacli-raid-data-harvester.out | grep "^Adapter #" |cut -d# -f2)
data_ld=$(for a in $data; do cat /tmp/megacli-raid-data-harvester.out |grep -w "^Virtual Drive:" |awk '{print $3}' |while read ld ; do echo $a:$ld; done ; done)

adp_list=$(/usr/sbin/megacli adpallinfo aALL nolog |grep "^Adapter #" |cut -d# -f2)
ld_list=$(for a in $adp_list; do /usr/sbin/megacli ldinfo lall a$a nolog |grep -w "^Virtual Drive:" |awk '{print $3}' |while read ld ; do echo $a:$ld; done ; done)

if [[ $1 = raw ]]; then
  for ld in ${ld_list}; do echo $ld; done ; exit 0
fi

echo -n '{"data":['
for ld in $data_ld; do
  echo -n "{\"{#CONTROLLER}\": \"$(echo "$ld" | cut -d ':' -f 1)\", \"{#LD}\": \"$(echo "$ld" | cut -d ':' -f 2)\"},"
done | sed -e 's|},$|}|'
echo -n ']}'

