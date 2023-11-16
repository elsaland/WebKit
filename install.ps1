# powershell -executionpolicy bypass -File .\install.ps1

$ICU_SOURCE_URL = "https://github.com/unicode-org/icu/releases/download/release-73-2/icu4c-73_2-src.tgz"
$ICU_SHARED_URL = "https://github.com/unicode-org/icu/releases/download/release-73-2/icu4c-73_2-Win64-MSVC2019.zip"

$WebKitBuild = "WebKitBuild"

$ICU_SHARED_ROOT = Join-Path $WebKitBuild "icu"
$ICU_SHARED_LIBRARY = Join-Path $ICU_SHARED_ROOT "lib64"
$ICU_SHARED_INCLUDE_DIR = Join-Path $ICU_SHARED_ROOT "include"

Write-Host "Downloading shared library ICU from ${ICU_SHARED_URL}"
$icuZipPath = Join-Path $WebKitBuild "icu.zip"

if (!(Test-Path -Path $icuZipPath)) {
    Invoke-WebRequest -Uri $ICU_SHARED_URL -OutFile $icuZipPath
    $null = New-Item -ItemType Directory -Path $ICU_SHARED_ROOT -Force
    $null = Expand-Archive $icuZipPath $ICU_SHARED_ROOT
    Get-ChildItem $ICU_SHARED_ROOT | Get-ChildItem
    Expand-Archive (Get-ChildItem $ICU_SHARED_ROOT | Get-ChildItem).FullName $ICU_SHARED_ROOT
}

Write-Host ":: Configuring WebKit"

# cmake -S . -B WebKitBuild -DPORT="JSCOnly" -DUSE_SYSTEM_MALLOC=ON -DENABLE_STATIC_JSC=ON -DUSE_THIN_ARCHIVES=OFF -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang "-DICU_ROOT=${ICU_SHARED_ROOT}" "-DICU_LIBRARY=${ICU_SHARED_LIBRARY}" "-DICU_INCLUDE_DIR=${ICU_SHARED_INCLUDE_DIR}" -G Ninja
cmake `
    "-DICU_ROOT=${ICU_SHARED_ROOT}" `
    "-DICU_LIBRARY=${ICU_SHARED_LIBRARY}" `
    "-DICU_INCLUDE_DIR=${ICU_SHARED_INCLUDE_DIR}" `
    -DPORT="JSCOnly" `
    -DENABLE_STATIC_JSC=ON `
    -DENABLE_SINGLE_THREADED_VM_ENTRY_SCOPE=ON `
    -DALLOW_LINE_AND_COLUMN_NUMBER_IN_BUILTINS=ON `
    -DCMAKE_BUILD_TYPE=Release `
    -DUSE_THIN_ARCHIVES=OFF `
    -DENABLE_DFG_JIT=ON `
    -DCMAKE_C_COMPILER=clang-cl `
    -DCMAKE_CXX_COMPILER=clang-cl `
    -DENABLE_FTL_JIT=OFF `
    -DENABLE_WEBASSEMBLY=OFF `
    -S . `
    -B WebKitBuild `
    -DUSE_SYSTEM_MALLOC=ON

Write-Host ":: Building WebKit"
cmake --build WebKitBuild --config Release --target jsc