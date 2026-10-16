
param(
    [switch]$AutoApprove
)

$ErrorActionPreference = "Stop"

# ---------------------------------------------------------
# Retail Banking infrastructure deployment
# ---------------------------------------------------------

$RepoRoot = "C:\Users\rajee\Documents\AWS\IaC-AWS\bank-aws-terraform"

$Targets = @(
    @{
        Name           = "Root Landing Zone"
        Path           = $RepoRoot
        Profile        = "default"
        ExpectedAccount = "651015497425"
    },
    @{
        Name           = "Retail Banking Networking"
        Path           = Join-Path $RepoRoot "workloads\retail-banking\dev\networking"
        Profile        = "retailprod"
        ExpectedAccount = "967172220355"
    },
    @{
        Name           = "Retail Banking Database"
        Path           = Join-Path $RepoRoot "workloads\retail-banking\dev\db"
        Profile        = "retailprod"
        ExpectedAccount = "967172220355"
    },
    @{
        Name           = "Retail Banking Frontend"
        Path           = Join-Path $RepoRoot "workloads\retail-banking\dev\frontend"
        Profile        = "retailprod"
        ExpectedAccount = "967172220355"
    }
)

function Invoke-CheckedCommand {
    param(
        [Parameter(Mandatory)]
        [string]$Description,

        [Parameter(Mandatory)]
        [scriptblock]$Command
    )

    Write-Host "`n>>> $Description" -ForegroundColor Cyan

    & $Command

    if ($LASTEXITCODE -ne 0) {
        throw "$Description failed with exit code $LASTEXITCODE."
    }
}

function Invoke-TerraformTarget {
    param(
        [Parameter(Mandatory)]
        [hashtable]$Target
    )

    Write-Host "`n========================================" -ForegroundColor Yellow
    Write-Host $Target.Name -ForegroundColor Yellow
    Write-Host $Target.Path
    Write-Host "========================================" -ForegroundColor Yellow

    if (-not (Test-Path $Target.Path -PathType Container)) {
        throw "Terraform directory does not exist: $($Target.Path)"
    }

    $TerraformFiles = Get-ChildItem $Target.Path -Filter "*.tf" -File

    if (-not $TerraformFiles) {
        throw "No .tf files found in $($Target.Path)"
    }

    Push-Location $Target.Path

    try {
        # Verify AWS identity before touching this state.
        Write-Host "`nChecking AWS account..." -ForegroundColor Cyan

        $IdentityArgs = @(
            "--query", "Account",
            "--output", "text"
        )

        if ($Target.Profile -ne "default") {
            $IdentityArgs = @("--profile", $Target.Profile) + $IdentityArgs
        }

        $ActualAccount = & aws sts get-caller-identity @IdentityArgs

        if ($LASTEXITCODE -ne 0) {
            throw "Unable to verify AWS identity for profile $($Target.Profile)."
        }

        $ActualAccount = "$ActualAccount".Trim()

        Write-Host "Profile: $($Target.Profile)"
        Write-Host "Account: $ActualAccount"

        if ($ActualAccount -ne $Target.ExpectedAccount) {
            throw "Wrong AWS account. Expected $($Target.ExpectedAccount), got $ActualAccount. Stopping."
        }

        # Format Terraform files.
        Invoke-CheckedCommand "Terraform format" {
            terraform fmt -recursive
        }

        # Initialize without automatically upgrading provider versions.
        Invoke-CheckedCommand "Terraform init" {
            terraform init -input=false
        }

        # Validate configuration.
        Invoke-CheckedCommand "Terraform validate" {
            terraform validate
        }

        # Create a saved plan for this specific Terraform root.
        $PlanFile = Join-Path $Target.Path ".deployment.tfplan"

        Invoke-CheckedCommand "Terraform plan" {
            terraform plan -input=false "-out=$PlanFile"
        }

        # Require explicit confirmation unless -AutoApprove was supplied.
        if (-not $AutoApprove) {
            $Answer = Read-Host "Apply this plan for '$($Target.Name)'? Type YES to continue"

            if ($Answer -cne "YES") {
                Remove-Item $PlanFile -Force -ErrorAction SilentlyContinue
                throw "Deployment cancelled by user."
            }
        }

        # Applying a saved plan applies exactly the reviewed plan.
        Invoke-CheckedCommand "Terraform apply" {
            terraform apply -input=false $PlanFile
        }

        Remove-Item $PlanFile -Force -ErrorAction SilentlyContinue

        Write-Host "`n$($Target.Name) completed successfully." -ForegroundColor Green
    }
    finally {
        Pop-Location
    }
}

# Check required tools.
foreach ($Tool in @("terraform", "aws")) {
    if (-not (Get-Command $Tool -ErrorAction SilentlyContinue)) {
        throw "Required command '$Tool' was not found in PATH."
    }
}

Write-Host "`nRetail Banking deployment starting." -ForegroundColor Green

if ($AutoApprove) {
    Write-Host "WARNING: Apply confirmations are disabled." -ForegroundColor Red
}

try {
    foreach ($Target in $Targets) {
        Invoke-TerraformTarget -Target $Target
    }

    Write-Host "`nAll Terraform roots completed successfully." -ForegroundColor Green
}
catch {
    Write-Host "`nDEPLOYMENT STOPPED: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Fix the error before rerunning the script." -ForegroundColor Yellow
    exit 1
}
