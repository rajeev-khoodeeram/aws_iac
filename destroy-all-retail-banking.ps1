
$ErrorActionPreference = "Stop"

$RepoRoot = "C:\Users\rajee\Documents\AWS\IaC-AWS\bank-aws-terraform"

$Targets = @(
    @{
        Name = "Retail Banking Frontend"
        Path = Join-Path $RepoRoot "workloads\retail-banking\dev\frontend"
        Profile = "retailprod"
        ExpectedAccount = "967172220355"
    },
    @{
        Name = "Retail Banking Database"
        Path = Join-Path $RepoRoot "workloads\retail-banking\dev\db"
        Profile = "retailprod"
        ExpectedAccount = "967172220355"
    },
    @{
        Name = "Retail Banking Networking"
        Path = Join-Path $RepoRoot "workloads\retail-banking\dev\networking"
        Profile = "retailprod"
        ExpectedAccount = "967172220355"
    },
    @{
        Name = "Root Landing Zone"
        Path = $RepoRoot
        Profile = "default"
        ExpectedAccount = "651015497425"
    }
)

Write-Host "`nDESTROY ALL RETAIL BANKING INFRASTRUCTURE" -ForegroundColor Red
Write-Host "Order: Frontend -> DB -> Networking -> Root" -ForegroundColor Yellow
Write-Host "WARNING: RDS data and root-managed resources may be permanently deleted." -ForegroundColor Red

$confirmation = Read-Host "`nType DESTROY-ALL to continue"
if ($confirmation -cne "DESTROY-ALL") {
    Write-Host "Cancelled. Nothing was destroyed."
    exit 1
}

foreach ($Target in $Targets) {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host $Target.Name -ForegroundColor Cyan
    Write-Host $Target.Path
    Write-Host "========================================" -ForegroundColor Cyan

    if (-not (Test-Path -LiteralPath $Target.Path -PathType Container)) {
        throw "Folder not found: $($Target.Path)"
    }

    Push-Location $Target.Path
    try {
        # Verify AWS account.
        $accountOutput = & aws --profile $Target.Profile sts get-caller-identity --query Account --output text
        if ($LASTEXITCODE -ne 0) {
            throw "AWS identity check failed for $($Target.Name)."
        }

        $account = "$accountOutput".Trim()
        if ($account -ne $Target.ExpectedAccount) {
            throw "Wrong AWS account. Expected $($Target.ExpectedAccount), got $account."
        }

        Write-Host "AWS account verified: $account" -ForegroundColor Green

        & terraform init -input=false
        if ($LASTEXITCODE -ne 0) {
            throw "terraform init failed for $($Target.Name)."
        }

        $state = & terraform state list
        if ($LASTEXITCODE -ne 0) {
            throw "Unable to read Terraform state. Stopping."
        }

        $resources = @($state | Where-Object { "$_".Trim() -ne "" })
        if ($resources.Count -eq 0) {
            Write-Host "State is empty; skipping this root." -ForegroundColor Yellow
            continue
        }

        Write-Host "`nTracked resources: $($resources.Count)" -ForegroundColor Yellow
        $resources | ForEach-Object { Write-Host "  $_" }

        # Use an absolute plan path and pass -out as one argument.
        $planFile = Join-Path $Target.Path ".destroy-review.tfplan"

        if (Test-Path -LiteralPath $planFile) {
            Remove-Item -LiteralPath $planFile -Force
        }

        & terraform plan -destroy -input=false "-out=$planFile"
        if ($LASTEXITCODE -ne 0) {
            throw "Destroy plan failed for $($Target.Name)."
        }

        if (-not (Test-Path -LiteralPath $planFile -PathType Leaf)) {
            throw "Terraform reported success, but the plan file is missing: $planFile"
        }

        Write-Host "`nVerified plan file: $planFile" -ForegroundColor Green

        $approval = Read-Host "Review the plan. Type YES to destroy $($Target.Name)"
        if ($approval -cne "YES") {
            Remove-Item -LiteralPath $planFile -Force -ErrorAction SilentlyContinue
            throw "Destruction declined for $($Target.Name). Stopping."
        }

        if (-not (Test-Path -LiteralPath $planFile -PathType Leaf)) {
            throw "Plan file disappeared. Refusing to apply: $planFile"
        }

        & terraform apply -input=false "$planFile"
        if ($LASTEXITCODE -ne 0) {
            throw "Destroy apply failed for $($Target.Name). Stopping."
        }

        Remove-Item -LiteralPath $planFile -Force -ErrorAction SilentlyContinue
        Write-Host "$($Target.Name) destroyed successfully." -ForegroundColor Green
    }
    finally {
        Pop-Location
    }
}

Write-Host "`nAll four Terraform roots processed." -ForegroundColor Green
Write-Host "Check AWS for resources not tracked by Terraform state." -ForegroundColor Yellow
