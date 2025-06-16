# NCP Terraform Server Example | 네이버 클라우드 Terraform 예제

This example demonstrates creating a multi-tier server architecture on NCP with proper security group configuration. It creates separate web and database tiers with appropriate network security rules.

이 예제는 적절한 보안 그룹 구성으로 NCP에서 멀티티어 서버 아키텍처를 생성하는 방법을 보여줍니다. 적절한 네트워크 보안 규칙을 가진 별도의 웹 및 데이터베이스 티어를 생성합니다.

## Architecture | 아키텍처

```
Internet
    ↓
[Web Servers] ← HTTP(80), HTTPS(443)
    ↓ MySQL(3306)
[DB Servers] ← Only from Web Servers
    ↑
Admin Access (RDP 3389) ← Your IP only
```

## What This Example Creates | 이 예제가 생성하는 것

- **Multiple Web Servers** (configurable count) | 다수의 웹 서버 (구성 가능한 개수)
- **Multiple Database Servers** (configurable count) | 다수의 데이터베이스 서버 (구성 가능한 개수)
- **Security Groups** with tiered access control | 계층화된 접근 제어를 가진 보안 그룹
- **Shared Login Key** for all servers | 모든 서버용 공유 로그인 키
- **Comprehensive Outputs** with detailed infrastructure information | 상세한 인프라 정보가 포함된 포괄적인 출력

## Security Configuration | 보안 구성

### Web Tier Security Group | 웹 티어 보안 그룹
- **HTTP (80)**: Open to internet | 인터넷에 개방
- **HTTPS (443)**: Open to internet | 인터넷에 개방  
- **RDP (3389)**: Restricted to admin IPs | 관리자 IP로 제한

### Database Tier Security Group | 데이터베이스 티어 보안 그룹
- **MySQL (3306)**: Only from web servers | 웹 서버에서만 접근 가능
- **RDP (3389)**: Restricted to admin IPs | 관리자 IP로 제한

## Quick Start | 빠른 시작

### 1. Configure your setup | 설정 구성

```bash
# Copy the example file | 예제 파일 복사
cp terraform.tfvars.example terraform.tfvars

# Edit for your needs | 필요에 맞게 편집
nano terraform.tfvars
```

**Important Security Setting | 중요한 보안 설정:**
```hcl
# CHANGE THIS to your office/home IP for better security
# 보안을 위해 사무실/집 IP로 변경하세요
admin_access_cidr = "YOUR.IP.ADDRESS.0/24"  
```

### 2. Deploy the infrastructure | 인프라 배포

```bash
terraform init
terraform plan
terraform apply
```

### 3. View your infrastructure | 인프라 확인

```bash
# See all server information | 모든 서버 정보 확인
terraform output infrastructure_summary

# View network architecture | 네트워크 아키텍처 확인
terraform output network_architecture

# Get connection details | 연결 세부 정보 확인
terraform output connection_info
```

## Configuration Examples | 구성 예제

### Development Environment | 개발 환경
```hcl
web_server_count = 1
db_server_count = 1
web_server_product_code = "SPSVRSTAND000049A"  # 2vCPU, 2GB
db_server_product_code = "SPSVRSTAND000004A"   # 2vCPU, 4GB
```
**Cost | 비용**: ~$70-80/month | 월 약 $70-80

### Production Environment | 프로덕션 환경
```hcl
web_server_count = 3
db_server_count = 2
web_server_product_code = "SPSVRSTAND000005A"  # 4vCPU, 8GB
db_server_product_code = "SPSVRSTAND000006A"   # 8vCPU, 16GB
enable_monitoring = true
enable_protection = true
```
**Cost | 비용**: ~$195-215/month | 월 약 $195-215

## Security Best Practices | 보안 모범 사례

### Implemented | 구현됨
- Separate security groups for different tiers | 다른 티어를 위한 별도 보안 그룹
- Database access restricted to web tier only | 웹 티어에만 데이터베이스 접근 제한
- Admin access controllable by IP | IP로 제어 가능한 관리자 접근

### 🔧 Recommended Improvements | 권장 개선사항
- Use specific IP ranges instead of 0.0.0.0/0 for admin access | 관리자 접근에 0.0.0.0/0 대신 특정 IP 범위 사용
- Consider implementing a bastion host | 배스천 호스트 구현 고려
- Enable monitoring for production workloads | 프로덕션 워크로드에 모니터링 활성화

## Common Issues | 일반적인 문제

### 1. Server Name Too Long | 서버 이름이 너무 김
**Error**: Server name exceeds 15 characters
**Solution**: Keep `project_name` to 10 characters or less
`project_name`을 10자 이하로 유지

