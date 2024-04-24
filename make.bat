@echo off
goto:$Main

:Command
setlocal EnableDelayedExpansion
    set "_command=%*"
    set "_command=!_command:   = !"
    set "_command=!_command:  = !"
    echo ##[cmd] !_command!
    call !_command!
exit /b %errorlevel%

:CreateVirtualEnvironment
    if not exist "%~dp0.venv\Scripts\activate.bat" goto:$CreateVirtualEnvironment
    if not exist "%~dp0.venv\Scripts\pip3.exe" goto:$CreateVirtualEnvironment
    goto:$CreateVirtualEnvironmentDone

    :$CreateVirtualEnvironment
        call :Command rmdir /s /q "%~dp0.venv"  >nul 2>&1
        call :Command py -3 -m venv "%~dp0.venv"
        goto:$CreateVirtualEnvironmentDone

    :$CreateVirtualEnvironmentDone
exit /b 0

:BuildDocumentation
    call :Command python "docs\build_autodoc_files.py"
    call :Command sphinx-build -w warnings.txt -E -b html .\docs .\html_docs 1>sphinx_build_log.txt 2>&1
    call :Command sphinx-build -w warnings.txt -E -b latex .\docs .\pdf_docs 1>sphinx_build_log.txt 2>&1
exit /b %errorlevel%

:CreateBackup
setlocal EnableDelayedExpansion
    set "_version=%~1"
    if "%~1"=="" set "_version=0"

    set "_previous_path=previousReleases\%_version%"

    if not exist "%_previous_path%" call :Command md "%_previous_path%"
    if not exist "%_previous_path%" goto:$CreateBackupFolderNotCreated

    md "%_previous_path%\DlgCheck2"
    if not exist %_previous_path% goto:$CreateBackupFolderTwoNotCreated

    copy *.py "%_previous_path%"
    copy dlgCheck2 "%_previous_path%\DlgCheck2"

    goto:$CreateBackupFinished

    :$CreateBackupFolderNotCreated
        echo.
        echo [WARNING] Could not create the folder "%_previous_path%"
        echo.
        goto:$CreateBackupFinished

    :$CreateBackupFolderTwoNotCreated
        echo.
        echo [WARNING] Could not create the folder "%_previous_path%\DlgCheck2"
        echo.
        goto:$CreateBackupFinished

    :$CreateBackupFinished
exit /b %errorlevel%

:$Main
setlocal EnableExtensions
    set "_action=%~1"

    call :CreateVirtualEnvironment
    if exist "%~dp0.venv\Scripts\activate.bat" call :Command "%~dp0.venv\Scripts\activate.bat"

    cd /d "%~dp0"
    if "%_action%"=="backup" goto:$MainBackup
    if "%_action%"=="docs" goto:$MainDocs
    echo No action specified. Defaulting to generate documentation and create a backup.
    call :BuildDocumentation
    call :CreateBackup %*
    goto:$MainDocs

    :$MainDocs
        call :BuildDocumentation
        goto:$MainDone

    :$MainBackup
        call :CreateBackup %*
        goto:$MainDone

    :$MainDone
        echo Finished 'make' script for 'pywinauto' library.
endlocal & exit /b %errorlevel%
