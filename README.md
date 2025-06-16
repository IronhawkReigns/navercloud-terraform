# Naver Cloud Platform Terraform Example | 네이버 클라우드 플랫폼 Terraform 예제


This example demonstrates a production-ready, complete VPC infrastructure on NCP with proper network segmentation, security groups, and multi-tier architecture. It includes VPC, subnets, security groups, NAT gateway, and bastion host configuration.

이 예제는 적절한 네트워크 분할, 보안 그룹, 멀티티어 아키텍처를 갖춘 NCP에서의 프로덕션 준비가 완료된 완전한 VPC 인프라입니다. VPC, 서브넷, 보안 그룹, NAT 게이트웨이, 배스천 호스트 구성이 포함됩니다.

## Architecture Overview | 아키텍처 개요

```
                    Internet
                        │
                 Internet Gateway
                        │
              ┌─────────┴─────────┐
              │   Public Subnet    │
              │   (10.0.1.0/24)   │
              │                   │
              │  ┌─────────────┐  │
              │  │ Web Servers │  │  ← HTTP/HTTPS from Internet
              │  │   [2 instances] │  │
              │  └─────────────┘  │
              │                   │
              │  ┌─────────────┐  │
              │  │ Bastion Host│  │  ← SSH/RDP from Admin IPs
              │  └─────────────┘  │
              │                   │
              │  ┌─────────────┐  │
              │  │ NAT Gateway │  │  ← Outbound Internet for Private
              │  └─────────────┘  │
              └─────────┬─────────┘
                        │
              ┌─────────┴─────────┐
              │  Private Subnet   │
              │   (10.0.2.0/24)   │
              │                   │
              │  ┌─────────────┐  │
              │  │ DB Servers  │  │  ← MySQL/SQL from Web Servers only
              │  │   [1 instance]  │  │
              │  └─────────────┘  │
              └───────────────────┘
```

## What This Example Creates | 이 예제가 생성하는 것

### Network Infrastructure | 네트워크 인프라
- **VPC** with custom CIDR block | 사용자 정의 CIDR 블록이 있는 VPC
- **Internet Gateway** for public internet access | 공용 인터넷 접근을 위한 인터넷 게이트웨이
- **NAT Gateway** for private subnet internet access | 프라이빗 서브넷 인터넷 접근을 위한 NAT 게이트웨이
- **Public Subnet** for web servers and bastion | 웹 서버와 배스천용 퍼블릭 서브넷
- **Private Subnet** for database servers | 데이터베이스 서버용 프라이빗 서브넷
- **Route Tables** with proper routing configuration | 적절한 라우팅 구성이 있는 라우팅 테이블

### Security Infrastructure | 보안 인프라
- **3 Security Groups** with layered security | 계층화된 보안이 있는 3개의 보안 그룹
- **Bastion Host** for secure access to private resources | 프라이빗 리소스에 대한 보안 접근을 위한 배스천 호스트
- **Network ACLs** and security group rules | 네트워크 ACL 및 보안 그룹 규칙

### Server Infrastructure | 서버 인프라
- **Web Servers** (configurable count) in public subnet | 퍼블릭 서브넷의 웹 서버 (구성 가능한 개수)
- **Database Servers** (configurable count) in private subnet | 프라이빗 서브넷의 데이터베이스 서버 (구성 가능한 개수)
- **Bastion Host** for administrative access | 관리 접근을 위한 배스천 호스트
- **Public IPs** for internet-facing resources | 인터넷 연결 리소스용 퍼블릭 IP

## Security Configuration | 보안 구성

### Security Groups | 보안 그룹

#### Web Servers Security Group | 웹 서버 보안 그룹
- **HTTP (80)**: Open to internet (0.0.0.0/0) | 인터넷에 개방
- **HTTPS (443)**: Open to internet (0.0.0.0/0) | 인터넷에 개방
- **RDP (3389)**: From admin IPs and bastion host | 관리자 IP 및 배스천 호스트에서

#### Database Servers Security Group | 데이터베이스 서버 보안 그룹
- **MySQL (3306)**: Only from web servers security group | 웹 서버 보안 그룹에서만
- **SQL Server (1433)**: Only from web servers security group | 웹 서버 보안 그룹에서만
- **RDP (3389)**: Only from bastion host | 배스천 호스트에서만

