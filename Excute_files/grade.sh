#!/bin/bash

MANAGE_SERVER="https://4d4d-118-218-37-245.ngrok-free.app"
SUBMISSION_DIR="/home/sijbwer77/ComGae/submissions"
ANSWER_FILE="/home/sijbwer77/ComGae/answer.txt"

for file in $SUBMISSION_DIR/*.py; do # 모든 .py 파일에 대해서 반복해라~
    id=$(basename "$file" .py) # 파일 이름에서 .py 확장자를 제거하여 저장함

    stdout_file="$SUBMISSION_DIR/$id.stdout"
    stderr_file="$SUBMISSION_DIR/$id.stderr"

    if [ ! -f "$stdout_file" ] && [ ! -f "$stderr_file" ]; then
        # stdout 및 stderr 파일이 없을 경우에만 실행
        python3 "$file" > "$stdout_file" 2> "$stderr_file"
        # 이거는 파이썬을 실행하고, 출력을 stdout 오류를 stderr에 저장함

        if [ -s "$stderr_file" ]; then # stderr 파일이 비어있지 않으면 코드 오류임
            status="ERROR"
        else # 오류 파일
            if diff -q "$stdout_file" "$ANSWER_FILE"; then
                status="CORRECT"
            else
                status="INCORRECT"
            fi
        fi

        # JSON 데이터 형식화
        json_data=$(jq -n --arg id "$id" --arg status "$status" '{id: ($id|tonumber), status: $status}')

        # 다시 서버로 결괏값 전송함
        curl -X PATCH "$MANAGE_SERVER/submission" -d "$json_data" -H "Content-Type: application/json"
    fi
done
