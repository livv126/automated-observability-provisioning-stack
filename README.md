# Automated Infrastructure & Observability Pipeline for Stateful Workloads
> **프로젝트 목표:** 멀티플레이어 게임 서버(Project Zomboid) 등 상태 유지(Stateful) 워크로드의 프로비저닝 자동화 및 중앙 집중형 로그 모니터링 환경 구축

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat-square&logo=terraform&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-EE0000?style=flat-square&logo=ansible&logoColor=white)
![Google Cloud](https://img.shields.io/badge/Google_Cloud-4285F4?style=flat-square&logo=googlecloud&logoColor=white)
![Observability](https://img.shields.io/badge/Observability-ELK_Stack-005571?style=flat-square)

## 1. 프로젝트 개요
실시간 상태 동기화와 대용량 메모리를 요구하는 Stateful 애플리케이션(Project Zomboid 게임 서버)을 대상으로, 인프라 생성부터 애플리케이션 설정까지 전 과정을 자동화한 파이프라인 프로젝트.

Terraform(IaC)과 Ansible(CaC)을 연동하여 수동 개입 없는 배포 환경을 구현했으며, Tailscale 사설망 기반의 보안 통신망 위에 ELK 스택(Elasticsearch, Logstash, Kibana, Filebeat)을 구축하여 비정형 애플리케이션 로그와 에러를 중앙 집중적으로 모니터링하는 아키텍처를 설계함.

---

## 2. 아키텍처 구성도
Cloudflare를 통한 DNS 관리와 UDP 트래픽의 직접 인입을 구성하고, 관리 및 모니터링 목적의 트래픽은 Tailscale 사설망(VPN)으로 완벽히 격리한 구조.

```mermaid

    end
```

---

## 3. 핵심 기술 및 구현 논리

* **프로비저닝 파이프라인 자동화 (IaC & CaC 연동)**
    * Terraform으로 리소스(GCP 인스턴스, 방화벽 등) 생성 직후 `local_file` 리소스를 활용해 Ansible `inventory.ini` 파일을 동적으로 생성. 이를 통해 인프라 프로비저닝과 애플리케이션 배포 파이프라인을 하나의 흐름으로 통합함.
    * Ansible Vault를 활용해 인프라 전반의 민감한 인증 정보(Elasticsearch 비밀번호, Tailscale 인증 키 등)를 암호화하여 형상 관리함.
* **네트워크 및 보안 설계**
    * Cloudflare API를 통해 DNS 레코드를 자동 등록하며, 실시간 게임 서버의 원활한 UDP 통신(16261, 16262 포트) 보장을 위해 Proxy 옵션을 명시적으로 비활성화함.
    * Tailscale 사설망 VPN을 도입하여, ELK 모니터링 데이터 수집 대역과 관리자 SSH 트래픽을 퍼블릭 인터넷으로부터 완전히 격리함.
* **데이터 파이프라인 (Observability)**
    * **Filebeat:** 대상 애플리케이션의 일반 텍스트 로그 및 JVM 기반 에러 로그 실시간 수집.
    * **Logstash Grok 파싱:** 애플리케이션 특유의 비정형 로그 데이터를 정규식으로 분석하여, 시계열 검색에 용이한 JSON 형태로 구조화함.

---

## 4. 기술 스택

| 분류 | 기술 스택 | 적용 목적 및 활용 |
|:---:|:---|:---|
| **IaC / CaC** | ![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat-square&logo=terraform&logoColor=white) ![Ansible](https://img.shields.io/badge/Ansible-EE0000?style=flat-square&logo=ansible&logoColor=white) | GCP 리소스 프로비저닝 및 SteamCMD, 게임 환경 설정 자동화 |
| **Infrastructure** | ![GCP](https://img.shields.io/badge/Google_Cloud-4285F4?style=flat-square&logo=googlecloud&logoColor=white) ![Cloudflare](https://img.shields.io/badge/Cloudflare-F38020?style=flat-square&logo=cloudflare&logoColor=white) | 클라우드 컴퓨팅 및 DNS 레코드 자동화 |
| **App & Runtime** | ![Linux](https://img.shields.io/badge/Rocky_Linux-10B981?style=flat-square&logo=linux&logoColor=white) ![SteamCMD](https://img.shields.io/badge/SteamCMD-000000?style=flat-square&logo=steam&logoColor=white) | 서버 구동 환경 및 전용 서버 애플리케이션 관리 |
| **Networking** | ![Tailscale](https://img.shields.io/badge/Tailscale-FFFFFF?style=flat-square&logo=tailscale&logoColor=black) | 관리자 및 로그 수집기 간의 제로 트러스트 사설망 구축 |
| **Observability** | ![Elasticsearch](https://img.shields.io/badge/Elasticsearch-005571?style=flat-square&logo=elasticsearch&logoColor=white) ![Logstash](https://img.shields.io/badge/Logstash-005571?style=flat-square&logo=logstash&logoColor=white) ![Kibana](https://img.shields.io/badge/Kibana-005571?style=flat-square&logo=kibana&logoColor=white) | 애플리케이션 로그, JVM 에러 및 성능 메트릭 중앙 집중화 |

---

## 5. Technical Challenges & Troubleshooting

**① Filebeat - Logstash 통신 장애 (Connection Refused) 해결**
* **문제:** 초기 파이프라인 구성 시 Filebeat가 Logstash(5044 포트)로 로그를 전송하지 못하고 연결 거부 에러가 지속적으로 발생함.
* **해결:** 퍼블릭 망을 통한 데이터 유출 방지를 위해 통신 대역을 Tailscale VPN 사설망으로 한정함. Logstash의 Bind IP를 Tailscale 인터페이스 IP로 고정하고, 해당 대역에서만 5044 및 5601 포트 접근이 가능하도록 방화벽 규칙을 IaC/CaC 코드로 일괄 적용하여 안전한 파이프라인 통신을 확보함.

**② 비정형 Java 에러 로그 파싱 규칙 최적화**
* **문제:** 애플리케이션 로그에 불규칙한 형태의 Java 스택 트레이스 에러가 혼재되어 Logstash 파싱 에러 및 지연이 발생함.
* **해결:** 중앙 수집된 로그 패턴을 분석하여 Grok 정규식을 수정하고 다중 줄(Multiline) 로그 처리 규칙을 도입함. 또한, 불필요한 단순 디버그 로그는 필터링 단계에서 드롭(Drop) 처리하도록 설정하여 전체 파이프라인의 인덱싱 성능을 개선함.

**③ 무거운 모드(Mod)로 인한 OOM 및 클라이언트 접속 장애 해결**
* **문제:** 서버 초기 구축 시 150여 개의 서드파티 모드를 적용했으나, 접속한 클라이언트(4~8인) 중 특정 인원에게서 지속적인 메모리 부족(OOM) 및 강제 연결 해제 현상 발생.
* **해결:** 중앙화된 에러 로그(Kibana) 대시보드를 분석하여 클라이언트와 서버 간 메모리 충돌 및 과부하를 유발하는 무거운 스크립트/텍스처 모드를 특정함. 해당 리소스를 제거하고 바닐라(Vanilla) 친화적 환경으로 경량화하여 접속 안정성을 확보함.

**④ Stateful 워크로드의 상태 동기화 지연(Desync) 완화**
* **문제:** 실시간 위치 및 상태 동기화가 필수적인 멀티플레이 워크로드 특성상, 오브젝트 생성 및 이동 시 연산 지연(Desync) 현상이 두드러지게 발생함.
* **해결:** 서버 리소스 모니터링 데이터를 바탕으로 JVM Heap Size를 24GB로 상향 조정함. 또한, 커뮤니티에서 검증된 네트워크 최적화 패치 파일(.class)을 Ansible 배포 파이프라인에 추가하여, 인프라 배포 시 서버에 자동으로 교체 및 적용되도록 구성함으로써 연산 지연을 대폭 완화함.

**⑤ 크로스 플랫폼 실행 의존성 및 개행 문자(CRLF) 오류 해결**
* **문제:** Linux(GCP) 환경에서 SteamCMD 구동 시 32-bit 라이브러리 누락으로 인한 바이너리 실행 실패 및, Windows 환경에서 작성된 설정 스크립트의 개행 문자(^M)로 인한 구문 오류 발생.
* **해결:** 애플리케이션 실행에 필수적인 `glibc.i686` 및 `libstdc++.i686` 패키지 설치 로직을 Ansible Role에 포함함. 또한 스크립트 배포 태스크에 정규식 치환 모듈을 적용하여 CRLF를 LF로 자동 변환하는 단계를 구성, 크로스 플랫폼 환경의 설정 번거로움과 휴먼 에러를 원천 차단함.
