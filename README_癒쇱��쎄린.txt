ACHIEVIA 업데이트 파일

포함 파일:
- index.html : 시크릿 등급이 추가된 사이트 메인 파일
- config.js.example : 연결 설정 예시 파일 (실제 config.js가 이미 있다면 이 파일로 덮어쓰지 마세요)

중요:
1. Supabase 데이터베이스를 삭제하거나 초기화하지 않습니다. 기존 데이터는 Supabase에 저장되어 있으므로 HTML 교체만으로 삭제되지 않습니다.
2. GitHub 저장소의 기존 config.js가 있다면 반드시 그대로 유지하세요.
3. GitHub 저장소의 index.html만 이 ZIP 안의 index.html로 교체하세요.
4. 배포 후에도 Supabase 연결이 안 되면 기존 config.js가 있는지, 그 파일의 변수명이 window.ACHIEVIA_CONFIG이고 속성이 supabaseUrl 및 supabaseKey인지 확인하세요.
5. 시크릿 등급 생성 시 데이터베이스 제약 조건 오류가 뜨면 오류 문구를 확인해야 할 수 있습니다. schema.sql을 무작정 다시 실행하지 마세요.
6. service_role 키는 절대 웹사이트 파일에 넣지 마세요. 공개 anon/publishable 키만 사용하세요.