#### Bastion Host Security Group | 배스천 호스트 보안 그룹
- **RDP (3389)**: From admin IPs only | 관리자 IP에서만
- **SSH (22)**: From admin IPs only | 관리자 IP에서만

## Quick Start | 빠른 시작

### 1. Configure your environment | 환경 구성

```bash
# Copy the example configuration | 예제 구성 복사
cp terraform.tfvars.example terraform.tfvars

# Edit the configuration | 구성 편집
nano terraform.tfvars
```

**Critical Security Configuration | 중요한 보안 구성:**
```hcl
# MUST CHANGE: Set to your office/home IP range
# 반드시 변경: 사무실/집 IP 범위로 설정
admin_access_cidr = "YOUR.IP.ADDRESS.0/24"  # NOT 0.0.0.0/0!
```

### 2. Deploy the infrastructure | 인프라 배포

```bash
# Initialize Terraform | Terraform 초기화
terraform init

# Review the plan | 계획 검토
terraform plan

# Deploy the infrastructure | 인프라 배포
terraform apply
```

### 3. Access your infrastructure | 인프라 접근

```bash
# View complete infrastructure summary | 완전한 인프라 요약 보기
terraform output infrastructure_summary

# Get connection guide | 연결 가이드 확인
terraform output connection_guide

# View network architecture | 네트워크 아키텍처 보기
terraform output network_architecture_diagram
```

## Access Patterns | 접근 패턴

### Web Server Access | 웹 서버 접근
```bash
# Direct HTTP/HTTPS access | 직접 HTTP/HTTPS 접근
curl http://[WEB_SERVER_PUBLIC_IP]
curl https://[WEB_SERVER_PUBLIC_IP]

# Admin RDP access (from allowed IP) | 관리자 RDP 접근 (허용된 IP에서)
mstsc /v:[WEB_SERVER_PUBLIC_IP]:3389
```

### Database Access via Bastion | 배스천을 통한 데이터베이스 접근
```bash
# Step 1: Connect to bastion host | 1단계: 배스천 호스트 연결
mstsc /v:[BASTION_PUBLIC_IP]:3389

# Step 2: From bastion, connect to database | 2단계: 배스천에서 데이터베이스 연결
mstsc /v:[DB_SERVER_PRIVATE_IP]:3389

# Or database connection from web server | 또는 웹 서버에서 데이터베이스 연결
mysql -h [DB_SERVER_PRIVATE_IP] -P 3306 -u username -p
```

## Environment Configurations | 환경 구성

### Development Environment | 개발 환경
```hcl
web_server_count = 1
db_server_count = 1
web_server_product_code = "SPSVRSTAND000049A"  # 2vCPU, 2GB
db_server_product_code = "SPSVRSTAND000004A"   # 2vCPU, 4GB
create_bastion = false
```
**Cost | 비용**: ~$80-90/month | 월 약 $80-90

### Staging Environment | 스테이징 환경
```hcl
web_server_count = 2
db_server_count = 1
web_server_product_code = "SPSVRSTAND000004A"  # 2vCPU, 4GB
db_server_product_code = "SPSVRSTAND000005A"   # 4vCPU, 8GB
create_bastion = true
```
**Cost | 비용**: ~$140-160/month | 월 약 $140-160

### Production Environment | 프로덕션 환경
```hcl
web_server_count = 3
db_server_count = 2
web_server_product_code = "SPSVRSTAND000005A"  # 4vCPU, 8GB
db_server_product_code = "SPSVRSTAND000006A"   # 8vCPU, 16GB
create_bastion = true
enable_monitoring = true
enable_protection = true
```
**Cost | 비용**: ~$280-320/month | 월 약 $280-320

## Troubleshooting | 문제 해결

### Common Issues | 일반적인 문제

**1. VPC Creation Fails | VPC 생성 실패**
```
Error: VPC creation failed
```
**Solution | 해결책**: Ensure CIDR blocks don't overlap and are valid  
CIDR 블록이 겹치지 않고 유효한지 확인

