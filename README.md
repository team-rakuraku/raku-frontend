## Raku Chat SDK

<img width="864" alt="image" src="https://github.com/user-attachments/assets/7a03cd2d-44ac-43f0-96a3-1e1a61820052" />

<br/>
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
| <img src="https://github.com/user-attachments/assets/38e7c0f5-74e9-4134-b78e-cb112178f9e2" width="250"/> | <img src="https://github.com/user-attachments/assets/1082160f-a597-4ef1-920f-59a66b9b4cb7" width="200"/> <img src="https://github.com/user-attachments/assets/3e2ee8d8-b729-4fa9-b7be-941874290f88" width="200"/> |



<br/>

## 핵심 기술 및 트러블 슈팅

### Stomp 활용 Web Socket 구현


<br/>

### S3 + Cloudfront 활용 미디어 데이터 캐싱전략 적용


<br/>


### Pagination을 통한 API 통신 비용 절약



<br/>

### 클린아키텍쳐와 모듈러 아키텍쳐 채택 이유



<br/>


### Failure + TaskEither 타입을 활용해 비동기 함수 결과값에 풍부한 의미 담아주기


<br/>

### Freezed vs Equatable vs JsonSerializable


<br/>

### Jenkins CI 구축중 발생했던 파일경로 트러블 슈팅


