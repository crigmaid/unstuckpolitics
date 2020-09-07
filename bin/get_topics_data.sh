#!/bin/bash -x

initialize()
{
    # dependencies:
    which jq >/dev/null
    [[ $? -ne 0 ]] && echo "please install jq" && exit 1
    which curl >/dev/null
    [[ $? -ne 0 ]] && echo "please install curl" && exit 1

    set -e
    base_url=https://unstuckpolitics.com
	topics_data_dir="../topics-data"
    set +e; mkdir $topics_data_dir; set -e
}

get_all_topics_data()
{
	local i=0
	api_path="/latest.json"
	curl_str="${base_url}${api_path}"
	curl $curl_str > $topics_data_dir/topics$i.json
	next_path=$(cat $topics_data_dir/topics$i.json | \
		jq '.topic_list.more_topics_url' | tr -d "\"" | \
		sed s/latest/latest.json/g)
	
	i=$((i+1))
	while [[ $i -gt 0 ]]
	do
		curl_str="${base_url}${next_path}"
		curl $curl_str > $topics_data_dir/topics$i.json
		topics=$(cat $topics_data_dir/topics$i.json \
			| jq '.topic_list.topics[]')
		next_path=$(cat $topics_data_dir/topics$i.json | \
			jq '.topic_list.more_topics_url' | tr -d "\"" | \
			sed s/latest/latest.json/g)
		if [[ $next_path == 'null' ]]
		then
			set -u
			rm -f $topics_data_dir/topics$i.json
			set +u
			break
		fi
		i=$((i+1))
	done
}

main()
{
    initialize
	get_all_topics_data
}

main
