
get_raw_hosts_list() {
    HOSTS=$(aws --output json --profile $PROFILE ec2 describe-instances \
        --query 'Reservations[*].Instances[*].{nif:NetworkInterfaces[*].PrivateIpAddresses[*].{public:Association.PublicIp,private:PrivateIpAddress},tags:Tags,state:State.Name,platform:Platform,id:InstanceId}')
    #--instance-ids i-0f98c3e67f0f50bde \
}

parse_host_from_raw_list() {
    local host=$(echo "$1" | jq -rc '.[] | to_entries | .[] | @sh "[\(.key)]=\(.value | tostring)"')
    eval "declare -A host=($host)"
    local nif=${host[nif]}
    nif=$(echo "$nif" | jq -rc '[.[][] | to_entries[]] | reduce .[] as $d (null; .[$d.key] += [$d.value])')
    nif=$(echo "$nif" | jq -rc '(.public | tostring)+ "," + (.private | tostring) + ","' | tr -d '[]"' | sed -E 's/(null,|,+$)//g')
    host[ip]=$(echo $nif | sed -E 's/^([^,$]*).*$/\1/g')
    nif=$(echo $nif | sed -E -e 's/^([^,$]*)(.*)$/\2/g' -e 's/^,//')
    local tags=${host[tags]}
    tags=$(echo "$tags" | jq -rc '[.[] | .["key"] = .Key | .["value"] = .Value] | from_entries')
    local names=$(echo "$tags" | jq -rc 'to_entries | .[] | @sh "[\(.key)]=\(.value | tostring)"')
    tags=$(echo "$tags" \
        | jq -rc '[to_entries[] | .["v"] = .key + "=" + (.value | tostring)] | reduce .[] as $d (null; .["xxx"] += [$d.v]) | .xxx' \
        | tr -d '[]"'
    )
    host[tags]=$tags
    eval "declare -A names=($names)"
    host[name]=${names[Name]:-"???"}
    host[env]=${names[Environment]:-"???"}
    if [ "x${host[platform]}" = "xnull" ]; then
        host[platform]="-"
    fi
    printf "%s##%s##%s##%s##%s##%s##%s##%s\n" ${host[env]} ${host[name]} ${host[ip]} ${host[state]} ${host[platform]} ${host[id]} ${nif} ${host[tags]}
}

echo "AWS Cloud functions loaded"

