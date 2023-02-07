

get_raw_hosts_list() {
    HOSTS=$(or2-describe-instances -p "$MAESTRO_PROJECT" -r "$MAESTRO_REGION" --json --full)
}

parse_host_from_raw_list() {
    local host=$(echo "$1" | jq -rc 'to_entries | .[] | @sh "[\(.key)]=\(.value | tostring)"')
    eval "declare -A host=($host)"
    # {"memory":"15360","privateIp":"10.24.21.14","dnsName":"example.com","description":"super jet","project":"SUPER-PRJ","networks":"fe772f49-8ad9-4b32-addf-ce47446b5038","instanceId":"fkrdr5ter345","vlan":"Server Network","schedules":"ua_db_start,ua_stop","isWindows":"false","state":"running","sshKeySet":"false","locked":"false","owner":"Maestro","image":"Linux8_64-bit","shape":"3XL.40","cpu":"8","tags":"cron:start=ua-db, cron:stop=ua","guestOS":"Linux 8 64-bit","requested":"2022-03-02T05:01:57+00:00","region":"PRG-US7","isExposed":"false","registerOnLuminate":"false","properties":"description=foo","buildImageDate":"01/06/2022"}
    local nif=${host[publicIp]:-"null"},${host[privateIp]:-"null"}
    nif=$(echo "$nif" | sed -E 's/(null,|,+$)//g')
    host[ip]=$(echo $nif | sed -E 's/^([^,$]*).*$/\1/g')
    nif=$(echo $nif | sed -E 's/^([^,$]*)(.*)$/\2/g')
    local desc=${host[description]:-"???"}
    host[env]="???"
    if echo "$desc" | grep -q '^env:' ; then
        host[env]=$(echo "$desc" | sed -E 's/^env:([^ ]*) .*/\1/')
        desc=$(echo "$desc" | sed -E 's/^env:[^ ]* (.*)/\1/')
    fi
    host[name]=$desc
    host[platform]=$([ ${host[isWindows]:-"???"} = "false" ] && echo "-" || echo "windows")
    host[id]=${host[instanceId]:-"???"}
    #local owner=${host[owner]}
    #host[tags]="${host[tags]}, owner: $owner"
    printf "%s##%s##%s##%s##%s##%s##%s##%s\n" "${host[env]}" "${host[name]}" "${host[ip]}" "${host[state]}" "${host[platform]}" "${host[id]}" "${nif}" "${host[tags]}"
}

echo "MAESTRO Cloud functions loaded"

