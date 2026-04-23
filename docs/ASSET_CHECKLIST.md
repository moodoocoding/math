# Asset Checklist (Flutter Mission App)

이 문서는 현재 코드 기준으로 실제 개발이 필요한 에셋 목록을 정리한 체크리스트입니다.

## 1) 필수 에셋 (우선순위 높음)

### A. 미션 데이터 JSON
- [ ] 파일: `assets/data/mission_low.json`
- [ ] 인코딩: `UTF-8` (한글 깨짐 방지)
- [ ] 포함 필드 점검:
  - [ ] `type` (`story` / `quiz`)
  - [ ] `quiz_type` (`mcq` / `input` / `qr`)
  - [ ] `question`, `choices`, `answer`, `hint`
- [ ] 검수 기준:
  - [ ] `mcq`의 `answer`는 `choices` 인덱스와 일치
  - [ ] `input`의 `answer`는 공백/대소문자 정책 정의
  - [ ] `qr`의 `answer` 값과 실제 QR 데이터 매핑 정의

### B. 홈/인트로 이미지
- [ ] 파일: `assets/images/bg_intro.jpg`
- [ ] 권장 해상도: `1920x1080` 이상 (16:9)
- [ ] 포맷: `JPG` (배경 이미지)
- [ ] 용량 목표: `300KB ~ 900KB`
- [ ] 검수 기준:
  - [ ] 텍스트가 올라가도 가독성 확보
  - [ ] 세로 화면(모바일) 크롭 시 주요 피사체 유지

### C. 캐릭터 이미지
- [ ] 파일: `assets/images/chr_main_happy.png`
- [ ] 권장 해상도: `1024x1024` 또는 세로형 `1024x1365`
- [ ] 포맷: `PNG` (투명 배경)
- [ ] 검수 기준:
  - [ ] 외곽 깨짐/흰 테두리 없음
  - [ ] 밝은/어두운 배경 모두에서 식별 가능

### D. 오디오
- [ ] 파일: `assets/audio/bgm.ogg`
- [ ] 권장 길이: `30 ~ 120초` (루프 가능)
- [ ] 포맷: `OGG`
- [ ] 용량 목표: `500KB ~ 2.5MB`
- [ ] 추가 권장:
  - [ ] `assets/audio/sfx_correct.ogg`
  - [ ] `assets/audio/sfx_wrong.ogg`

## 2) QR 퀴즈용 추가 에셋

현재 `mission_low.json`에 `quiz_type: "qr"`가 있으므로 아래 중 하나를 선택해야 합니다.

- [ ] 방식 1: 실제 QR 인쇄/스캔
  - [ ] 인쇄용 QR 이미지 세트 제작 (`assets/images/qr/`)
  - [ ] 정답 데이터 문자열 정책 문서화
- [ ] 방식 2: 앱 내 QR 이미지 선택형
  - [ ] 화면 표시용 QR 이미지 제작
  - [ ] 정답 QR와 오답 QR 구분 데이터 정의

## 3) 파일명 규칙 (권장)

- [ ] 소문자 + 스네이크케이스 사용
- [ ] 접두어로 용도 구분
  - [ ] `bg_*.jpg` (배경)
  - [ ] `chr_*.png` (캐릭터)
  - [ ] `sfx_*.ogg` (효과음)
  - [ ] `bgm_*.ogg` (배경음)
  - [ ] `mission_*.json` (미션 데이터)

예시:
- `assets/images/bg_intro.jpg`
- `assets/images/chr_main_happy.png`
- `assets/audio/bgm_main_loop.ogg`
- `assets/audio/sfx_correct.ogg`
- `assets/data/mission_low.json`

## 4) 제작 수량 가이드 (MVP)

- [ ] 배경 이미지: 최소 1장
- [ ] 캐릭터: 최소 1표정 (`happy`)
- [ ] BGM: 최소 1트랙
- [ ] 효과음: 정답/오답 2개
- [ ] 미션 JSON: 1개 (현재 파일 고도화)

## 5) 현재 프로젝트 상태 점검

- [x] `pubspec.yaml`에 assets 경로 등록 완료
- [x] 코드에서 JSON 로딩 구현됨
- [ ] 이미지/오디오 실제 UI 연결 미완료
- [ ] QR 퀴즈 UI/스캔 로직 미완료
- [ ] 테스트 코드(`test/widget_test.dart`)는 현재 화면 구조와 불일치

## 6) 적용 순서 (추천)

1. `mission_low.json` 한글/문항 데이터 정리
2. `bg_intro.jpg`, `chr_main_happy.png` 실에셋 교체
3. `bgm.ogg` + `sfx_correct.ogg`, `sfx_wrong.ogg` 추가
4. QR 퀴즈 방식 결정 후 에셋 확정
5. 마지막에 UI 연결 및 테스트 업데이트
