#bin/bash

base_url='https://g4t1xnsjll.execute-api.eu-central-1.amazonaws.com/serverless_gw_stage'

curl -XPOST ${base_url}/signup -H 'Content-Type: application/json' -d '{ "username": "sfrumkin34", "email": "sfrumkin11@gmail.com", "password": "1234!ABCdef", "name": "Shira" }'

RESPONSE=$(curl -XPOST ${base_url}/signin -H 'Content-Type: application/json' -d '{ "username": "sfrumkin34", "password": "1234!ABCdef" }')

echo ${RESPONSE} > tmp.txt

TOKEN=`grep -o '"id_token": "[^"]*' tmp.txt | grep -o '[^"]*$'`

echo ${TOKEN}

curl -XPOST ${base_url}/countWords -H "Authorization: Bearer ${TOKEN}" -H 'Content-Type: text/plain' --data-ascii @base64.txt