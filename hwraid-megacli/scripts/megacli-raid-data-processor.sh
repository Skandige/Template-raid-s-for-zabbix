#!/usr/bin/env bash

PATH="/usr/local/bin:/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/bin"

megacli=$(which megacli)
data_tmp="/tmp/megacli-raid-data-harvester.tmp"
data_out="/tmp/megacli-raid-data-harvester.out"
adp_list=$(/usr/libexec/zabbix-extensions/scripts/megacli-adp-discovery.sh raw)
ld_list=$(/usr/libexec/zabbix-extensions/scripts/megacli-ld-discovery.sh raw)
pd_list=$(/usr/libexec/zabbix-extensions/scripts/megacli-pd-discovery.sh raw)

echo -n > $data_tmp

# берем список контроллеров и берем с каждого информацию.
echo "### adp section begin ###" >> $data_tmp
for adp in $adp_list;
  do
    echo "### adp begin $adp ###" >> $data_tmp
    $megacli adpallinfo a$adp nolog >> $data_tmp
    echo "### adp end $adp ###" >> $data_tmp
  done
echo "### adp section end ###" >> $data_tmp

# перебираем все контроллеры и все логические тома на этих контроллерах
echo "### ld section begin ###" >> $data_tmp
  for ld in $ld_list;
    do
      a=$(echo $ld|cut -d: -f1)
      l=$(echo $ld|cut -d: -f2)
      echo "### ld begin $a $l  ###" >> $data_tmp
      $megacli ldinfo l$l a$a nolog >> $data_tmp
      echo "### ld end $a $l ###" >> $data_tmp
    done
echo "### ld section end ###" >> $data_tmp

# перебираем все контроллеры и все физические диски на этих контроллерах
echo "### pd section begin ###" >> $data_tmp
for pd in $pd_list;
  do
    a=$(echo $pd|cut -d: -f1)
    e=$(echo $pd|cut -d: -f2)
    p=$(echo $pd|cut -d: -f3)
    echo "### pd begin $a $e $p ###" >> $data_tmp
    $megacli pdinfo physdrv [$e:$p] a$a nolog >> $data_tmp
    echo "### pd end $a $e $p ###" >> $data_tmp
  done
echo "### pd section end ###" >> $data_tmp

mv $data_tmp $data_out

