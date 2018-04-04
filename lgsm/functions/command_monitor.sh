#!/bin/bash
# LinuxGSM command_monitor.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://linuxgsm.com
# Description: Monitors server by checking for running processes.
# then passes to query_gsquery.sh.

local commandname="MONITOR"
local commandaction="Monitor"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_monitor_loop(){
# Will query up to 4 times every 15 seconds.
# Servers changing map can return a failure.
# Will Wait up to 60 seconds to confirm server is down giving server time to change map.
totalseconds=0
for queryattempt in {1..5}; do
	fn_print_dots "Querying port: ${ip}:${port} : ${totalseconds}/${queryattempt} : "
	fn_print_querying_eol
	fn_script_log_info "Querying port: ${ip}:${port} : ${queryattempt} : QUERYING"
	if [ "${querymethod}" ==  "gamedig" ];then
		fn_print_info "Querying port: gamedig enabled"
		fn_script_log_info "Querying port: gamedig enabled"
		query_gamedig.sh
	elif [ "${querymethod}" ==  "gsquery" ];then
		fn_print_info "Querying port: gsquery.py enabled"
		fn_script_log_info "Querying port: gsquery.py enabled"
		# Downloads gsquery.py if missing
		if [ ! -f "${functionsdir}/gsquery.py" ]; then
			fn_fetch_file_github "lgsm/functions" "gsquery.py" "${functionsdir}" "chmodx" "norun" "noforce" "nomd5"
		fi
		gsquerycmd=$("${functionsdir}"/gsquery.py -a "${ip}" -p "${port}" -e "${engine}" 2>&1)
		querystatus="$?"
	fi

	sleep 0.5
	if [ "${querystatus}" == "0" ]; then
		# Server OK
		fn_print_ok "Querying port: ${ip}:${port} : ${queryattempt} : "
		fn_print_ok_eol_nl
		fn_script_log_pass "Querying port: ${ip}:${port} : ${queryattempt} : OK"
		exitcode=0
		monitorpass=1
		break
	else
		# Server failed query
		fn_script_log_info "Querying port: ${ip}:${port} : ${queryattempt} : ${gsquerycmd}"
		if [ "${querymethod}" ==  "gamedig" ];then
			query_gamedig.sh
		elif [ "${querymethod}" ==  "gsquery" ];then
			# Downloads gsquery.py if missing
			if [ ! -f "${functionsdir}/gsquery.py" ]; then
				fn_fetch_file_github "lgsm/functions" "gsquery.py" "${functionsdir}" "chmodx" "norun" "noforce" "nomd5"
			fi
			gsquerycmd=$("${functionsdir}"/gsquery.py -a "${ip}" -p "${port}" -e "${engine}" 2>&1)
			querystatus="$?"
		fi

		if [ "${queryattempt}" == "5" ]; then
			# Server failed query 4 times confirmed failure
			fn_print_fail "Querying port: ${ip}:${port} : ${totalseconds}/${queryattempt} : "
			fn_print_fail_eol_nl
			fn_script_log_error "Querying port: ${ip}:${port} : ${queryattempt} : FAIL"
			sleep 1

			# Send alert if enabled
			alert="restartquery"
			alert.sh
			command_restart.sh
			break
		fi

		# Seconds counter
		for seconds in {1..15}; do
			fn_print_fail "Querying port: ${ip}:${port} : ${totalseconds}/${queryattempt} : ${red}${gsquerycmd}${default}"
			totalseconds=$((totalseconds + 1))
			sleep 1
			if [ "${seconds}" == "15" ]; then
				break
			fi
		done
	fi
done
}

fn_monitor_check_lockfile(){
	# Monitor does not run it lockfile is not found
	if [ ! -f "${rootdir}/${lockselfname}" ]; then
		fn_print_error_nl "Disabled: No lockfile found"
		fn_script_log_error "Disabled: No lockfile found"
		echo "	* To enable monitor run ./${selfname} start"
		core_exit.sh
	fi
}

fn_monitor_check_update(){
	# Monitor will not check if update is running.
	if [ "$(ps -ef|grep "${selfname} update"|grep -v grep|wc -l)" != "0" ]; then
		fn_print_error_nl "SteamCMD is currently checking for updates"
		fn_script_log_error "SteamCMD is currently checking for updates"
		sleep 1
		core_exit.sh
	fi
}

fn_monitor_check_session(){
	fn_print_dots "Checking session: "
	fn_print_checking_eol
	fn_script_log_info "Checking session: CHECKING"
	sleep 1
	if [ "${status}" != "0" ]; then
		fn_print_ok "Checking session: "
		fn_print_ok_eol_nl
		fn_script_log_pass "Checking session: OK"
	else
		if [ "${gamename}" == "TeamSpeak 3" ]; then
			fn_print_error "Checking session: ${ts3error}: "
		elif [ "${gamename}" == "Mumble" ]; then
			fn_print_error "Checking session: Not listening to port ${port}"
		else
			fn_print_error "Checking session: "
		fi
		fn_print_fail_eol_nl
		fn_script_log_error "Checking session: FAIL"
		alert="restart"
		alert.sh
		fn_script_log_info "Monitor is starting ${servername}"
		sleep 1
		command_restart.sh
	fi
}

fn_monitor_query(){
if [ "${queryenabled}" == "true" ]; then
	fn_print_info "Querying port: query enabled"
	fn_script_log_info "Querying port: query enabled"
	sleep 0.5
	local allowed_engines_array=( avalanche2.0 avalanche3.0 goldsource idtech2 idtech3 idtech3_ql iw2.0 iw3.0 madness quake refractor realvirtuality source spark starbound unity3d unreal unreal2 unreal4 )
	for allowed_engine in "${allowed_engines_array[@]}"
	do
		info_config.sh
		if [ "${engine}" == "unreal" ]||[ "${engine}" == "unreal2" ]; then
			port=$((port + 1))
		elif [ "${engine}" == "realvirtuality" ]; then
			port=$((port + 1))
		elif [ "${engine}" == "spark" ]; then
			port=$((port + 1))
		elif [ "${engine}" == "idtech3_ql" ]; then
			engine="quakelive"
		fi

		if [ -n "${queryport}" ]; then
			port="${queryport}"
		fi
		local query_methods_array=( gamedig gsquery )
		for query_method in "${query_methods_array[@]}"
		do
			if [ -z "${monitorpass}" ]; then
				querymethod="${query_method}"
				fn_monitor_loop
			fi
		done
	done
fi
}

monitorflag=1
fn_print_dots "${servername}"
sleep 1
check.sh
logs.sh
info_config.sh

fn_monitor_check_lockfile
fn_monitor_check_update
fn_monitor_check_session
fn_monitor_query
core_exit.sh
