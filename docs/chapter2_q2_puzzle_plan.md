# 수학놀이실 2번째 문제 구현 계획 (4x4 드래그 퍼즐)

## 1) 목표
- 화면 주제: `조각 6개를 드래그해서 4×4 격자판에 배치`하고, 목표 모양과 일치시키는 퍼즐
- 난이도: 초등학생 대상 (밝고 단순한 UI, 큰 터치 영역)
- 실행 목표: `main.dart` 단일 파일로 웹/태블릿 가로 대응 동작

---

## 2) 요구사항 매핑

### 화면 구조
- 상단: 문제 문장
  - `조각 6개를 움직여서 오른쪽과 같은 모양을 만들어 보세요.`
- 좌측: 드래그 가능한 조각 6개
  - 좁은 화면: 2열 Grid
  - 넓은 화면: 세로/2열 자동 전환
- 우측 상단: 목표 모양 예시 이미지
- 우측(또는 중앙): 4×4 보드
- 하단: `다시하기`, `완성 확인` 버튼

### 퍼즐 동작
- 조각 1개당 보드 1칸 점유
- 이미 놓은 조각 재이동 가능
- 보드 밖으로 드롭 시 조각 영역으로 복귀
- 회전 기능 없음
- `완성 확인` 시 정답 배열과 완전 비교
  - 정답: 성공 다이얼로그
  - 오답: 다시 시도 안내

### 데이터 구조
- 조각 모델: `id`, `imagePath`, `currentCell`
- 보드: 16칸 (`0..15`)
- 정답: 16칸 배열(빈칸 포함)

---

## 3) 구현 설계

## 상태 모델
```dart
class PieceModel {
  final String id;
  final String imagePath;
  int? currentCell; // null이면 조각 트레이에 있음
}
```

- `List<PieceModel> pieces` (6개)
- `List<String?> boardCells = List.filled(16, null)`  
  - 값: 해당 칸 조각 id / null(빈칸)
- `List<String?> answerCells`  
  - 길이 16, 빈칸 포함한 정답 패턴

## 인덱스 규칙
- 4×4 보드 인덱스
  - 0~3: 1행
  - 4~7: 2행
  - 8~11: 3행
  - 12~15: 4행

## 핵심 함수
1. `placePieceOnCell(String pieceId, int targetCell)`
- 기존 위치 제거
- 타겟 칸 점유 검사
- 비어 있으면 배치
- 점유 중이면 이전 조각을 트레이로 보내고 교체(혹은 무시 정책 선택)

2. `returnPieceToTray(String pieceId)`
- 조각이 있던 칸 비우기
- `currentCell = null`

3. `resetPuzzle()`
- 모든 조각 `currentCell = null`
- 보드 전부 `null`

4. `checkAnswer()`
- `for i in 0..15`에서 `boardCells[i] == answerCells[i]` 전부 일치 검사

---

## 4) 위젯 구성 (main.dart 단일 파일)

1. `PuzzleApp` / `PuzzlePage` (StatefulWidget)
2. 상단 문제 문장 카드
3. 본문 `LayoutBuilder` 반응형 분기
- 넓은 화면(태블릿 가로): 좌(조각) / 우(목표+보드)
- 좁은 화면: 상단 목표, 중간 보드, 하단 조각

4. 조각 영역
- `Draggable<String>`로 piece id 전달
- 빈 슬롯 표현(이미 배치된 조각은 트레이에서 숨김 또는 빈칸 박스)

5. 보드 영역
- 16칸 `DragTarget<String>`
- 각 칸 크기 고정 비율(정사각형)
- 배치된 조각은 `LongPressDraggable` 또는 `Draggable`로 재이동 가능

6. 목표 이미지
- `Image.asset('assets/pieces/target.png')` (더미 가능)

7. 하단 버튼
- `다시하기` -> reset
- `완성 확인` -> check + dialog

---

## 5) 드래그 동작 규칙 상세

1. 트레이 -> 보드
- 비어있는 칸이면 배치
- 점유된 칸이면 정책:
  - 기본안: 드롭 무효 (학생 혼동 감소)
  - 대안: 스왑
- 이번 구현은 **무효 처리 + 안내 스낵바** 권장

2. 보드 -> 다른 칸
- 기존 칸 비우고 새 칸 배치

3. 보드 -> 트레이(보드 밖)
- 조각 위젯의 `onDraggableCanceled`에서 트레이 복귀 처리

---

## 6) 정답 데이터 예시

```dart
final List<String?> answerCells = [
  null,    "p1",   "p2",   null,
  "p3",    "p4",   "p5",   null,
  null,    "p6",   null,   null,
  null,    null,   null,   null,
];
```

- 실제 모양 기준으로 piece id 매핑 조정
- 빈칸도 `null`로 반드시 비교

---

## 7) 에셋 경로(더미)
- `assets/pieces/piece1.png` ~ `assets/pieces/piece6.png`
- `assets/pieces/target.png`

`pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/pieces/
```

---

## 8) UI 가이드(초등학생용)
- 배경: 밝은 톤(#F7FAFF 계열)
- 카드: 둥근 모서리 + 약한 그림자
- 보드 칸: 두께 있는 라인, 충분한 터치 면적(최소 56dp 이상)
- 버튼: 크게, 명확한 색 대비
- 텍스트: 짧고 큰 폰트(문장 가독성 우선)

---

## 9) 웹/태블릿 대응 체크
- `LayoutBuilder`로 폭 기준 분기
- `AspectRatio`로 보드 비율 유지
- 마우스/터치 모두 드래그 가능(Flutter Web `Draggable/DragTarget` 사용)

---

## 10) 작업 순서 (실행 플랜)
1. `main.dart`에 상태 모델/초기 데이터 작성
2. 정적 UI 프레임(문장, 조각, 목표, 보드, 버튼) 구성
3. Draggable/DragTarget 배선
4. `reset`, `check` 로직 연결
5. 성공/실패 다이얼로그 연결
6. 반응형 레이아웃 및 터치 영역 튜닝
7. 웹 실행 검증 (`flutter run -d chrome`)

---

## 11) 완료 기준 (Definition of Done)
- 조각 6개 드래그 배치/재배치 가능
- 보드 밖 드롭 시 트레이 복귀
- 빈칸 포함 정답 비교 정확
- 버튼 동작 정상
- 태블릿 가로/웹에서 레이아웃 깨짐 없음
- `main.dart` 단독 실행 가능

