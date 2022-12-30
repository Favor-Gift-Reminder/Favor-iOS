
# 페이버 - Favor
<img height="250" src="https://via.placeholder.com/250"></img>
> **_선물 기록/리마인더 앱_** <br/>
> **_개발기간: 2022.12.29_**

<br/>

## ⭐️ 프로젝트 소개

선물 기록/리마인더 앱

<br/>

## 🔨 개발환경 및 라이브러리

[![Swift Badge](http://img.shields.io/badge/-5.7.1-555555?style=for-the-badge&label=Swift&labelColor=F54A2A&logo=swift&logoColor=white)]() <br/>
[![SnapKit Badge](http://img.shields.io/badge/-5.6.0-555555?style=for-the-badge&label=SnapKit&labelColor=4AA5b7&logoColor=white)]()
[![ReactorKit Badge](http://img.shields.io/badge/-3.2.0-555555?style=for-the-badge&label=ReactorKit&labelColor=5D8FDB&logoColor=white)]()
[![RxSwift Badge](http://img.shields.io/badge/-6.5.0-555555?style=for-the-badge&label=RxSwift&labelColor=EC5BB0&logoColor=white)]() <br/>

<br/>

## iOS

|이창준|김응철|
|:-:|:-:|
|<img src="https://avatars.githubusercontent.com/u/60438045?v=4" width=200>|<img src="https://avatars.githubusercontent.com/u/97531269?v=4" width=200>|
|[@nomatterjun](https://github.com/nomatterjun)|[@eung7](https://github.com/eung7)|

<br/>

## ⚒ 아키텍쳐 

### ⏺ MVVM-C & ReactorKit

> **MVVM**
- MVVM 패턴을 사용하여 ViewController에는 화면 구성 코드만 담고 ViewModel(Reactor)에게 비즈니스 로직과 데이터 가공 코드를 담았습니다.
- 비즈니스 로직 테스트에서 UI 컴포넌트 의존성을 없앨 수 있어 유닛 테스트에 용이했습니다.
> **Coordinator**
- Navigation Controller로 대표되는 화면 전환 로직들을 코디네이터 패턴에 전임하여 뷰 전환 코드의 재사용성을 높였습니다.
- 데이터 전달, 의존성 주입 등의 로직을 비즈니스 로직에서 분리하여 코디네이터가 담당하도록 하였습니다.
> **ReactorKit**
- ViewModel마다 신경써야 했던 의존성 주입 문제의 피곤을 덜 수 있도록 ReactorKit을 도입하였습니다.
- Action ➡️ Mutate ➡️ State의 일방성 스트림을 통해 자연스러운 코딩 컨벤션 통일이 가능했습니다.
<br/>

## ⚽ 테크 Goal

### 🔀 RxSwift + ReactorKit
- description of challenge
### ⚒️ XCTest 코드 작성
- description of challenge

<br/>
