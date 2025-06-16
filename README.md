# Basic NCP Server Example | 기본 NCP 서버 예제

This example demonstrates creating a basic Windows Server 2016 instance on Naver Cloud Platform using Terraform. The configurations provided have been tested and verified to work reliably.

이 예제는 Terraform을 사용하여 Naver Cloud Platform에서 기본 Windows Server 2016 인스턴스를 생성하는 방법을 보여줍니다. 제공된 구성은 테스트되고 안정적으로 작동하는 것이 확인되었습니다.

## What This Example Creates | 이 예제가 생성하는 것

- **Windows Server 2016** instance with customizable specifications | 사용자 정의 가능한 사양의 Windows Server 2016 인스턴스
- **Login Key** (SSH key pair) for server access | 서버 접근을 위한 로그인 키 (SSH 키 페어)
- **Resource outputs** with connection information and server details | 연결 정보 및 서버 세부 정보가 포함된 리소스 출력

## Prerequisites | 필수 요구사항

1. **NCP Account** with appropriate permissions | 권한이 주어진 NCP 계정
2. **Terraform** installed (version >= 1.0) | Terraform 설치 (버전 >= 1.0)
3. **NCP API credentials** configured | NCP API 자격 증명 구성

## Quick Start | 빠른 시작

### 1. Set up your credentials | 자격 설정

```bash
# Set environment variables (recommended) | 환경 변수 설정 (권장)
export NCLOUD_ACCESS_KEY="your-access-key"
export NCLOUD_SECRET_KEY="your-secret-key"
```

### 2. Configure your variables | 변수 구성

```bash
# Copy the example variables file | 예제 변수 파일 복사
cp terraform.tfvars.example terraform.tfvars

# Edit with your preferences | 설정 편집
nano terraform.tfvars
```

### 3. Deploy the infrastructure | 인프라 배포

```bash
# Initialize Terraform | Terraform 초기화
terraform init

# Review the execution plan | 실행 계획 검토
terraform plan

# Apply the configuration | 구성 적용
terraform apply
```

### 4. Connect to your server | 서버 연결

After deployment, use the output information to connect:
배포 후 출력 정보를 사용하여 연결:

```bash
# View connection information | 연결 정보 확인
terraform output connection_info

# For Windows servers, use RDP with the public IP
# Windows 서버의 경우 공용 IP로 RDP 사용
# Default RDP port: 3389 | 기본 RDP 포트: 3389
```

## Configuration Options | 구성 옵션

### Server Specifications | 서버 사양

Based on testing, here are the recommended configurations:
테스트를 기반으로 한 권장 구성:

| Server Type<br/>서버 유형 | Code<br/>코드 | vCPU | RAM | Storage<br/>스토리지 | Provisioning Time<br/>프로비저닝 시간 |
|-------------|------|------|-----|---------|-------------------|
| **Standard Small**<br/>**표준 소형** | `SPSVRSTAND000049A` | 2 | 2GB | 100GB HDD | 5-10 minutes<br/>5-10분 |
| **Standard Medium**<br/>**표준 중형** | `SPSVRSTAND000004A` | 2 | 4GB | 100GB HDD | 5-15 minutes<br/>5-15분 |

> 💡 **Tip | 팁**: Provisioning times can vary significantly depending on infrastructure load.  
> 프로비저닝 시간은 인프라 부하에 따라 크게 달라질 수 있습니다.

### Availability Zones | 가용 영역

- **KR-1**: Only available zone in NCP (despite what some documentation might suggest about KR-2)  
- **KR-1**: NCP에서 사용 가능한 유일한 영역 (일부 문서에서 KR-2를 언급하더라도)

## Troubleshooting | 문제 해결

### Common Issues | 일반적인 문제

**1. Server name length error | 서버 이름 길이 오류**
```
Error: "Please check your input value : [server-name]. Length constraints: Minimum length of 3. Maximum length of 15."
```
**Solution | 해결책**: Ensure server name is 3-15 characters long.  
서버 이름이 3-15자인지 확인하세요.

**2. Provisioning timeout (15+ minutes) | 프로비저닝 타임아웃 (15분 이상)**  
**Common issue | 일반적인 문제**: Extended provisioning times occasionally occur  
긴 프로비저닝 시간이 가끔 발생합니다  
**Solution | 해결책**: 
- Stop the process with `Ctrl+C` | `Ctrl+C`로 프로세스 중지
- Run `terraform destroy` to clean up | `terraform destroy`로 정리
- Retry the deployment - success often varies between attempts | 재배포 시도 - 시도마다 성공률이 다름
- This appears to be infrastructure-related rather than configuration issues | 구성 문제가 아닌 인프라 관련 문제로 보임

**3. Compatible server product code error | 호환 서버 제품 코드 오류**
```
Error: "Cannot find matched product code [PRODUCT_CODE] matching server image [IMAGE_CODE]"
```
**Issue | 문제**: Not all server product codes are compatible with all image types  
모든 서버 제품 코드가 모든 이미지 유형과 호환되는 것은 아닙니다  
**Solution | 해결책**: Use the verified combinations provided in `terraform.tfvars.example`  
`terraform.tfvars.example`에 제공된 검증된 조합을 사용하세요

### Key Observations | 주요 관찰사항

1. **Provisioning variability** - Identical configurations may take 3-15+ minutes depending on infrastructure load  
   **프로비저닝 변동성** - 동일한 구성도 인프라 부하에 따라 3-15분+ 소요될 수 있음
2. **Limited OS options** - Windows images are readily available; Linux availability may vary by region/account  
   **제한된 OS 옵션** - Windows 이미지는 쉽게 사용 가능; Linux 가용성은 지역/계정에 따라 다를 수 있음
3. **Strict naming requirements** - Server names must be exactly 3-15 characters  
   **엄격한 명명 요구사항** - 서버 이름은 정확히 3-15자여야 함
4. **Product compatibility** - Specific server product codes work with specific image types  
   **제품 호환성** - 특정 서버 제품 코드는 특정 이미지 유형과만 작동

## Cleanup | 정리

To destroy the resources | 리소스 삭제:

```bash
terraform destroy
```

## Cost Considerations | 비용 고려사항

Estimated monthly costs for standard server configurations:  
표준 서버 구성의 예상 월 비용:
- **Standard servers | 표준 서버**: Approximately $25-40/month depending on specifications  
  사양에 따라 월 약 $25-40
- **Remember to destroy** test resources to avoid unnecessary charges  
  **테스트 리소스 삭제**를 잊지 마세요 (불필요한 요금 방지)

---

*These configurations have been tested and verified to work reliably with NCP's Terraform provider.*  
*이 구성들은 NCP의 Terraform 프로바이더와 안정적으로 작동하는 것을 테스트하였습니다.*
