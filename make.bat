@echo off
goto:$Main

:$Main
setlocal EnableExtensions
    set "_action=%~1"
    if "%_action%"=="backup" goto:$MainBackup

    :$MainDocs
        python docs\build_autodoc_files.py

        sphinx-build -w warnings.txt -E -b html .\docs .\html_docs 1>sphinx_build_log.txt 2>&1
        ::sphinx-build -w warnings.txt -E -b latex .\docs .\pdf_docs 1>sphinx_build_log.txt 2>&1

        goto:$MainDone

    :$MainBackup
        if (%~1)==() goto VersionNotGiven

        md previousReleases\%1

        if not exist previousReleases\%1 goto FolderNotCreated

        md previousReleases\%1\DlgCheck2
        if not exist previousReleases\%1 goto FolderTwoNotCreated

        copy *.py previousReleases\%1
        copy dlgCheck2 previousReleases\%1\DlgCheck2


        goto finished

        :FolderNotCreated
        echo.
        echo Could not create the folder "previousReleases\%1"
        echo.
        goto finished

        :FolderTwoNotCreated
        echo.
        echo Could not create the folder "previousReleases\%1\DlgCheck2"
        echo.
        goto finished


        VersionNotGiven
        echo.
        echo please specify the version of the backup
        echo.
        goto finished

        :finished
        goto:$MainDone

    :$MainDone
exit /b %errorlevel%
