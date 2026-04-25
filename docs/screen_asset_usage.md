# 화면별 에셋 사용 정리

## 정리 기준

- 화면별로 사용되는 배경, 캐릭터, 문제 이미지 에셋을 정리했습니다.
- “주요 텍스트”는 `docs/story_development.md`의 화면별 대화 플로우를 기준으로 작성했습니다.
- **[2026-04-26 업데이트]**: 모든 챕터 스토리 화면에 캐릭터가 정상 표시되며, 엔딩 스토리 화면에서만 캐릭터가 등장하지 않습니다.

## 공통 화면

| 화면 | 주요 텍스트 | 배경 에셋 | 주요 이미지 에셋 | 비고 |
|---|---|---|---|---|
| 인트로 화면 | 충북 수학체험센터에 온 걸 환영해! | `assets/images/bg_intro.png` | - | 앱 시작 화면 |
| 메인/챕터 선택 화면 | 미션! 수학체험센터의 반짝별을 찾아서 | `assets/images/bg_intro.png` | `assets/images/logo_cb_math.png` | 충북수학체험센터 로고 사용 |

## 챕터1

| 화면 | 주요 텍스트 | 배경 에셋 | 캐릭터/문제 에셋 | 비고 |
|---|---|---|---|---|
| 화면1 | 수학체험센터에 온 것을 환영해! 하우와 플레이와 함께 모험을 시작하자! | - | `assets/images/chr_background.png` | 시작 안내용 통합 이미지 |
| 화면2 | 큰일이야! 체험센터 불빛이 또 하나 꺼졌어! | `assets/images/chapter1_bg_1.png` | `assets/images/chr_how_worry.png` | 하우 |
| 화면3 | 마지막 불빛까지 꺼지기 전에 첫 번째 별 조각을 찾아야 해! | `assets/images/chapter1_bg_1.png` | `assets/images/chr_play_worry.png` | 플레이 |
| 화면4 | 저기! 벽에 빛나는 문장이 보여! 첫 번째 별 조각은 수학체험실에 있대! | `assets/images/chapter1_bg_1.png` | `assets/images/chr_how_idea.png` | 하우 |
| 화면5 | 찾았다! 그런데 문이 잠겨 있어! 문제를 풀어야 열 수 있나 봐! | `assets/images/chapter1_bg_1.png` | `assets/images/chr_play_surprised.png` | 플레이 |
| 화면6 | 문제1: 빈칸 없이 바닥을 채울 수 있는 모양은 무엇일까요? | - | 별도 이미지 없음 | 바닥/보기 도형은 Flutter에서 직접 그림 |
| 화면7 | 문이 열렸어! 바닥에 반짝이는 길이 나타났어! | `assets/images/chapter1_bg_1.png` | `assets/images/chr_how_heart.png` | 하우 |
| 화면8 | 저 길 끝에 다음 장치가 있어! 얼른 가 보자! | `assets/images/chapter1_bg_1.png` | `assets/images/chr_play_lefthand2.png` | 플레이 |
| 화면9 | 어? 이번에는 원판이 기둥에 쌓여 있어! | `assets/images/chapter1_bg_1.png` | `assets/images/chr_how_surprised.png` | 하우 |
| 화면10 | 원판을 규칙대로 옮기면 첫 번째 별 조각을 꺼낼 수 있대! | `assets/images/chapter1_bg_1.png` | `assets/images/chr_play_explaining.png` | 플레이 |
| 화면11 | 문제2: 하노이의 탑에서 원반 3개를 옮길 때 최소 몇 번 움직여야 할까요? | - | 별도 이미지 없음 | 기둥/원반은 Flutter에서 직접 그림 |

## 챕터2

