## Raku Chat SDK

<img width="864" alt="image" src="https://github.com/user-attachments/assets/7a03cd2d-44ac-43f0-96a3-1e1a61820052" />

<br/>
<br/>

## 프로젝트 일정

[프로젝트 일정링크](https://github.com/orgs/team-rakuraku/projects/1/views/8) | 2025.01 - 02

<br/>

## 스크린샷


| **메인 채팅 리스트 화면** | **채팅방 목록 화면** | **이미지 전송** | **채팅방 만들기 화면** | **이미지 선택 화면** |
|----------------|----------------|----------------|----------------|----------------|
| <img src="https://github.com/user-attachments/assets/48fc5f5a-0396-4e31-8b77-2cd33c9a64a0" width="150"/> | <img src="https://github.com/user-attachments/assets/b35e51aa-b88f-452a-b5ae-189e7c421f51" width="150"/> | <img src="https://github.com/user-attachments/assets/788f0e7f-ef1b-4de7-baec-0c646b21e7ff" width="150"/> | <img src="https://github.com/user-attachments/assets/ef962e64-d499-459f-8e95-dc9fe8cb3d61" width="150"/> | <img src="https://github.com/user-attachments/assets/757e678c-cddb-491b-acd1-ce657c454d58" width="150"/> |

<br/>


## Frontend Architecture


### Modular Architecture (Melos Package 사용)

<img width="600" alt="image" src="https://github.com/user-attachments/assets/c388cf92-e704-478d-8625-67bed397db56" />

<br/>

### ChatSDK(Raku Domain) Architecture

<img width="200" alt="image" src="https://github.com/user-attachments/assets/7b26cfbb-fd77-46a8-b1ad-ff7c6cb29a4f" />

<img width="600" alt="image" src="https://github.com/user-attachments/assets/620cb9b9-4511-42de-b588-a4e6b9a0d56a" />

<br/>

### ChatUI(Raku UI) Architecture

<img width="240" alt="image" src="https://github.com/user-attachments/assets/5770f803-ee5d-427a-87fb-48882ce84c03" />


<br/>
<br/>

## 폴더 구조 

| **chat_ui** | **chat_sdk** |
|------------|------------|
| <img src="https://github.com/user-attachments/assets/38e7c0f5-74e9-4134-b78e-cb112178f9e2" width="250"/> | <img src="https://github.com/user-attachments/assets/3e2ee8d8-b729-4fa9-b7be-941874290f88" width="200"/> <img src="https://github.com/user-attachments/assets/1082160f-a597-4ef1-920f-59a66b9b4cb7" width="200"/> |



<br/>

## 핵심 기술 및 트러블 슈팅

### Stomp 활용 Web Socket 구현
- **문제상황**<br/>일반 WebSocket은 단순한 양방향 통신만 제공하고 메시지 순서를 보장하지 않았습니다. 또한 클라이언트가 직접 메시지를 브로드캐스트하거나 관리해야 하므로 구현이 복잡해지는 상황이었습니다. <br/><br/>
- **해결방법**<br/>STOMP 프로토콜을 사용하여 메시지를 Publish/Subscribe 모델로 처리함과 동시에 메시지 큐가 적용되어 순서를 보장하고 구현을 단순화했습니다. <br/><br/>
- **내용정리 링크**
  - [Flutter에서 Stomp로 소켓통신하기](https://ssuojae.tistory.com/382)
  - [오토스케일링 되는 과정에서 소켓 커넥션을 유지하기 위한 고민](https://ssuojae.tistory.com/366)


<br/>
<br/>

### **S3 + CloudFront 활용 미디어 데이터 캐싱 전략 적용**  
- **문제상황**<br/>초기에는 채팅에서 주고받은 이미지 데이터를 MongoDB에 직접 저장했으나, 데이터 용량이 급격히 증가하며 저장소가 빠르게 소진되었습니다. 또한, 이미지 요청 시마다 MongoDB에서 데이터를 불러오면서 응답 시간이 길어지고 서버 부하가 증가하는 문제가 발생했습니다.  <br/><br/>
- **해결방법**<br/>이미지를 MongoDB가 아닌 S3에 저장하고, CloudFront를 통해 CDN 캐싱을 적용하여 성능을 최적화했습니다. 이를 통해 데이터 저장 비용을 절감하고, 동일한 이미지 요청 시 S3가 아닌 CDN에서 제공하도록 설정하여 로딩 속도를 크게 향상시켰습니다.<br/><br/>  
- **내용정리 링크**  
  - [S3 + CloudFront 캐싱 전략](https://ssuojae.tistory.com/380)  

<br/>
<br/>


### **Pagination을 통한 API 통신 비용 절약**  
- **문제상황**<br/>채팅 목록 및 메시지 불러오기에서 무한 스크롤을 사용할 경우, 한 번의 API 호출로 과도한 데이터를 가져와 성능 저하와 불필요한 네트워크 비용이 발생했습니다. 특히, 새 메시지가 지속적으로 추가되는 채팅 특성상, 전체 데이터를 로드하는 방식은 비효율적이었습니다.<br/><br/>
- **해결방법**<br/>Offset 기반 Pagination을 도입하여 일정 개수의 메시지만 요청하도록 제한하고, 클라이언트에서 **Infinite Scroll(무한 스크롤링)**을 구현하여 사용자가 스크롤할 때만 추가 데이터를 요청하도록 최적화했습니다. 이를 통해 네트워크 비용을 절감하고, 초기 로딩 속도를 개선했습니다.  <br/><br/>

<br/>
<br/>


### **클린 아키텍처 & 모듈러 아키텍처 채택 이유**  
- **문제상황**<br/>채팅 SDK를 개발하면서, UI를 직접 제공하는 패키지와 사용자가 UI를 자유롭게 커스터마이징할 수 있는 패키지로 분리해야 했습니다. 이 과정에서 UI와 비즈니스 로직을 분리하지 않으면 유지보수성과 확장성이 급격히 낮아지는 문제가 발생했습니다. 또한, 패키지가 여러 개로 나뉘면서 Flutter의 **hot reload** 기능이 정상적으로 동작하지 않는 등의 불편함도 있었습니다.<br/><br/>
- **해결방법**<br/>클린 아키텍처를 적용하여 **Presentation, Domain, Data** 레이어를 명확하게 나누고, UI와 핵심 비즈니스 로직을 완전히 분리했습니다. 이를 통해 SDK를 유연하게 확장할 수 있도록 설계했습니다. 또한, 패키지 분리에 따른 불편함을 해소하기 위해 **Melos**를 도입하여 모노레포 환경에서 의존성 관리 및 개발 편의성을 유지할 수 있도록 했습니다.  <br/><br/>

<br/>
<br/>


### **Failure + TaskEither 타입을 활용한 에러 핸들링**  
- **문제상황**<br/>API 호출 및 비동기 로직에서 발생하는 예외 처리가 일관되지 않아, 오류 발생 시 코드 흐름을 예측하기 어려웠습니다. 또한, 단순 `try-catch` 방식은 코드 가독성을 떨어뜨렸습니다.<br/><br/>
- **해결방법**<br/>`TaskEither<Failure, T>` 패턴을 적용하여 성공과 실패를 명확하게 구분하고, 실패 시 풍부한 의미를 담은 에러 타입을 반환하여 예외 처리를 체계적으로 관리했습니다.<br/><br/>
- **내용정리 링크**  
  - [Future와 Task의 차이](https://ssuojae.tistory.com/358)  

<br/>
<br/>


### **Freezed vs Equatable vs JsonSerializable 비교**  
- **문제상황**<br/>Freezed는 강력한 기능을 제공하지만, 코드 생성(CodeGen)으로 인해 빌드 시간이 증가하고, 불필요한 기능이 많아 프로젝트에 과도한 복잡성을 초래했습니다. 또한, DTO와 상태 관리를 위한 최소한의 기능만 필요했기 때문에 불필요한 기능을 제거할 필요가 있었습니다.<br/><br/>  
- **해결방법**<br/>Freezed 대신 **Equatable + sealed class**를 사용하여 불변성과 패턴 매칭을 효과적으로 구현하고, DTO 변환에는 `JsonSerializable`을 활용하여 필요한 최소한의 직렬화 기능만 추가했습니다. 이를 통해 코드의 미니멀리즘을 유지하면서도 유지보수성을 극대화했습니다. <br/><br/> 
- **내용정리 링크**  
  - [Freezed 패키지 사용이유 알아보기](https://ssuojae.tistory.com/272)
  - [Freezed 패키지에서 Equatable 패키지로 옮긴 이유](https://ssuojae.tistory.com/391)

<br/>
<br/>


### **Jenkins CI 구축 중 파일 경로 트러블 슈팅**  
- **문제상황**<br/>  
  Flutter 프로젝트의 `develop` 브랜치에서 매일 새벽 5시에 단위 테스트를 실행하기 위해 EC2에 Docker 기반으로 Jenkins를 배포했습니다. 그러나, Docker 컨테이너 내부에서 Flutter 및 Android SDK를 인식하지 못해 빌드가 실패했습니다. Jenkins 컨테이너가 격리된 환경에서 실행되므로, EC2 로컬에 설치된 Flutter 및 Android SDK 경로를 찾을 수 없었고, 환경 변수 또한 제대로 로드되지 않는 문제가 있었습니다. <br/><br/> 
- **해결방법**<br/>  
  Jenkins Docker 컨테이너가 EC2 로컬의 Flutter 및 Android SDK를 인식할 수 있도록 **볼륨 마운트(Bind Mount)** 를 설정했습니다.  
  1. Docker 실행 시 `-v` 옵션을 사용하여 EC2의 `/home/ec2-user/flutter` 및 `/home/ec2-user/android-sdk`를 Jenkins 컨테이너 내부로 마운트.  
  2. Jenkins Pipeline에서 `environment` 블록을 활용하여 Flutter 및 Android SDK 경로를 `PATH` 환경 변수에 추가.  
  3. Jenkins 컨테이너가 해당 디렉토리에 접근할 수 있도록 `chown -R 1000:1000`으로 권한 설정.  
  이를 통해 Jenkins가 로컬 Flutter 및 Android SDK를 정상적으로 인식하여 빌드를 수행할 수 있도록 해결했습니다.  <br/><br/>
- **내용정리 링크**  
  - [Jenkins CI/CD 파일 경로 문제 해결](https://ssuojae.tistory.com/362)  
