# KnowMedicine

시각장애인 및 저시력자를 위한 의약품 인식 어플리케이션

## 프로젝트 소개
혼자서 의약품 구분과 코로나 키트 결과를 확인하기 어려운 시각장애인 및 저시력자를 위한 어플리케이션입니다.<br><br>
약품의 표지를 촬영하면 AI가 해당 이미지를 분석하여 약품 정보와 주의사항 등을 TTS로 읽어줍니다.

## 개발환경
- **FrameWork**: Flutter 3.13.2
- **Language**: Dart
- **IDE**: Android Studio Giraffe | 2022.3.1
- **Database**: Python
- **AI Model**: YOLOv8

## 주요기능
### 회원가입 화면
- 아이디, 비밀번호, 이름 등의 정보를 입력받아 회원가입을 진행합니다.
- 시각장애인 및 저시력자분들을 위해 음성인식과 TTS 기능을 제공합니다.
- 회원가입 절차를 단계적으로 구성하여 보다 쉽게 회원가입을 할 수 있도록 구현하였습니다.

### 카메라 화면
- 의약품을 촬영하기 위해 카메라를 불러옵니다.
- 촬영 버튼을 누르면 사진을 촬영합니다.
- 촬영된 이미지는 서버로 전송되고, 서버로부터 데이터를 받을 때까지 대기합니다.

### 결과 화면
- 서버로부터 전달받은 분석결과를 보여줍니다.
- TTS 기능을 이용하여 약품의 정보나 주의사항을 음성으로 읽어줍니다.
- 여러 개의 의약품이 감지된 경우, 자동으로 넘어가면서 음성이 재생됩니다.
- 왼쪽의 메뉴바를 누르면 TTS를 ON/OFF 하거나 말하기 속도를 조정할 수 있습니다.

### 로그인 화면
- 아이디와 비밀번호를 입력하면 로그인할 수 있습니다.
- 이미지 분석을 위해 사진을 서버로 전송할 때 현재 로그인한 사용자 정보도 함께 전송됩니다.
- 전송된 사용자 정보는 추후 AI 모델이나 시스템 개선을 위해 사용될 수 있습니다.


