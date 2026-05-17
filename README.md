# ReactToiOS

React + Spring Boot 기반 기존 관리자 서비스를 Swift iOS 앱으로 포팅하는 프로젝트입니다.

## Goal
- 기존 백엔드를 재사용해 iOS 클라이언트 출시
- MVP 기능을 빠르게 완성하고 TestFlight 배포

## Scope (MVP)
- 로그인/회원가입
- 관리자 계정 빠른 로그인 버튼
- 로그인 세션 복원/로그아웃/401 처리
- 대시보드(요약 카드 + 매출 추이 차트)
- 대시보드 메뉴 구조: Dashboard, Resume, Products, Recruits, Devlogs, Settings
- 상품 목록/상세
- 내 계정 기본 화면

## Tech (planned)
- SwiftUI
- MVVM
- async/await + URLSession
- Keychain (토큰 저장)