### 2. Security Group Rule Conflicts | 보안 그룹 규칙 충돌
**Issue**: Rules may conflict during creation
**Solution**: Apply in stages or recreate if needed
단계별로 적용하거나 필요시 재생성

### 3. Multiple Server Provisioning | 다중 서버 프로비저닝
**Issue**: Some servers may fail while others succeed
**Solution**: Check outputs to see which servers were created successfully
어떤 서버가 성공적으로 생성되었는지 출력을 확인

## Example Output | 출력 예제

After deployment, you'll see detailed information like:
배포 후 다음과 같은 상세 정보를 볼 수 있습니다:

```hcl
infrastructure_summary = {
  "total_servers" = 3
  "web_servers" = 2
  "db_servers" = 1
  "security_groups" = 2
  "cost_estimate" = {
    "monthly_web_servers" = "~$70/month (estimated)"
    "monthly_db_servers" = "~$45/month (estimated)"
    "total_estimated" = "~$115/month"
  }
}

network_architecture = {
  "web_tier" = {
    "servers" = ["webapp-web-1", "webapp-web-2"]
    "allowed_ports" = ["80 (HTTP)", "443 (HTTPS)", "3389 (RDP from admin)"]
    "security_group" = "webapp-web-sg"
  }
  "db_tier" = {
    "servers" = ["webapp-db-1"]
    "allowed_ports" = ["3306 (MySQL from web tier)", "3389 (RDP from admin)"]
    "security_group" = "webapp-db-sg"
  }
}
```

## Testing Your Setup | 설정 테스트

### 1. Test Web Server Access | 웹 서버 접근 테스트
```bash
# Test HTTP access to web servers | 웹 서버 HTTP 접근 테스트
curl http://[WEB_SERVER_PUBLIC_IP]

# RDP to web servers (from allowed IP) | 웹 서버 RDP 접근 (허용된 IP에서)
mstsc /v:[WEB_SERVER_PUBLIC_IP]:3389
```

### 2. Test Database Connectivity | 데이터베이스 연결 테스트
```bash
# From web server, test MySQL connection | 웹 서버에서 MySQL 연결 테스트
mysql -h [DB_SERVER_PRIVATE_IP] -u username -p

# Direct access should be blocked from internet | 인터넷에서 직접 접근은 차단되어야 함
```

## Scaling and Modifications | 확장 및 수정

### Adding More Servers | 서버 추가
```hcl
# Add more web servers | 웹 서버 추가
web_server_count = 3  # Increase from 2 to 3

# Add more database servers | 데이터베이스 서버 추가
db_server_count = 2   # Increase from 1 to 2
```

### Upgrading Server Specifications | 서버 사양 업그레이드
```hcl
# Upgrade web servers | 웹 서버 업그레이드
web_server_product_code = "SPSVRSTAND000005A"  # 4vCPU, 8GB

# Upgrade database servers | 데이터베이스 서버 업그레이드
db_server_product_code = "SPSVRSTAND000006A"   # 8vCPU, 16GB
```

## Cleanup | 정리

To destroy all resources:
모든 리소스를 삭제하려면:

```bash
terraform destroy
```

**Note | 참고**: This will destroy all servers and security groups created by this configuration.
이 구성으로 생성된 모든 서버와 보안 그룹이 삭제됩니다.

## Next Steps | 다음 단계

1. **Configure Applications | 애플리케이션 구성**
   - Install web server software (IIS, Apache, etc.) | 웹 서버 소프트웨어 설치
   - Set up database software (MySQL, SQL Server, etc.) | 데이터베이스 소프트웨어 설정

2. **Implement Load Balancing | 로드 밸런싱 구현**
   - Configure NCP Load Balancer | NCP 로드 밸런서 구성
   - Set up health checks | 헬스 체크 설정

3. **Enhance Security | 보안 강화**
   - Implement SSL certificates | SSL 인증서 구현
   - Set up VPN access | VPN 접근 설정
   - Configure monitoring and alerting | 모니터링 및 알림 구성

## Related Examples | 관련 예제

- [Basic Server](../01-basic-server/) - Start here if you're new to NCP Terraform | NCP Terraform이 처음이라면 여기서 시작
- [Complete Infrastructure](../04-complete-infrastructure/) - Full production setup | 완전한 프로덕션 설정

---

*This configuration has been tested with multiple server deployments and provides a solid foundation for multi-tier applications on NCP.*

*이 구성은 다중 서버 배포로 테스트되었으며 NCP에서 멀티티어 애플리케이션을 위한 견고한 기반을 제공합니다.*
