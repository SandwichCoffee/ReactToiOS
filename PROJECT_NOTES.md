# PROJECT_NOTES

## 1) Project Identity
- Name: `ReactToiOS`
- Type: iOS client porting project (from existing React + Spring Boot service)
- Target: App Store release after MVP + TestFlight validation

## 2) Source of Truth (Web Backend/API)
- Git repository: `https://github.com/SandwichCoffee/ReactProject.git`
- Base branch: `main`
- iOS port starting commit: `239adbe`
- Local reference path: `/Users/chococream/projects/ReactProject`

## 3) Why this project
- 웹 포트폴리오를 유지하면서 iOS 역량을 증명
- 하나의 백엔드를 Web + iOS로 확장하는 실무형 스토리 확보

## 4) MVP Feature Set
- Auth: 로그인, 회원가입, 로그아웃
- Product: 목록, 상세
- Cart: 조회, 추가, 수량 변경, 삭제
- Order: 주문 생성
- My: 내 계정 기본 정보 화면

## 5) API Mapping (MVP)
- `POST /api/users/login`
- `POST /api/users/join`
- `GET /api/products?page=&size=`
- `GET /api/products/{id}`
- `GET /api/cart/user/{userId}`
- `POST /api/cart`
- `PUT /api/cart`
- `DELETE /api/cart/{cartId}`
- `POST /api/orders`

## 6) Auth/Token Policy
- 로그인 성공 시 `token` 수신
- Keychain 저장
- API 요청 시 `Authorization: Bearer <token>` 첨부
- 401 응답 시 토큰 제거 후 로그인 화면으로 이동

## 7) Error Policy (server aligned)
- 400: 요청값 오류
- 401: 인증 실패 / 로그인 실패
- 403: 권한 없음
- 409: 중복/충돌
- 500: 서버 내부 오류

## 8) 8-Week Plan
1. Week 1: MVP 고정 + API 계약 검토
2. Week 2: iOS 아키텍처/네트워크 레이어 구성
3. Week 3-4: Auth + Product 구현
4. Week 5: Cart + Order 구현
5. Week 6: 안정화(에러/빈상태/재시도)
6. Week 7: TestFlight 배포 준비
7. Week 8: App Store 제출

## 9) Resume/Portfolio Angle
- 기존 Web 프로젝트와 동일 백엔드 연동
- 기능 재사용이 아닌 플랫폼 재설계(UI/상태관리) 강조
- 출시 경험(TestFlight/App Store)까지 증빙

## 10) Open Decisions
- 앱 최소 지원 iOS 버전 (권장: iOS 17+)
- 관리자 기능 포함 여부 (MVP에서는 제외 권장)
- 디자인 시스템 범위 (웹과 동일 톤 vs iOS 네이티브 톤)
