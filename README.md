# Automated Infrastructure & Observability Pipeline for Stateful Workloads

## 1. 프로젝트 개요 (Overview)
- Terraform(IaC)과 Ansible(CaC) 연동을 통한 인프라 프로비저닝 및 설정 자동화 파이프라인 구축.
- Tailscale 기반 사설망 통신 및 ELK 스택 기반 로그 중앙화 아키텍처 요약.

## 2. 기술 스택 (Tech Stack)

### Infrastructure & Provisioning
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat-square&logo=terraform&logoColor=white)
![GCP](https://img.shields.io/badge/Google_Cloud-4285F4?style=flat-square&logo=googlecloud&logoColor=white)
![Cloudflare](https://img.shields.io/badge/Cloudflare-F38020?style=flat-square&logo=cloudflare&logoColor=white)

### Configuration & Automation
![Ansible](https://img.shields.io/badge/Ansible-EE0000?style=flat-square&logo=ansible&logoColor=white)
![Linux](https://img.shields.io/badge/Rocky_Linux-10B981?style=flat-square&logo=linux&logoColor=white)
![SteamCMD](https://img.shields.io/badge/SteamCMD-000000?style=flat-square&logo=steam&logoColor=white)

### Networking & Security
![Tailscale](https://img.shields.io/badge/Tailscale-FFFFFF?style=flat-square&logo=tailscale&logoColor=black)

### Observability
![Elasticsearch](https://img.shields.io/badge/Elasticsearch-005571?style=flat-square&logo=elasticsearch&logoColor=white)
![Logstash](https://img.shields.io/badge/Logstash-005571?style=flat-square&logo=logstash&logoColor=white)
![Kibana](https://img.shields.io/badge/Kibana-005571?style=flat-square&logo=kibana&logoColor=white)
![Filebeat](https://img.shields.io/badge/Filebeat-005571?style=flat-square&logo=elastic&logoColor=white)

## 3. 핵심 아키텍처 (Core Architecture)

- **프로비저닝 파이프라인**: Terraform 리소스 생성 직후 `local_file` 리소스로 Ansible `inventory.ini` 파일을 동적 생성함. 이를 통해 인프라 프로비저닝과 애플리케이션 배포 간의 수동 개입을 최소화함.
- **네트워크 및 보안**: 
  - Cloudflare API를 활용하여 DNS 레코드를 자동 등록하며, 게임 서버의 원활한 UDP 통신(포트 16261, 16262)을 위해 Proxy 옵션을 비활성화함.
  - Tailscale 사설망 VPN을 도입하여 ELK 모니터링 대역과 관리자 SSH 트래픽을 퍼블릭 망으로부터 분리 및 격리함.
  - Ansible Vault를 활용하여 인프라 전반의 민감한 인증 정보(Elasticsearch 비밀번호, Tailscale 인증 키 등)를 암호화하여 형상 관리함.

## 4. 데이터 파이프라인 (Data Pipeline)

- **Filebeat 활용**: 대상 애플리케이션의 텍스트 로그 및 Java 기반 에러 로그 수집.
- **Logstash Grok 필터링**: 애플리케이션 특유의 비정형 로그 데이터를 시계열 데이터로 분석하기 쉽도록 JSON 형태로 구조화함.

## 5. 트러블슈팅 및 성능 최적화 (Troubleshooting & Optimization)

- **Filebeat - Logstash 통신 장애 해결**: 
  - 초기 파이프라인 설정 시 Connection Refused 문제 발생.
  - Tailscale 사설망 대역에 맞춘 Logstash Bind IP 설정 및 GCP 방화벽의 모니터링 포트(5044, 5601) 허용 정책을 IaC/CaC 코드로 반영하여 파이프라인 통신을 정상화함.
- **비정형 로그 파싱 규칙 최적화**: 
  - 애플리케이션 로그에 불규칙한 Java 에러 메시지가 혼재되어 파싱 에러 및 지연 발생. 
  - 로그 패턴을 분석하여 Grok 정규식을 수정하고, 불필요한 디버그 로그는 필터링 단계에서 드롭(Drop) 처리하여 처리 성능을 개선함.
- **오류 모드 식별을 통한 클라이언트 접속 안정성 확보**: 
  - 초기 150여 개의 게임 모드(Mod) 적용 시, 특정 클라이언트에서 메모리 부족(OOM) 및 접속 끊김 현상 발생. 
  - 서버 에러 로그를 분석하여 충돌과 과부하를 유발하는 스크립트/텍스처 모드를 식별하고 제거함. 바닐라 친화적(Vanilla-friendly) 환경으로 경량화하여 접속 안정성을 확보함.
- **상태 동기화 지연(Desync) 완화**: 
  - Stateful 워크로드 특유의 멀티플레이 위치 동기화 지연 현상 발생. 
  - 서버 모니터링 결과를 바탕으로 JVM Heap Size를 24GB로 조절하고, 커뮤니티에서 검증된 최적화 패치 파일(.class)을 Ansible을 통해 자동 교체 및 배포하도록 구성하여 연산 지연 현상을 완화함.
- **크로스 플랫폼 실행 의존성 해결**: 
  - Linux(GCP) 환경에서 SteamCMD 구동 시 발생하는 32-bit 라이브러리 누락 오류 및 Windows 개행 문자(^M)로 인한 스크립트 실행 오류 발생.
  - 필수 라이브러리(glibc.i686 등) 설치 및 개행 문자 치환 작업을 Ansible Role에 통합하여 수동 환경 설정의 번거로움을 해결함.
