#!/bin/bash
# command_dev_gamedig_raw.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Raw gamedig output of the server.

info_config.sh

local engine_query_array=( avalanche3.0 madness quakelive realvirtuality refractor source goldsource spark starbound unity3d )
for engine_query in "${engine_query_array[@]}"
do
	if [ "${engine_query}" == "${engine}" ]; then
		gamedigengine="protocol_valve"
	fi
done

local engine_query_array=( avalanche2.0 )
for engine_query in "${engine_query_array[@]}"
do
	if [ "${engine_query}" == "${engine}" ]; then
		gamedigengine="jc2mp"
	fi
done


gamedig --type ${gamedigengine} --host ${ip} --port ${port}