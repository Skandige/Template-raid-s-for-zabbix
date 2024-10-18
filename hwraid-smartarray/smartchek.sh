#!/bin/bash

# Автоопределение слота контроллера
slot=$(ssacli ctrl all show | grep -i "E208e-p" | awk '{print $9}')

# Проверка, что слот найден
if [ -z "$slot" ]; then
    echo "Контроллер не найден"
    exit 1
fi

# Если аргумент не передан, используем устройство по умолчанию (/dev/sda)
DEVICE=${1:-/dev/sda}

# Проверяем, существует ли устройство
if ! lsblk | grep -q "$(basename "$DEVICE")"; then
    echo "Устройство $DEVICE не найдено"
    exit 1
fi

echo "Контроллер найден в слоте: $slot"
num=$(( $(ssacli ctrl slot=$slot pd all show | grep "physicaldrive" | wc -l) -1 ))
ssacli ctrl slot=$slot pd all show detail > /tmp/ssacli.tmp

    # Основной цикл по возможным слотам дисков в RAID
   for i in $(seq 0 $num); do
        # Получаем данные SMART для каждого диска
        smart_data=$(smartctl -a $DEVICE -d cciss,$i )

        
        # Проверяем важные параметры SMART
        serial_number=$(echo "$smart_data" | grep -i "Serial Number" | awk '{print $3}' )
        seek_error_rate=$(echo "$smart_data" | grep -i "Seek_Error_Rate" | awk '{print $10}' )
        reallocated_sector=$(echo "$smart_data" | grep -i "Reallocated_Sector_Ct" | awk '{print $10}' )
        pending_sector=$(echo "$smart_data" | grep -i "Current_Pending_Sector" | awk '{print $10}' )
        offline_uncorrectable=$(echo "$smart_data" | grep -i "Offline_Uncorrectable" | awk '{print $10}')
        raw_read_error_rate=$(echo "$smart_data" | grep -i "Raw_Read_Error_Rate" | awk '{print $10}')
        power_on_hours=$(echo "$smart_data" | grep -i "Power_On_Hours" | awk '{print $10}')

        name_drive=$(cat /tmp/ssacli.tmp | grep -B 12 "Serial Number: $serial_number" | grep "physicaldrive"| awk '{print $2}')

        # Выводим данные, если есть ошибки
        if [[ -n "$name_drive" ]]; then
           echo "Name Drive : $name_drive"
        fi
        if [[ -n "$serial_number" ]]; then
            echo "Serial Number : $serial_number"
        fi
        if [[ -n "$seek_error_rate" ]]; then
            echo "Seek Error Rate : $seek_error_rate "
        fi
        if [[ -n "$reallocated_sector" ]]; then
            echo "Reallocated Sector Count : $reallocated_sector"
        fi
        if [[ -n "$pending_sector" ]]; then
            echo "Current Pending Sector : $pending_sector"
        fi
        if [[ -n "$offline_uncorrectable" ]]; then
            echo "Offline Uncorrectable : $offline_uncorrectable"
        fi
        if [[ -n "$raw_read_error_rate" ]]; then
            echo "Raw_Read_Error_Rate : $raw_read_error_rate"
        fi
        if [[ -n "$power_on_hours" ]]; then
           echo "Power_On_Hours : $power_on_hours" 
           echo " "
        fi 
    done
