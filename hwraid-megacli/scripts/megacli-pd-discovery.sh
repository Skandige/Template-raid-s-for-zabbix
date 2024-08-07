#!/usr/bin/env bash

data=$(grep "^Adapter #" /tmp/megacli-raid-data-harvester.out | cut -d# -f2)
data_enc=$(grep -w "Device ID" /tmp/megacli-raid-data-harvester.out | awk '{print $4}')
data_pd=$(for a in $data;
            do
              for e in $data_enc;
                do
                 grep -wE -A 10 "pd begin $a" /tmp/megacli-raid-data-harvester.out |sed -n -e "/Enclosure Device ID: $e/,/Slot Number:/p" | grep -wE 'Slot Number:' | awk -v adp=$a -v enc=$e '{print adp":"enc":"$3}'
                done
            done| sort -u)


adp_list=$(/usr/sbin/megacli adpallinfo aALL nolog |grep "^Adapter #" |cut -d# -f2)

enc_list=()
for a in $adp_list; do
  enc_list+=($(/usr/sbin/megacli encinfo a$a nolog | grep -w "Device ID" | awk '{print $4}'))
done
unique_enc_list=($(echo "${enc_list[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

pd_list=()
for a in $adp_list; do
  for e in ${unique_enc_list[@]}; do
    pd_list+=($(/usr/sbin/megacli pdlist a$a nolog | sed -n -e "/Enclosure Device ID: $e/,/Slot Number:/p" | grep -wE 'Slot Number:' | awk -v adp=$a -v enc=$e '{print adp":"enc":"$3}'))
  done
done

if [[ $1 = raw ]]; then
  for pd in ${pd_list[@]}; do echo $pd; done ; exit 0
fi

echo -n '{"data":['
for pd in $data_pd; do
  echo -n "{\"{#CONTROLLER}\": \"$(echo "$pd" | cut -d ':' -f 1)\", \"{#BAY}\": \"$(echo "$pd" | cut -d ':' -f 2)\", \"{#PD}\": \"$(echo "$pd" | cut -d ':' -f 3)\"},"
done | sed -e 's|},$|}|'
echo -n ']}'