**2. NAT Gateway Timeout | NAT 게이트웨이 타임아웃**
**Issue | 문제**: NAT Gateway creation takes longer than expected  
NAT 게이트웨이 생성이 예상보다 오래 걸림  
**Solution | 해결책**: This is normal for NAT Gateway creation (5-10 minutes)  
NAT 게이트웨이 생성에는 정상적으로 5-10분 소요

**3. Security Group Rule Conflicts | 보안 그룹 규칙 충돌**
**Issue | 문제**: Rules may conflict during creation  
생성 중 규칙이 충돌할 수 있음  
**Solution | 해결책**: Apply in stages using `-target` flag  
`-target` 플래그를 사용하여 단계별로 적용

**4. Server Placement Errors | 서버 배치 오류**
**Issue | 문제**: Servers fail to launch in specific subnets  
특정 서브넷에서 서버 시작 실패  
**Solution | 해결책**: Check subnet availability and zone configuration  
서브넷 가용성 및 영역 구성 확인

## Security Best Practices | 보안 모범 사례

### Implemented Features | 구현된 기능
- Network segmentation with public/private subnets | 퍼블릭/프라이빗 서브넷으로 네트워크 분할
- Bastion host for secure access to private resources | 프라이빗 리소스에 대한 보안 접근을 위한 배스천 호스트
- Database isolation in private subnet | 프라이빗 서브넷에서 데이터베이스 격리
- Layered security groups with least privilege | 최소 권한 원칙의 계층화된 보안 그룹
- NAT Gateway for controlled outbound access | 제어된 아웃바운드 접근을 위한 NAT 게이트웨이

### Recommended Improvements | 권장 개선사항
- Set specific IP ranges for admin access | 관리자 접근에 특정 IP 범위 설정
- Implement SSL certificates for HTTPS | HTTPS용 SSL 인증서 구현
- Add monitoring and logging | 모니터링 및 로깅 추가
- Configure automated backups | 자동 백업 구성
- Implement intrusion detection | 침입 탐지 구현

## Scaling and Modifications | 확장 및 수정

### Adding More Servers | 서버 추가
```hcl
# Scale web tier | 웹 티어 확장
web_server_count = 4  # Increase from 2 to 4

# Add database replicas | 데이터베이스 복제본 추가
db_server_count = 3   # Increase from 1 to 3
```

### Network Expansion | 네트워크 확장
```hcl
# Add additional subnets (requires code modification)
# 추가 서브넷 추가 (코드 수정 필요)
# Example: Add staging subnet (10.0.3.0/24)
```

## Cost Optimization | 비용 최적화

### Development Tips | 개발 팁
- Use smaller server instances | 더 작은 서버 인스턴스 사용
- Disable bastion host when not needed | 필요하지 않을 때 배스천 호스트 비활성화
- Use single database server | 단일 데이터베이스 서버 사용

### Production Considerations | 프로덕션 고려사항
- Monitor NAT Gateway data transfer costs | NAT 게이트웨이 데이터 전송 비용 모니터링
- Review public IP usage regularly | 퍼블릭 IP 사용량 정기 검토
- Consider reserved instances for long-term use | 장기 사용 시 예약 인스턴스 고려

## Cleanup | 정리

To destroy all infrastructure:  
모든 인프라를 삭제하려면:

```bash
terraform destroy
```

**Warning | 경고**: This will destroy all VPC resources including servers, networking, and data.  
이는 서버, 네트워킹, 데이터를 포함한 모든 VPC 리소스를 삭제합니다.

## Next Steps | 다음 단계

1. **Application Deployment | 애플리케이션 배포**
   - Configure web servers with your application | 애플리케이션으로 웹 서버 구성
   - Set up database with proper schemas | 적절한 스키마로 데이터베이스 설정

2. **Load Balancing | 로드 밸런싱**
   - Add NCP Load Balancer for web servers | 웹 서버용 NCP 로드 밸런서 추가
   - Configure health checks | 헬스 체크 구성

3. **Monitoring and Backup | 모니터링 및 백업**
   - Implement monitoring solutions | 모니터링 솔루션 구현
   - Set up automated backup procedures | 자동 백업 절차 설정

## Related Examples | 관련 예제

- [Basic Server](../01-basic-server/) - Simple single server setup | 간단한 단일 서버 설정
- [Multi-Server Security](../02-multi-server-security/) - Multi-server without VPC | VPC 없는 멀티 서버
