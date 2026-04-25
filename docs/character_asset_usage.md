# 캐릭터 이미지 에셋 사용 정리

현재 화면 흐름 기준으로 캐릭터 이미지 에셋이 어디에 쓰이는지 정리했습니다.
**[2026-04-26 업데이트]**: 자주 중복 사용되던 에셋들(surprised, explaining 등)을 미사용 에셋들로 분산 배치하여 다양성을 높였습니다. 

## 사용 현황 (USED)

|번호|이미지 에셋|사용 위치|
|---:|---|---|
|1|assets/images/chr_background.png|mission_low.dart (1회), story_dummy_screen.dart (1회)|
|2|assets/images/chr_how_heart.png|chapter1_story2_tbd_screen.dart (1회), chapter3_story_screen.dart (1회)|
|3|assets/images/chr_how_laughing.png|chapter2_story_screen.dart (1회), chapter4_story_screen.dart (1회)|
|4|assets/images/chr_how_presenting.png|chapter2_story_screen.dart (1회), chapter4_story_screen.dart (1회)|
|5|assets/images/chr_play_laughing.png|chapter3_story2_screen.dart (1회), chapter4_story_screen.dart (1회)|
|6|assets/images/chr_play_right.png|chapter2_story2_screen.dart (1회), chapter4_story_screen.dart (1회)|
|7|assets/images/chr_how_cheering.png|ending_story_screen.dart (1회)|
|8|assets/images/chr_how_clapping.png|chapter2_story2_screen.dart (1회)|
|9|assets/images/chr_how_confused.png|chapter3_story2_screen.dart (1회)|
|10|assets/images/chr_how_fail.png|mission_low.dart (1회)|
|11|assets/images/chr_how_happy.png|chapter2_story_screen.dart (1회)|
|12|assets/images/chr_how_idea.png|mission_low.dart (1회)|
|13|assets/images/chr_how_jump.png|chapter3_story_screen.dart (1회)|
|14|assets/images/chr_how_left.png|story_dummy_screen.dart (1회)|
|15|assets/images/chr_how_lefttalk.png|chapter3_story_screen.dart (1회)|
|16|assets/images/chr_how_ok.png|chapter3_story3_screen.dart (2회)|
|17|assets/images/chr_how_right.png|chapter1_story2_tbd_screen.dart (1회)|
|18|assets/images/chr_how_running.png|chapter4_story_screen.dart (1회)|
|19|assets/images/chr_how_surprised.png|chapter4_story_screen.dart (1회)|
|20|assets/images/chr_how_thinking.png|chapter3_story_screen.dart (1회)|
|21|assets/images/chr_how_thumbs_up.png|chapter4_story_screen.dart (1회)|
|22|assets/images/chr_how_waving.png|chapter2_story3_screen.dart (2회)|
|23|assets/images/chr_how_worry.png|story_dummy_screen.dart (1회)|
|24|assets/images/chr_play_cheering.png|chapter4_story_screen.dart (1회)|
|25|assets/images/chr_play_clapping.png|chapter3_story_screen.dart (1회)|
|26|assets/images/chr_play_confused.png|story_dummy_screen.dart (1회)|
|27|assets/images/chr_play_correct.png|mission_low.dart (1회)|
|28|assets/images/chr_play_explaining.png|chapter1_story2_tbd_screen.dart (1회)|
|29|assets/images/chr_play_happy.png|ending_story_screen.dart (1회)|
|30|assets/images/chr_play_heart_hands.png|chapter4_story_screen.dart (1회)|
|31|assets/images/chr_play_idea.png|chapter2_story_screen.dart (1회)|
|32|assets/images/chr_play_jumping.png|chapter3_story2_screen.dart (1회)|
|33|assets/images/chr_play_lefthand.png|chapter2_story_screen.dart (1회)|
|34|assets/images/chr_play_lefthand2.png|chapter1_story2_tbd_screen.dart (1회)|
|35|assets/images/chr_play_running.png|chapter3_story_screen.dart (1회)|
|36|assets/images/chr_play_surprised.png|chapter3_story_screen.dart (1회)|
|37|assets/images/chr_play_thinking.png|chapter4_story_screen.dart (1회)|
|38|assets/images/chr_play_thumbs_up.png|chapter2_story_screen.dart (1회)|
|39|assets/images/chr_play_waving.png|chapter4_story_screen.dart (1회)|
|40|assets/images/chr_play_worry.png|story_dummy_screen.dart (1회)|

## 미사용 에셋 (UNUSED)

현재 코드에서 참조되지 않는 캐릭터 에셋들입니다. 남은 파일들은 주로 앉아있거나, 슬프거나, 인사를 하는 등 현재 플로우(신나게 모험)에 다소 맞지 않거나, 유사한 포즈가 이미 쓰인 경우입니다.

- `chr_how_angry.png`
- `chr_how_bowing.png`
- `chr_how_cheering.png (1).png` (중복 오류 파일)
- `chr_how_cheering.png.png` (중복 오류 파일)
- `chr_how_correct.png`
- `chr_how_lefthand.png`
- `chr_how_sad.png`
- `chr_how_sitting.png`
- `chr_how_sleepy.png`
- `chr_how_surprised (2).png` (중복 느낌)
- `chr_howplay.png`
- `chr_main_happy.png` (자리표시자)
- `chr_play_angry.png`
- `chr_play_bow_greeting.png`
- `chr_play_fail.png`
- `chr_play_left.png`
- `chr_play_ok.png`
- `chr_play_sad.png`
- `chr_play_sitting.png`
- `chr_play_sleepy.png`
- `chr_together.png`

## 참고

- **엔딩 챕터**: `ending_story_screen.dart`에서는 캐릭터 이미지를 의도적으로 표시하지 않으며 배경과 텍스트만 사용합니다.
- **챕터3 스토리3**: `lib/chapter3_story3_screen.dart`는 주 흐름에서는 빠져있으나 코드는 유지되고 있습니다.
