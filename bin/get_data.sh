#!/bin/bash

initialize()
{
    # dependencies:
    which jq >/dev/null
    [[ $? -ne 0 ]] && echo "please install jq" && exit 1
    which curl >/dev/null
    [[ $? -ne 0 ]] && echo "please install curl" && exit 1

    set -e
    base_url=https://unstuckpolitics.com
    order_by="likes_received"
    data_dir="../data"
    #set +e; mkdir $data_dir; set -e
}

get_all_user_data()
{
    # get first page
    local i=0
    api_path="/directory_items.json?period=all&order=$order_by"
    curl_str="${base_url}${api_path}"
    curl $curl_str > $data_dir/data$i.json
    next_path=$(cat $data_dir/data$i.json | jq '.meta.load_more_directory_items' | tr -d "\"")

    # loop until directory_items is empty
    i=$((i+1))
    while [[ $i -gt 0 ]] 
    do
        curl_str="${base_url}${next_path}"
        curl $curl_str > $data_dir/data$i.json
        dir_items=$(cat $data_dir/data$i.json | jq '.directory_items[]')
        if [[ -z $dir_items ]]
        then
            set -u
            rm -f $data_dir/data$i.json
            set +u
            break
        fi
        next_path=$(cat $data_dir/data$i.json | jq '.meta.load_more_directory_items' | tr -d "\"")
        i=$((i+1))
    done
}

main()
{
    initialize
    get_all_user_data
}

main
