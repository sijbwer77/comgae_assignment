_____________________________________________
<리눅스 운영체제에서 실행>
_____________________________________________
<TREE 구조>
│   fetch.sh
│   grade.sh
│
└───ComGae
    │   answer.txt
    │
    └───submissions
            1.py
            2.py
_____________________________________________
<crontab>
* * * * * /home/sijbwer77/fetch.sh
* * * * * /home/sijbwer77/grade.sh
_____________________________________________
<fetch.sh>
"/home/sijbwer77/ComGae/submissions"
위치에 파이썬 파일로 저장함
_____________________________________________
<grade.sh>
"/home/sijbwer77/ComGae/submissions"
위치에 있는 파일 채점하기
"/home/sijbwer77/ComGae/answer.txt"
위치에 있는 answer.txt가 정답
_____________________________________________


