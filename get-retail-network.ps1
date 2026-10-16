$ErrorActionPreference = "Stop"

$Region  = "us-east-1"
$Profile = "retailprod"

Write-Host "`nChecking AWS account..." -ForegroundColor Cyan

aws --profile $Profile sts get-caller-identity
if ($LASTEXITCODE -ne 0) {
    throw "Unable to verify AWS identity."
}

Write-Host "`nFinding Retail Banking Dev VPC..." -ForegroundColor Cyan

$VpcId = aws --profile $Profile ec2 describe-vpcs `
    --region $Region `
    --filters "Name=tag:Name,Values=vpc-retail-dev" `
    --query "Vpcs[0].VpcId" `
    --output text

if ($LASTEXITCODE -ne 0 -or !$VpcId -or $VpcId -eq "None") {
    throw "Could not find VPC tagged vpc-retail-dev."
}

Write-Host "VPC ID: $VpcId" -ForegroundColor Green

Write-Host "`nFinding subnets..." -ForegroundColor Cyan

$Subnets = aws --profile $Profile ec2 describe-subnets `
    --region $Region `
    --filters "Name=vpc-id,Values=$VpcId" `
    --query "Subnets[].{SubnetId:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,Name:Tags[?Key=='Name']|[0].Value}" `
    --output json | ConvertFrom-Json

$Subnets | Sort-Object CIDR | Format-Table Name, SubnetId, CIDR, AZ -AutoSize

$Public = @($Subnets | Where-Object { $_.Name -like "*public*" } | Sort-Object AZ)
$Private = @($Subnets | Where-Object { $_.Name -like "*private*" } | Sort-Object AZ)
$Database = @($Subnets | Where-Object { $_.Name -like "*db*" } | Sort-Object AZ)

if ($Public.Count -lt 2 -or $Private.Count -lt 2 -or $Database.Count -lt 2) {
    throw "Expected at least two public, two private, and two DB subnets. Check subnet Name tags."
}

Write-Host "`n--- Values for frontend/terraform.tfvars ---" -ForegroundColor Yellow

@"
vpc_id = "$VpcId"

public_subnets = [
$(($Public | ForEach-Object { '  "' + $_.SubnetId + '"' }) -join ",`n")
]

private_subnets = [
$(($Private | ForEach-Object { '  "' + $_.SubnetId + '"' }) -join ",`n")
]
"@

Write-Host "`n--- Values for database/terraform.tfvars ---" -ForegroundColor Yellow

@"
vpc_id = "$VpcId"

db_subnet_ids = [
$(($Database | ForEach-Object { '  "' + $_.SubnetId + '"' }) -join ",`n")
]
"@

Write-Host "`nCopy the appropriate values into each Terraform root's tfvars file." -ForegroundColor Green