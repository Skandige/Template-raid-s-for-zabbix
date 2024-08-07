#!/usr/bin/env bash

PATH=/etc:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

data=$(cat /tmp/megacli-raid-data-harvester.out | grep "^Adapter #" |cut -d# -f2)

adp_list=$(/usr/sbin/megacli adpallinfo aALL nolog |grep "^Adapter #" |cut -d# -f2)

if [[ $1 = raw ]]; then
  for adp in ${adp_list}; do echo $adp; done ; exit 0
fi

echo -n '{"data":['
for adp in $data; do echo -n "{\"{#ADPNUM}\": \"$adp\"},"; done |sed -e 's:\},$:\}:'
echo -n ']}'
