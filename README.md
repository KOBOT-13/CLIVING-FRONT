# CLIVING FRONT

클라이밍 클립 자동 제작 서비스 CLIVING의 Front-End 레포지토리입니다.

## 요구사항
- Flutter 3.22.2
- Dart 3.4.3
- iOS Deployment Target 12.0 (iOS 개발 시)

## 설치 및 실행 방법
### 1. Git Clone
    git clone https://github.com/KOBOT-13/cliving-front.git
    cd cliving-front
### 2. Flutter package install
    flutter pub get
### 3. Create .env
    vi .env
    API_ADDRESS=http://{SERVER_IP_ADDRESS}
    :wq
-  SERVER_IP_ADDRESS
    + IOS LOCAL IP : 127.0.0.1:8000
    + ADNROID LOCAL IP : 10.0.2.2:8000
    
*에뮬레이터 실행*

    flutter run

