// submissionForm 클릭 이벤트
document.getElementById('submissionForm').addEventListener('submit', async function (event) {
    // 새로고침 방지
    event.preventDefault();
    
    // 사용자 입력 값을 변수에 저장
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    const code = document.getElementById('code').value;

    try {
        // axios를 사용하여 POST 요청을 보냅니다.
        const response = await axios.post('https://f1d4-118-218-37-245.ngrok-free.app/submission', {
            username: username,
            password: password,
            code: code
        });

        // 응답 상태 및 데이터 출력
        console.log('Response:', {
            statusCode: response.status, // 응답의 상태 코드
            data: response.data // 응답 데이터
        });

        if (response.status === 200) {
            alert(`Submission successful! Your submission ID is ${response.data.id}`);
        } else {
            alert(`Error: ${response.data.detail}`);
        }
    } catch (error) {
        // 에러 응답이 있는 경우 콘솔에 출력
        if (error.response) {
            console.error('Error:', {
                message: error.message,
                statusCode: error.response.status, // 에러 응답의 상태 코드
                details: error.response.data // 에러 응답의 세부 정보
            });
        } else {
            console.error('Error:', error.message); // 일반 에러 메시지
        }
        alert('코드 제출에 실패하였습니다.');
    }
});

// checkForm 이벤트 처리
document.getElementById('checkForm').addEventListener('submit', async function (event) {
    // 새로고침 방지
    event.preventDefault();
    
    // 변수에 저장
    const username = document.getElementById('checkUsername').value;
    const password = document.getElementById('checkPassword').value;
    const id = document.getElementById('checkId').value;

    try {
        // axios GET 요청
        const response = await axios.get('https://f1d4-118-218-37-245.ngrok-free.app/submission', {
            params: {
                username: username,
                password: password,
                id: id
            },
            headers: {
                'ngrok-skip-browser-warning': 'true' //ngrok 경고창 건너뛰기
            }
        });

        // 응답 상태 및 데이터 출력
        console.log('Response:', {
            statusCode: response.status, // 응답의 상태 코드
            data: response.data // 응답 데이터
        });

        if (response.status === 200) {
            document.getElementById('results').innerText = JSON.stringify(response.data, null, 2);
        } else {
            alert(`Error: ${response.data.detail}`);
        }
    } catch (error) {
        // 에러 응답이 있는 경우 통합하여 콘솔에 출력
        if (error.response) {
            console.error('Error:', {
                message: error.message,
                statusCode: error.response.status, // 에러 응답의 상태 코드
                details: error.response.data // 에러 응답의 세부 정보
            });
        } else {
            console.error('Error:', error.message); // 일반 에러 메시지
        }
        // 메시지
        alert('코드 확인에 실패했습니다.');
    }
});