| 화면 | 주요 텍스트 | 배경 에셋 | 캐릭터/문제 에셋 | 비고 |
|---|---|---|---|---|
| 화면1 | 와! 첫 번째 별 조각을 찾으니까 불빛이 다시 켜졌어! | `assets/images/chapter1_bg_1.png` | `assets/images/chr_how_surprised (2).png` | 하우 |
| 화면2 | 좋아! 다음 조각을 찾으면 체험센터가 더 밝아질 거야! | `assets/images/chapter1_bg_1.png` | `assets/images/chr_play_thumbs_up.png` | 플레이 |
| 화면3 | 첫 번째 조각 뒤에 다음 단서가 있어! | `assets/images/chapter1_bg_1.png` | `assets/images/chr_how_lefttalk.png` | 하우 |
| 화면4 | 두 번째 별 조각은 수학놀이실에 있대! | `assets/images/chapter2_bg_1.png` | `assets/images/chr_play_idea.png` | 플레이 |
| 화면5 | 와! 여기가 수학놀이실이구나! 저기 반짝이는 저울이 보여! | `assets/images/chapter2_bg_1.png` | `assets/images/chr_how_surprised.png` | 하우 |
| 화면6 | 더 무거운 쪽을 맞히면 다음 장치가 열릴 거야! | `assets/images/chapter2_bg_1.png` | `assets/images/chr_play_explaining.png` | 플레이 |
| 화면7 | 문제1: 더 무거운 것은 무엇일까요? | - | `assets/images/chapter2_p1_1.png`, `assets/images/chapter2_p1_2.png`, `assets/images/chapter2_p1_3.png` | 문제용 저울/물체 이미지 |
| 화면8 | 열렸어! 저울 아래에서 반짝이는 무늬판이 나타났어! | `assets/images/chapter2_bg_1.png` | `assets/images/chr_how_clapping.png` | 하우 |
| 화면9 | 조각 6개를 움직여 같은 무늬를 만들면 지나갈 수 있대! | `assets/images/chapter2_bg_1.png` | `assets/images/chr_play_angry.png` | 플레이 |
| 화면10 | 문제2: 조각 6개를 움직여 목표 무늬를 완성하세요. | - | `assets/pieces/target.png`, `assets/pieces/piece1.png` ~ `assets/pieces/piece6.png` | 목표 모양과 조각 보관함 |
| 화면11 | 좋아! 두 번째 별 조각을 찾으면 불빛이 더 밝아질 거야! | `assets/images/chapter2_bg_1.png` | `assets/images/chr_how_cheering.png` | 하우 |
| QR 인증 화면 | 충북수학체험센터 QR 코드를 비추면 자동으로 인증 여부를 확인합니다. | - | 별도 이미지 없음 | 카메라 스캐너 UI |

## 챕터3

| 화면 | 주요 텍스트 | 배경 에셋 | 캐릭터/문제 에셋 | 비고 |
|---|---|---|---|---|
| 화면1 | 찾았다! 두 번째 별 조각이야! | `assets/images/chapter2_bg_1.png` | `assets/images/chr_how_heart.png` | 하우 |
| 화면2 | 봐! 조각을 찾으니까 체험센터가 더 환해졌어! | `assets/images/chapter2_bg_1.png` | `assets/images/chr_play_happy.png` | 플레이 |
| 화면3 | 다음 단서가 보여! 세 번째 별 조각은 수학역사실에 있대! | `assets/images/chapter2_bg_1.png` | `assets/images/chr_how_lefttalk.png` | 하우 |
| 화면4 | 서둘러 가자! 다음 조각을 찾으면 빛이 더 돌아올 거야! | `assets/images/chapter3_bg_1.png` | `assets/images/chr_play_running.png` | 플레이 |
| 화면5 | 와! 여기가 수학역사실이구나! | `assets/images/chapter3_bg_1.png` | `assets/images/chr_how_jump.png` | 하우 |
| 화면6 | 저기 빛나는 계산 막대가 보여. 첫 번째 장치인가 봐! | `assets/images/chapter3_bg_1.png` | `assets/images/chr_play_surprised.png` | 플레이 |
| 화면7 | 산가지 숫자를 맞히면 문이 열릴 것 같아! | `assets/images/chapter3_bg_1.png` | `assets/images/chr_how_thinking.png` | 하우 |
| 화면8 | 문제1: 그림의 산가지는 어떤 수를 나타낼까요? | - | 별도 이미지 없음 | 산가지 그림은 Flutter에서 직접 그림 |
| 화면9 | 열렸어! 안쪽에 숫자판이 또 숨어 있었어! | `assets/images/chapter3_bg_1.png` | `assets/images/chr_play_happy.png` | 플레이 |
| 화면10 | 이번엔 빈칸에 알맞은 수를 넣어야 하나 봐! | `assets/images/chapter3_bg_1.png` | `assets/images/chr_how_confused.png` | 하우 |
| 화면11 | 가로와 세로의 합을 잘 보면 답을 찾을 수 있어! | `assets/images/chapter3_bg_1.png` | `assets/images/chr_play_explaining.png` | 플레이 |
| 화면12 | 문제2: 가로와 세로의 합이 같아지도록 빈칸에 들어갈 수를 고르세요. | - | 별도 이미지 없음 | 마방진 판과 숫자 입력은 Flutter UI |
| 화면13 (Story3) | 좋아! 두 번째 별 조각을 찾으면 불빛이 더 밝아질 거야! | `assets/images/chapter3_bg_1.png` | `assets/images/chr_how_ok.png` | 하우 |

