@echo off
setlocal EnableDelayedExpansion

@call :GetVCInstallDir

@call "%VCINSTALLDIR%\bin\amd64\vcvars64.bat"

mkdir ..\generated
cd ..\scripts
echo running perl scripts
perl cave_sprite_func.pl -o ../generated/cave_sprite_func.h
perl license2rtf.pl -o ../generated/license.rtf ../../license.txt
perl cave_tile_func.pl -o ../generated/cave_tile_func.h
perl neo_sprite_func.pl -o ../generated/neo_sprite_func.h
perl psikyo_tile_func.pl -o ../generated/psikyo_tile_func.h
perl toa_gp9001_func.pl -o ../generated/toa_gp9001_func.h
SET DRVS=
@for /d %%i in (../../burn/drv/*) do (@SET DRVS=!DRVS! ../../burn/drv/%%~nxi)
perl gamelist.pl -o ../generated/driverlist.h -l ../../gamelist.txt %DRVS%
echo building buildinfo
"%VCINSTALLDIR%\bin\amd64\cl" build_details.cpp
build_details > ../generated/build_details.h
del build_details.exe
del build_details.obj
cd ../../

echo building ctv
cd burn/drv/capcom
"%VCINSTALLDIR%\bin\amd64\cl" ctv_make.cpp
ctv_make > ../../../dep/generated/ctv.h
del ctv_make.exe
del ctv_make.obj
cd ../../../

#temporarily disable m68k generation...
#echo building 68k generator
#cd cpu/m68k
#"%VCINSTALLDIR%\bin\amd64\cl" /DINLINE="__inline static" m68kmake.c
#m68kmake . m68k_in.c
#del m68kmake.exe
#del m68kmake.obj
#cd ../../

echo building pgm_sprite_create
cd burn/drv/pgm
"%VCINSTALLDIR%\bin\amd64\cl" /DINLINE="__inline static" pgm_sprite_create.cpp
pgm_sprite_create > ../../../dep/generated/pgm_sprite.h
del pgm_sprite_create.exe
del pgm_sprite_create.obj
cd ../../../

cd dep/vs2010

:GetVCInstallDir
@set VCINSTALLDIR=
@call :GetVCInstallDirHelper32 HKLM > nul 2>&1
@if errorlevel 1 call :GetVCInstallDirHelper32 HKCU > nul 2>&1
@if errorlevel 1 call :GetVCInstallDirHelper64  HKLM > nul 2>&1
@if errorlevel 1 call :GetVCInstallDirHelper64  HKCU > nul 2>&1
@exit /B 0

:GetVCInstallDirHelper32
@for /F "tokens=1,2*" %%i in ('reg query "%1\SOFTWARE\Microsoft\VisualStudio\SxS\VC7" /v "10.0"') DO (
    @if "%%i"=="10.0" (
        @SET VCINSTALLDIR=%%k
    )
)
@if "%VCINSTALLDIR%"=="" exit /B 1
@exit /B 0

:GetVCInstallDirHelper64
@for /F "tokens=1,2*" %%i in ('reg query "%1\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\SxS\VC7" /v "10.0"') DO (
    @if "%%i"=="10.0" (
        @SET VCINSTALLDIR=%%k
    )
)
@if "%VCINSTALLDIR%"=="" exit /B 1
@if "%VCINSTALLDIR%"=="" exit /B 1
@exit /B 0
