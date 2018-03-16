#!/bin/bash
# command_dev_gamedig_raw.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Querys a gameserver using gamedig.

if [ "$(command -v gamedig 2>/dev/null)" ]&&[ "$(command -v jq 2>/dev/null)" ]; then
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

	local engine_query_array=( avalanche3.0 madness quakelive realvirtuality refractor source goldsource spark starbound unity3d )
	for engine_query in "${engine_query_array[@]}"
	do
		if [ "${engine_query}" == "${engine}" ]; then
			gamedigengine="protocol-valve"
		fi
	done

	local engine_query_array=( avalanche2.0 )
	for engine_query in "${engine_query_array[@]}"
	do
		if [ "${engine_query}" == "${engine}" ]; then
			gamedigengine="jc2mp"
		fi
	done

	local engine_query_array=( idtech2 iw2.0 )
	for engine_query in "${engine_query_array[@]}"
	do
		if [ "${engine_query}" == "${engine}" ]; then
			gamedigengine="protocol-quake2"
		fi
	done

	local engine_query_array=( idtech3 quake iw3.0 )
	for engine_query in "${engine_query_array[@]}"
	do
		if [ "${engine_query}" == "${engine}" ]; then
			gamedigengine="protocol-quake3"
		fi
	done

	local shortname_query_array=( ts3 )
	for shortname_query in "${shortname_query_array[@]}"
	do
		if [ "${engine_query}" == "${shortname}" ]; then
			gamedigengine="teamspeak3"
		fi
	done

	# raw output
	gamedigraw=$(gamedig --type "${gamedigengine}" --host "${ip}" --port "${port}")

	# numplayers
	gdplayers=$(echo "${gamedigraw}" | jq -re '.players|length')

	# current map
	gdmap=$(echo "${gamedigraw}" | jq -re '.map')

	# numbots
	gdbots=$(echo "${gamedigraw}" | jq -re '.raw.numbots')
fi