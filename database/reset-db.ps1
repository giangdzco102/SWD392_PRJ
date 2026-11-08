# Rebuild the AutoCare database from scratch: drop everything, create schema, load sample data.
# Usage (PowerShell):  .\reset-db.ps1                 (defaults: user autocare / autocare123, db autocare)
param(
  [string]$PsqlPath = "C:\Program Files\PostgreSQL\18\bin\psql.exe",
  [string]$DbHost = "localhost",
  [string]$User = "autocare",
  [string]$Password = "autocare123",
  [string]$Database = "autocare"
)
$ErrorActionPreference = "Stop"
$env:PGPASSWORD = $Password
$env:PGCLIENTENCODING = "UTF8"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
& $PsqlPath -U $User -h $DbHost -d $Database -q -v ON_ERROR_STOP=1 -c "SET client_min_messages TO warning; DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
& $PsqlPath -U $User -h $DbHost -d $Database -q -v ON_ERROR_STOP=1 -f "$here\01_schema.sql" | Out-Null
& $PsqlPath -U $User -h $DbHost -d $Database -q -v ON_ERROR_STOP=1 -f "$here\02_seed.sql" | Out-Null
Write-Host "Database '$Database' rebuilt with sample data."
