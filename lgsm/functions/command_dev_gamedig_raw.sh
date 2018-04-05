#!/bin/bash
# command_dev_gamedig_raw.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Raw gamedig output of the server.

echo "================================="
echo "Gamedig Raw Output"
echo "================================="
echo""
if [ ! "$(command -v gamedig 2>/dev/null)" ]; then
	fn_print_fail_nl "gamedig not installed"
	core_exit.sh
fi

info_config.sh
if [ "${engine}" == "unreal" ]||[ "${engine}" == "unreal2" ]; then
	port=$((port + 1))
elif [ "${engine}" == "realvirtuality" ]; then
	port=$((port + 1))
elif [ "${engine}" == "spark" ]; then
	port=$((port + 1))
elif [ "${engine}" == "idtech3_ql" ]; then
	engine="quakelive"
elif [ "${gamename}" == "TeamSpeak 3" ]; then
	port="${queryport}"
fi

if [ -n "${queryport}" ]; then
	port="${queryport}"
fi
query_gamedig.sh
echo "gamedig --type \"${gamedigengine}\" --host \"${ip}\" --port \"${port}\"|jq"
echo""
echo "${gamedigraw}" | jq
echo""
echo "================================="
echo "gsquery Raw Output"
echo "================================="
echo""
if [ ! -f "${functionsdir}/query_gsquery.py" ]; then
	fn_fetch_file_github "lgsm/functions" "query_gsquery.py" "${functionsdir}" "chmodx" "norun" "noforce" "nomd5"
fi
"${functionsdir}"/query_gsquery.py -a "${ip}" -p "${port}" -e "${engine}"