## 챕터4

| 화면 | 주요 텍스트 | 배경 에셋 | 캐릭터/문제 에셋 | 비고 |
|---|---|---|---|---|
| 화면1 | 찾았다! 세 번째 별 조각이야! | `assets/images/chapter3_bg_1.png` | `assets/images/chr_play_cheering.png` | 플레이 |
| 화면2 | 와! 체험센터가 거의 다 밝아졌어! | `assets/images/chapter3_bg_1.png` | `assets/images/chr_how_cheering.png` | 하우 |
| 화면3 | 다음 단서가 보여! 마지막 별 조각은 수학융합실에 있대! | `assets/images/chapter3_bg_1.png` | `assets/images/chr_play_happy.png` | 플레이 |
| 화면4 | 마지막 조각만 찾으면 반짝별이 다시 빛날 거야! | `assets/images/chapter4_bg_1.png` | `assets/images/chr_how_thumbs_up.png` | 하우 |
| 화면5 | 와! 여기가 수학융합실이구나! | `assets/images/chapter4_bg_1.png` | `assets/images/chr_play_surprised.png` | 플레이 |
| 화면6 | 저기 빛나는 블록판이 보여! 첫 번째 장치인가 봐! | `assets/images/chapter4_bg_1.png` | `assets/images/chr_how_surprised.png` | 하우 |
| 화면7 | 같은 모양의 블록을 찾으면 길이 열릴 것 같아! | `assets/images/chapter4_bg_1.png` | `assets/images/chr_play_thinking.png` | 플레이 |
| 화면8 | 문제1: 아래 보기 중 같은 블록 모양은 무엇일까요? | - | 별도 이미지 없음 | 블록 문제는 Flutter에서 직접 그림 |
| 화면9 | 열렸어! 안쪽에 글자판이 숨어 있었어! | `assets/images/chapter4_bg_1.png` | `assets/images/chr_how_surprised.png` | 하우 |
| 화면10 | 이번엔 글자 속에 숨은 수학 낱말을 찾아야 하나 봐! | `assets/images/chapter4_bg_1.png` | `assets/images/chr_play_explaining.png` | 플레이 |
| 화면11 | 잘 보면 마지막 단서가 나타날 거야! | `assets/images/chapter4_bg_1.png` | `assets/images/chr_how_idea.png` | 하우 |
| 화면12 | 문제2: 글자판에서 찾을 수 있는 수학 낱말은 무엇일까요? | - | 별도 이미지 없음 | 글자판은 Flutter UI |
| 화면13 | 드디어 마지막 별 조각을 찾았어, 반짝별을 다시 빛나게 하자! | `assets/images/chapter4_bg_1.png` | `assets/images/chr_play_cheering.png` | 플레이 |

## 엔딩

| 화면 | 주요 텍스트 | 배경/영상 에셋 | 캐릭터/문제 에셋 | 비고 |
|---|---|---|---|---|
| 화면1 | 서둘러! 마지막 별 조각을 반짝별 앞으로 가져가자! | `assets/images/ending.png` | 캐릭터 등장 안 함 | 하우 (음성/텍스트만) |
| 화면2 | 봐! 마지막 별 조각이 반짝별과 하나로 모이고 있어! | `assets/images/ending.png` | 캐릭터 등장 안 함 | 플레이 (음성/텍스트만) |
| 영상 재생 | (엔딩 영상 재생) | `assets/video/ending_video.mp4` | - | 스토리 완료 후 자동 재생 |

## 공통 팝업/피드백 에셋

| 사용 위치 | 주요 텍스트 | 에셋 | 비고 |
|---|---|---|---|
| 힌트 팝업 | 힌트 | `assets/images/chr_how_idea.png` | 문제 화면의 힌트 안내 |
| 정답 결과 팝업 | 성공! | `assets/images/chr_play_correct.png` | 정답 제출 시 표시 |
| 오답 결과 팝업 | 다시 도전! | `assets/images/chr_how_fail.png` | 오답 제출 시 표시 |
| 미션 시작 안내 | 미션을 시작해 볼까요? | `assets/images/chr_background.png` | `MissionLowScreen` 시작 안내 이미지 |

## 참고

- **엔딩 캐릭터**: 엔딩 스토리에서는 캐릭터 이미지를 쓰지 않고 배경 이미지(`ending.png`)와 대화창만 사용하여 시각적 집중도를 높였습니다.
- **이미지 부재**: `chapter2_scene1_together.png`, `chr_together.png` 등은 현재 스토리 흐름에서 사용되지 않습니다.
