#!/bin/bash

MANAGE_SERVER="https://f1d4-118-218-37-245.ngrok-free.app"
SUBMISSION_DIR="/home/youngwon/ComGae/submissions"

#curl 은 기본적으로 GET 요청하는거임
#curl -x 를 붙여서 POST PUT DELETE 등 다른거 사용가
#-s : 진행상황을 출력하진 않음.
response=$(curl -s $MANAGE_SERVER/new) 
echo "Response : $response"

#jq는 json 데이터 처리하고 변환하는거
#js -r은 문자열로 만드는거라했나..?
id=$(echo $response | jq '.id')
code=$(echo $response | jq -r '.code')

if [ ! -z "$id" ] && [ "$id" != "null" ]; then
    echo "$code" > "$SUBMISSION_DIR/$id.py" # > 기호는 파일 덮어쓰면서 저장
    echo "Fetched and saved code with ID $id"
fi

echo ""
