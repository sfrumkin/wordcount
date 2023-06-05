#bin/bash

base_url=$(cd ../deploy && terraform output --raw base_url)

echo ${base_url}

curl -XPOST ${base_url}/signup -H 'Content-Type: application/json' -d '{ "username": "sfrumkinab", "email": "sfrumkin11@gmail.com", "password": "1234!ABCdef", "name": "Shira" }'

RESPONSE=$(curl -XPOST ${base_url}/signin -H 'Content-Type: application/json' -d '{ "username": "sfrumkinab", "password": "1234!ABCdef" }')

echo ${RESPONSE} > tmp.txt

TOKEN=`grep -o '"id_token": "[^"]*' tmp.txt | grep -o '[^"]*$'`

echo ${TOKEN}

RESPONSE2=$(curl -XPOST ${base_url}/countWords -H "Authorization: Bearer ${TOKEN}" -H 'Content-Type: text/plain' --data-ascii @base64.txt)

echo ${RESPONSE2} > tmp.txt

URL=`grep -o '"url": "[^"]*' tmp.txt | grep -o '[^"]*$'`

echo ${URL}

curl ${URL}