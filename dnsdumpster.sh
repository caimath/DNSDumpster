#!/usr/bin/env bash

# Export /env
source .env

# Query Domains#
# Domain
read -p "Search domain : " DOMAIN

# Request
REQUEST=$(curl -H "X-API-Key: $APIKEY" https://api.dnsdumpster.com/domain/$DOMAIN)


#RENDER REQUEST #
# A
cat <<EOF

#############
# A Records #
#############
EOF
echo $REQUEST | jq -r '.a[] | "Host: \(.host) | IP: \(.ips[].ip) \nASN: \(.ips[].asn_name) - PTR: \(.ips[].ptr)\n"'
echo $REQUEST | jq -r '"Count: \(.total_a_recs) A Records "'

# MX
cat <<EOF

##############
# MX Records #
##############
EOF
echo $REQUEST | jq -r '.mx[] |"Host : \(.host) | IP: \(.ips[].ip) - \(.ips[].asn_name)"'

# NS
cat <<EOF

##############
# NS Records #
##############
EOF
echo $REQUEST | jq -r '.ns[] |"Host : \(.host) - asn: \(.ips[].asn_name) \n - IP: \(.ips[].ip)\n"'

#TXT
cat <<EOF
###############
# TXT Records #
###############
EOF
echo $REQUEST | jq -r '"* \(.txt[])"' | sed 's/"//g'

# DMARC
cat <<EOF

#########
# DMARC #
#########
EOF
DMARC=$(dig +short TXT _dmarc.$DOMAIN)
if [[ $DMARC == *"p=reject"* && $DMARC == *"sp=reject"* ]]
then
    echo "Your DMARC policy is well configured."

elif [[ -z "$DMARC" ]]
then
    echo "Your DMARC policy is not configured."

else
    echo "Your DMARC policy is not configured correctly."
    echo $DMARC
fi
