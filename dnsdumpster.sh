#!/usr/bin/env bash

# Export /env
source .env

# FUNCTION
# Query domain with the API DNSDumpster
query_domain() {

    # Request
    REQUEST=$(curl -H "X-API-Key: $APIKEY" https://api.dnsdumpster.com/domain/$DOMAIN)

    #RENDER REQUEST #
    # A
    echo -e "\n#############\n# A Records #\n#############"
    echo $REQUEST | jq -r '.a[] | "Host: \(.host) | IP: \(.ips[].ip) \nASN: \(.ips[].asn_name) - PTR: \(.ips[].ptr)\n"'
    echo $REQUEST | jq -r '"Count: \(.total_a_recs) A Records "'

    # MX
    echo -e "\n##############\n# MX Records # \n##############"
    echo $REQUEST | jq -r '.mx[] |"Host : \(.host) | IP: \(.ips[].ip) - \(.ips[].asn_name)"'

    # NS
    echo -e "\n##############\n# NS Records #\n##############"
    echo $REQUEST | jq -r '.ns[] |"Host : \(.host) - asn: \(.ips[].asn_name) \n - IP: \(.ips[].ip)\n"'

    #TXT
    echo -e "\n###############\n# TXT Records #\n###############"
    echo $REQUEST | jq -r '"* \(.txt[])"' | sed 's/"//g'
}

# Query DMARC with dig 
query_dmarc() {
    
    # dmarc query to DNS
    echo -e "\n#########\n# DMARC #\n#########"
    DMARC=$(dig +short TXT _dmarc.$DOMAIN)

    # Check if dmarc policy is well configured
    if [[ $DMARC == *"p=reject"* ]]; then
        if [[ $DMARC == *"sp=none"* || $DMARC == *"sp=quarantine"* ]]; then
            echo "Your DMARC policy is not configured correctly."
        fi

        echo "Your DMARC policy is well configured."

    elif [[ -z "$DMARC" ]]
    then
        echo "Your DMARC policy is not configured."

    else
        echo "Your DMARC policy is not configured correctly."
    fi

    echo $DMARC
}

# User chooses 1 domain or file
query_user_choice() {
    echo "1) Search DNS Records for one domain"
    echo "2) Select a file with multiple domains"
    read -p "Type 1 or 2: " CHOICE

    # Force user to choose 1 or 2
    while [[ $CHOICE -ne 1 && $CHOICE -ne 2 ]]; do
        echo "Invalid choice, please type 1 or 2"
        query_user_choice
    done
}

# Read file
: '
 * Use query_domain and query_dmarc functions for each domain in specified file
'
query_file() {

    # User chooses a file 
    FILE=$(fzf)

    # Search DNS records for each domain in file
    echo "Searching domains in $FILE"
    while read -r line || [ -n "$line" ]; do
        DOMAIN=$line
        query_domain
        query_dmarc
    done < $FILE
}

# main program
main_program() {

    # User choice
    query_user_choice

    # Check user choice
    if [[ $CHOICE -eq 1 ]]
    then 
        read -p "Search domain: " DOMAIN 
        query_domain 
        query_dmarc 
    elif [[ $CHOICE -eq 2 ]]
    then 
        query_file
    else 
        echo "Invalid Choice" ;fi
}

# Launch program
main_program
