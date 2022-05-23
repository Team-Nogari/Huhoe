# 후회 - 그 때 샀으면 지금 얼마일까?

![image](https://user-images.githubusercontent.com/70251136/169486601-47e9ec88-1df7-4570-b6f9-467075d7e099.png)

> **후회 - 그 때 샀으면 지금 얼마일까?**
> 
> 그 때 샀다면.. 지금 얼마였을까? 
> 상상만 하지말고, 과거와 실시간 가격을 비교해보세요!
> 
> 개발 기간 : 2022.04.06 ~ 업데이트 진행 중
> 출시 날짜 : 2022.05.22


## 앱 스토어 링크
[<img src="https://i.imgur.com/kZiWHOT.png" width="100" height="100">](https://apps.apple.com/kr/app/%ED%9B%84%ED%9A%8C-%EA%B7%B8-%EB%95%8C-%EC%83%80%EC%9C%BC%EB%A9%B4-%EC%A7%80%EA%B8%88-%EC%96%BC%EB%A7%88%EC%9D%BC%EA%B9%8C/id1624645983)

## 개발자 소개
|임지성|황제하|
|:---:|:---:|
|<img src="https://i.imgur.com/HlOi6PK.jpg" width="250" height="250">|<img src="https://i.imgur.com/i9r6sJJ.jpg" width="250" height="250">|
|[@yim2627](https://github.com/yim2627)|[@HJEHA](https://github.com/HJEHA)|

## 프로젝트 소개

### 개발 환경
![](https://img.shields.io/badge/Xcode-13.3-blue) ![](https://img.shields.io/badge/Swift-5.6-orange) ![](https://img.shields.io/badge/RxSwift-6.5.0-red) ![](https://img.shields.io/badge/Lottie-3.3.0-yellow) ![](https://img.shields.io/badge/SPM-0.6.0-red)

### 구동 화면

|온보딩 뷰|메인 화면|상세 화면|
|:---:|:---:|:---:|
|<img src="https://i.imgur.com/Pjv8fEn.gif" width="240">|<img src="https://user-images.githubusercontent.com/70251136/169845105-42c57615-f99c-4c74-9011-2bba52f3f403.gif" width="240">|<img src="https://i.imgur.com/CRFii1Q.gif" width="240">|

## 프로젝트 주요 기능
### 비동기 프로그래밍(RxSwift)
- `Escaping Closure` 중첩 사용을 피하고, 선언형 프로그래밍을 통해 코드 응집도를 높이고, 효율적인 비동기 처리를 위해 `RxSwift`를 사용하였습니다.
- 발생한 데이터를 RxSwift를 통해 데이터 각각 하나의 스트림을 따라 View까지 이어지고, 스트림이 끊어지지 않도록 데이터 바인딩을 구현하였습니다.

### 실시간 가격 조회
- `URLSessionWebSocketTask`을 활용하여 상세화면에서 코인 가격을 실시간으로 갱신하고 있습니다.

### 날짜별 종가 차트
- `UIImageView`의 `Context`와 `Path`을 활용하여 날짜별 종가 차트를 구현했습니다.

### 과거 코인 가격 조회, 현재 가격과 손익 계산
- URLSession을 사용하여 Http통신을 구현하였습니다.
- RxSwift를 사용하여 서버에 GET요청 후 받아오는 데이터를 하나의 스트림으로 View에 적용되도록 하였습니다.
- 코인에 대한 상세 정보(과거/현재 가격, 거래량, 거래대금, 체결 내역)를 요청하여 거래대금 Top50 코인의 정보를 가져와 선택한 날짜의 가격을 조회하고 있습니다.
- 투자 날짜, 투자금을 Input으로 받은 후 ViewModel에서 가격 비교 및 손익 계산한 후 뷰에 반영하였습니다.

### Diffable DataSource 
- 컬렉션 뷰를 구현할 때 `Diffable DataSource`를 사용하였습니다.
- 뷰모델에서 가공한 타입에 Hashable을 채택 후 Output으로 바인딩 해줬습니다.
- 뷰컨트롤러에서 Output을 subscrive후 내려온 데이터를 apply 했습니다.

## App Architecture

![](https://i.imgur.com/BvIKHWI.png)

### MVVM
+ MVVM을 도입하여 뷰컨트롤러와 뷰는 화면을 그리는 역할에만 집중하고, 데이터 관리, 비지니스 로직은 뷰모델에서 진행하여 역할을 명확히 하였습니다.

### Clean Architecture
+ Presentation Layer, Domain Layer, Data Layer로 역할과 영역을 분리하여 관리했습니다.
+ Presentation Layer에는 `뷰`, `뷰컨트롤러`, `뷰모델`이 포함되어 있습니다.
+ Domain Layer에는 `Entity(모델)`, `UseCase`, `Repository(Protocol)`이 포함되어 있습니다.
+ Data Layer에는 `DTO(네트워크 모델)`, `Repository`, `Network Service`가 포함되어 있습니다.

### Input/Output Modeling
+ 뷰모델에 Input과 Output을 정의했습니다.
+ 뷰, 뷰컨트롤러에서 들어오는 입력 값을 Input으로 정의하고 Input과 데이터를 가공하여 뷰에 보여질 데이터를 Output으로 바인딩했습니다.

> 향후 MVMM-C 적용 예정


## 상세 내용 (트러블 슈팅 등) WIKI 작성중
