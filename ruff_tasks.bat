@echo off

REM Check if an argument is provided
if "%1"=="" (
    echo Usage: ruff_tasks.bat [check|format|all]
    echo Example: ruff_tasks.bat check
    exit /b
)

if "%1"=="check" goto ruff_check
if "%1"=="format" goto ruff_format
if "%1"=="all" goto ruff_all

echo Invalid argument: %1
echo Please use one of the following: check, format, all
exit /b

:ruff_check
    echo Running Ruff check with fix...
    poetry run ruff check --fix
    goto end

:ruff_format
    echo Formatting code with Ruff...
    poetry run ruff format
    goto end

:ruff_all
    echo Running Ruff format and check...
    poetry run ruff format
    poetry run ruff check --fix
    goto end

:end
exit /b
