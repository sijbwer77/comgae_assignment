from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import datetime
import pymysql.cursors
from typing import List, Dict
import os
from fastapi.responses import JSONResponse
import logging

app = FastAPI()

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# MySQL 연결 함수
def connect_to_mysql():
    return pymysql.connect(
        host='127.0.0.1',  # MySQL 호스트
        user='root',  # MySQL 사용자 이름
        password='qlalfqjagh77',  # MySQL 암호
        database='submissions_db',  # 사용할 데이터베이스 이름
        charset='utf8',
        cursorclass=pymysql.cursors.DictCursor
    )

class Submission(BaseModel):
    username: str
    password: str
    code: str

class SubmissionResponse(BaseModel):
    id: int

class Result(BaseModel):
    id: int
    status: str

# 디렉토리 생성 함수
def create_directory(path):
    if not os.path.exists(path):
        os.makedirs(path)

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.post("/submission", response_model=SubmissionResponse)
async def submit_code(submission: Submission):
    connection = connect_to_mysql()
    try:
        with connection.cursor() as cursor:
            # SQL 쿼리 실행
            sql = """
            INSERT INTO submissions (username, password, code, created_at, updated_at, status)
            VALUES (%s, %s, %s, %s, %s, %s)
            """
            cursor.execute(sql, (
                submission.username, submission.password, submission.code,
                datetime.datetime.utcnow(), datetime.datetime.utcnow(), "SUBMITTED"
            ))
        connection.commit()
        submission_id = cursor.lastrowid

        # 코드 파일 저장
        submission_dir = os.path.join(os.path.dirname(__file__), 'Submissions')
        create_directory(submission_dir)
        with open(os.path.join(submission_dir, f"{submission_id}.py"), "w") as code_file:
            code_file.write(submission.code)
            
    except Exception as e:
        logger.error(f"Error inserting submission: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")
    finally:
        connection.close()
    return {"id": submission_id}

@app.get("/new")
async def fetch_new_code():
    connection = connect_to_mysql()
    try:
        with connection.cursor() as cursor:
            # 가장 오래된 SUBMITTED 상태의 항목을 가져옴
            sql = """
            SELECT * FROM submissions WHERE status='SUBMITTED' ORDER BY created_at ASC LIMIT 1
            """
            cursor.execute(sql)
            submission = cursor.fetchone()
            if submission:
                # 상태를 PROCESSING으로 업데이트
                update_sql = """
                UPDATE submissions SET status='PROCESSING', updated_at=%s WHERE id=%s
                """
                cursor.execute(update_sql, (datetime.datetime.utcnow(), submission['id']))
                connection.commit()
                return submission
            else:
                raise HTTPException(status_code=404, detail="No new submissions")
    except Exception as e:
        logger.error(f"Error fetching new code: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")
    finally:
        connection.close()

@app.patch("/submission")
async def update_submission(result: Result):
    connection = connect_to_mysql()
    try:
        with connection.cursor() as cursor:
            # 해당 id의 상태를 업데이트
            sql = """
            UPDATE submissions SET status=%s, updated_at=%s WHERE id=%s
            """
            cursor.execute(sql, (result.status, datetime.datetime.utcnow(), result.id))
        connection.commit()
        if cursor.rowcount == 0:
            raise HTTPException(status_code=404, detail="Submission not found")
    except Exception as e:
        logger.error(f"Error updating submission: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")
    finally:
        connection.close()
    return {"id": result.id, "status": result.status}

@app.get("/submission")
async def get_submission(username: str, password: str, id: int):
    connection = connect_to_mysql()
    try:
        with connection.cursor() as cursor:
            logger.info(f"Fetching submission for id={id}, username={username}")
            # 주어진 id와 username을 가진 제출물 조회
            sql = """
            SELECT * FROM submissions WHERE id=%s AND username=%s
            """
            cursor.execute(sql, (id, username))
            submission = cursor.fetchone()
            if submission:
                if submission['password'] == password:
                    # 날짜를 문자열로 변환
                    submission['created_at'] = submission['created_at'].isoformat()
                    submission['updated_at'] = submission['updated_at'].isoformat()
                    return JSONResponse(content=submission)
                else:
                    raise HTTPException(status_code=401, detail="Unauthorized")
            else:
                raise HTTPException(status_code=404, detail="Submission not found")
    except Exception as e:
        logger.error(f"Error fetching submission: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")
    finally:
        connection.close()
        
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
