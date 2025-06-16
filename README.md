# Terraform on NAVER Cloud: Multi-Server Provisioning with Security Group  
*네이버 클라우드 플랫폼에서 다중 서버와 보안 그룹을 구성하는 Terraform 예제*

This project provides a clean, minimal example of how to provision multiple virtual servers on NAVER Cloud Platform (NCP) using Terraform.

> 본 프로젝트는 네이버 클라우드에서 Terraform을 활용해 여러 서버와 기본 보안 그룹을 자동으로 구축하는 실용 예제입니다.

It includes:

- A configurable number of Linux-based virtual machines (VMs)
- Basic network security rules via Access Control Groups (ACGs)
- Modular, readable structure suitable for both personal experiments and production bootstrapping

This repository is intended as a practical and reproducible reference for cloud engineers, DevOps professionals, or platform teams evaluating infrastructure-as-code (IaC) within the NAVER Cloud ecosystem.

> 이 저장소는 NAVER Cloud 환경에서 IaC(Infrastructure as Code)를 테스트하거나 적용하려는 엔지니어와 팀을 위한 **간결하고 재사용 가능한 템플릿** 역할을 합니다.  
> 한국 개발자 분들이 참고하시기에도 좋도록 작성되었습니다.

---

## Key Features (*주요 기능*)

- Multi-server provisioning via `count`  
  → `count`를 사용해 원하는 만큼 서버를 동시에 구성할 수 있습니다.
- Public IP output for each instance
- Basic SSH access control (port 22) using NCP's ACG  
  → 보안 그룹을 통한 SSH 접근 허용 예시 포함
- Modular structure separating variables, outputs, and tfvars  
  → 변수, 출력, 입력값(tfvars)을 분리해 관리가 쉽도록 설계
- Designed with reusability and clarity in mind

---

## File Structure (*파일 구조*)

```
.
├── main.tf               # Main Terraform logic
├── variables.tf          # Input variable definitions
├── terraform.tfvars      # Values for input variables
├── outputs.tf            # Exported server details
└── README.md             # This documentation (영문 + 한글)
```

---

## Requirements (*요구 사항*)

- [Terraform](https://developer.hashicorp.com/terraform/downloads) 1.5+
- NAVER Cloud Platform account (https://www.ncloud.com/)
- NCP Access Key & Secret Key

---

## Usage (*사용 방법*)

1. Clone the repository:

```bash
git clone https://github.com/your-username/ncp-terraform-example.git
cd ncp-terraform-example
```

2. Configure your credentials and settings:

```hcl
# terraform.tfvars
ncloud_access_key = "YOUR_ACCESS_KEY"
ncloud_secret_key = "YOUR_SECRET_KEY"
region            = "KR"
server_count      = 2
```

> 위와 같이 입력 후, 원하는 서버 수량(server_count)과 지역(region)을 설정하세요.

3. Initialize Terraform:

```bash
terraform init
```

4. Preview the execution plan:

```bash
terraform plan
```

5. Apply the configuration:

```bash
terraform apply
```

---

## What This Provisions (*생성되는 리소스 개요*)

- Multiple Linux VMs based on a specified count
- A single ACG allowing inbound SSH access (port 22)
- Public IP addresses for each instance
- Server details output to the terminal after apply

---

## Security Considerations (*보안 관련 주의 사항*)

This example allows SSH access from all IP addresses for demonstration purposes. In real-world scenarios, consider the following:

- Restrict SSH access to a specific CIDR block
- Use key pair authentication for all access
- Limit exposure by applying private subnets, NAT gateways, or jump hosts

> 본 예제는 기본적으로 SSH 접근을 허용하고 있으므로, 실제 운영 환경에서는 CIDR 제한, 키 기반 인증, NAT 또는 점프 서버 활용을 권장합니다.

---

## Potential Extensions (*확장 가능 예시*)

This example can be easily extended to demonstrate more advanced Terraform patterns, such as:

- Load balancer configuration (NLB)
- Auto-scaling groups
- Cloud-init or userdata scripting
- Modular separation (`modules/server`, `modules/network`)
- Multiple ACGs or tiered access control

> 단순한 실습에서 시작해, 모듈화, 오토스케일링, 보안 설계 등 더 복잡한 인프라 구현으로 발전시킬 수 있습니다.  
> Terraform 학습용으로도, 팀 단위 테스트/배포 자동화 기반으로도 확장 가능합니다.

---

## Author’s Note (*작성자 메모*)

This repository was created as part of an internship project at NAVER Cloud. It reflects practical experience building infrastructure with Terraform and demonstrates an understanding of real-world provisioning flows, security structure, and IaC best practices.

> 이 저장소는 NAVER Cloud 인턴십의 일환으로 개발되었으며, 단순 코드 구성에 그치지 않고 실제 인프라 배포 흐름에 대한 이해와 경험을 반영하고자 했습니다.  
> 실무에 가까운 실습 예제가 필요하신 한국 개발자 분들께도 도움이 되기를 바랍니다.
