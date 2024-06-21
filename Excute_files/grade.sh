#!/bin/bash

# 서버 URL 및 디렉터리 경로 설정
MANAGE_SERVER="https://f1d4-118-218-37-245.ngrok-free.app"
SUBMISSION_DIR="/home/youngwon/ComGae/submissions"
ANSWER_FILE="/home/youngwon/ComGae/answer.txt"

# 스크립트 실행 시작 메시지
echo "스크립트 실행을 시작합니다..."
echo "제출 디렉토리: $SUBMISSION_DIR"
echo "정답 파일: $ANSWER_FILE"

# 제출 디렉토리에 파이썬 파일이 하나도 없는 경우 실행 중지
if [ -z "$(ls -A "$SUBMISSION_DIR"/*.py 2>/dev/null)" ]; then
    echo "제출 디렉토리에 파이썬 파일이 없습니다. 스크립트를 종료합니다."
    exit 0
fi

# 제출 디렉터리의 모든 .py 파일에 대해 반복
for file in "$SUBMISSION_DIR"/*.py; do
    id=$(basename "$file" .py) # 파일 이름에서 .py 확장자를 제거하여 ID로 사용
    stdout_file="$SUBMISSION_DIR/$id.stdout"
    stderr_file="$SUBMISSION_DIR/$id.stderr"

    echo "현재 파일: $file"
    echo "ID: $id"

    # stdout 및 stderr 파일이 존재하지 않을 경우에만 실행
    if [ ! -f "$stdout_file" ] && [ ! -f "$stderr_file" ]; then
        echo "출력 파일이 없으므로 Python 스크립트를 실행합니다..."

        # Python 파일 실행 및 출력 저장
        python3 "$file" > "$stdout_file" 2> "$stderr_file"

        # stderr 파일이 비어있지 않으면 오류로 간주
        if [ -s "$stderr_file" ]; then
            echo "오류가 발견되었습니다: $stderr_file"
            status="ERROR"
        else
            echo "오류가 없으며 출력을 비교합니다..."
            if diff -q "$stdout_file" "$ANSWER_FILE"; then
                status="CORRECT"
            else
                status="INCORRECT"
            fi
        fi

        echo "상태: $status"

        # JSON 데이터 생성
        json_data=$(jq -n --arg id "$id" --arg status "$status" '{id: ($id|tonumber), status: $status}')
        echo "JSON 데이터: $json_data"

        # 서버에 결과 전송
        response=$(curl -s -o /dev/null -w "%{http_code}" -X PATCH "$MANAGE_SERVER/submission" -d "$json_data" -H "Content-Type: application/json")
        echo "서버 응답: $response"

        # 서버 응답 확인
        if [ "$response" -ne 200 ]; then
            echo "서버 업데이트에 실패했습니다: ID $id"
        fi
    else
        echo "출력 파일이 이미 존재합니다. 실행을 건너뜁니다..."
    fi
    echo ""
done

echo ""