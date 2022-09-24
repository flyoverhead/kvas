#!/usr/bin/env bats
source ../libs/main

#================================================================
# 	Данный файл предназначен для тестирования самих тестов
#	Здесь пишутся сами тесты и затем переносятся в соотвествующие
#	файлы етосв с расширением bats
#================================================================
@test "Проверка работы генерации ipset блока в файле конфигурации dnsmasq [/kvas/bin/main/dnsmasq]" {
	adh_file=/opt/apps/kvas/bin/main/dnsmasq
	run on_server "${adh_file} && cat /opt/etc/kvas.dnsmasq"
# 	в случае ошибок в тесте - будет вывод основных критериев работы
	print_on_error "${status}" "${output}"
	[ "${status}" -eq 0 ]
	ipset_num=$(echo "${output}" | grep -c "ipset")
	unblock_num=$(echo "${output}" | grep -c "unblock")
	[ "${ipset_num}" -gt 1 ] && [ "${ipset_num}" -ge "${unblock_num}" ]
}
