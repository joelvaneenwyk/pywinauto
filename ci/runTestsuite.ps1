# Credits to:
# https://github.com/originell/jpype/appveyor/runTestsuite.ps1
#
function xslt_transform($xml, $xsl, $run_output) {
    trap [Exception] {
        Write-Host $_.Exception
    }

    $xslt = New-Object System.Xml.Xsl.XslCompiledTransform
    $xslt.Load($xsl)
    $xslt.Transform($xml, $run_output)
}

function upload($file) {
    trap [Exception] {
        Write-Host $_.Exception
    }

    if ($script:IS_APPVEYOR_BUILD) {
        Write-Host 'Uploading: ' $file
        $wc = New-Object 'System.Net.WebClient'
        $wc.UploadFile("https://ci.appveyor.com/api/testresults/xunit/$($script:JOB_ID)", $file)
    }

    $test_report_dir = '.\TestResultsReport'
    mkdir -Force $test_report_dir | Out-Null
    $revid = $($script:REPO_COMMIT).Substring(0, 8)
    $rep_dest = "$test_report_dir\$($script:JOB_ID)-$revid-$($script:PYTHON_VERSION)-$($script:PYTHON_ARCH)-UIA$($env:UIA_SUPPORT)-result.xml"

    Write-Host 'Copying test report to: ' $rep_dest
    Copy-Item $file $rep_dest

    if ($script:IS_APPVEYOR_BUILD) {
        Push-AppveyorArtifact $rep_dest
    }
}

function Get-ScriptDirectory {
    if ($psise) {
        Split-Path $psise.CurrentFile.FullPath
    }
    else {
        $global:PSScriptRoot
    }
}

function run {
    try {
        $script:JOB_ID = 0
        $script:REPO_COMMIT = 'abcdabcdabcdabcd'
        $script:PYTHON_VERSION = '3.11'
        $script:PYTHON_ARCH = 'x64'
        $script:UIA_SUPPORT = ''

        $script:PROJECT_CI_PATH = Get-ScriptDirectory
        $script:BUILD_FOLDER = Split-Path -Parent $script:PROJECT_CI_PATH
        $script:IS_APPVEYOR_BUILD = ($null -ne $env:APPVEYOR_BUILD_FOLDER)

        if ($script:IS_APPVEYOR_BUILD) {
            $script:JOB_ID = $env:APPVEYOR_JOB_ID
            $script:REPO_COMMIT = $env:APPVEYOR_REPO_COMMIT

            $script:PYTHON_VERSION = $env:PYTHON_VERSION
            $script:PYTHON_ARCH = $env:PYTHON_ARCH
            $script:UIA_SUPPORT = $env:UIA_SUPPORT

            $script:BUILD_FOLDER = $env:APPVEYOR_BUILD_FOLDER
        }

        Write-Host $script:BUILD_FOLDER

        Push-Location $script:BUILD_FOLDER

        $stylesheet = './ci/transform_xunit_to_appveyor.xsl'
        $run_input = 'nosetests.xml'
        $run_output = 'transformed.xml'

        #nosetests  --all-modules --with-xunit pywinauto/unittests
        # --traverse-namespace is required for python 3.8 https://stackoverflow.com/q/58556183
        nosetests --nologcapture --traverse-namespace --exclude=testall --with-xunit --with-coverage --cover-html --cover-html-dir=Coverage_report --cover-package=pywinauto --verbosity=3 pywinauto\unittests
        $success = $?
        Write-Host 'result code of nosetests:' $success

        xslt_transform $run_input $stylesheet $run_output

        upload $run_output

        # return exit code of testsuite
        if (-not $success) {
            throw 'testsuite not successful'
        }
    }
    finally {
        Write-Host 'Ended work.'
        Pop-Location
    }
}

run
