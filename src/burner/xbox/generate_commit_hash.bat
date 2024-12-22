@echo off
setlocal
set git_hash=
for /f "delims=" %%i in ('git rev-parse --short HEAD') do set git_hash=%%i
echo #define GIT_COMMIT_HASH "%git_hash%" > commit_hash.h
endlocal