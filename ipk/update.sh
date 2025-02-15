#!/bin/sh

RED="\033[1;31m";
GREEN="\033[1;32m";
NOCL="\033[m";
LENGTH=68
print_line()(printf "%83s\n" | tr " " "-")
diff_len() {
        charlen=$(echo "${1}" | sed -r "s/[\]033\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
        charlen=${#charlen}
        echo $(( LENGTH - charlen ))
}
ready() {
        size=$(diff_len "${1}")
        printf "%b%-${size}s%b" "${1}"
}
when_ok() (echo -e "${GREEN}ГОТОВО${NOCL}")
when_err() (echo -e "${RED}ОШИБКА${NOCL}" )

package_name=kvas_all.ipk
package_url=https://github.com/qzeleza/kvas/releases/latest/download/${package_name}
list_backup=/opt/etc/hosts.list.backup
host_list=/opt/etc/hosts.list

clear
print_line
echo -e "${GREEN}Начинаем установку пакета КВАС${NOCL}"

mkdir -p /opt/packages || {
	echo "Невозможно создать папку /opt/packages";
	exit 1
}
print_line
ready 'Обновляем opkg...'
{
	opkg update && opkg upgrade && opkg install curl iptables
} &>/dev/null && when_ok || when_err


ready 'Загружаем пакет...'
{

	cd /opt/packages
	curl -sOL "${package_url}"
} &>/dev/null && when_ok || when_err

[ -f "${host_list}" ] && {
	ready 'Сохраняем список разблокировки в архив...'
	mv "${host_list}" "${list_backup}" &>/dev/null && when_ok || when_err
}

ready 'Удаляем предыдущую версию пакета...'
{
	kvas rm yes

} &>/dev/null && when_ok || when_err

ready 'Устанавливаем новую версию пакета...'
{
	opkg install "./${package_name}"

} &>/dev/null && when_ok || when_err

print_line
sleep 1

{
    clear
    kvas setup update
}

[ -f "${list_backup}" ] && {
	ready 'Восстанавливаем список разблокировки из архива...'
	kvas import "${list_backup}" &>/dev/null && when_ok || when_err
}

print_line
sleep 2
rm -f ./update.sh