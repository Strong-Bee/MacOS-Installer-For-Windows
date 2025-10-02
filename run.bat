@echo off
title VirtualBox macOS Fix Script
echo ============================================
echo   VirtualBox macOS Fix Script (Interactive)
echo ============================================

:: --- Input VM name
set /p VMNAME=Masukkan nama VirtualBox VM: 
if "%VMNAME%"=="" (
  echo Nama VM kosong. Keluar.
  pause
  exit /b 1
)

echo.
echo Menggunakan VM: "%VMNAME%"
echo.

:: --- Matikan Hyper-V (butuh admin)
echo [*] Mematikan Hyper-V (jika aktif)...
bcdedit /set hypervisorlaunchtype off

:: --- CPU Settings
echo [*] Mengatur CPUID...
VBoxManage modifyvm "%VMNAME%" --cpuidset 00000001 000106e5 00100800 0098e3fd bfebfbff

echo.

:: --- Pilih tipe Mac (SMBIOS)
echo Pilih tipe Mac (SMBIOS) yang ingin dispoof:
echo [1] iMac20,1    (Direkomendasikan untuk Monterey/Ventura)
echo [2] iMac19,3    (Versi lama — kompatibel)
echo [3] iMacPro1,1  (iMac Pro / workstation)
echo [4] MacBookPro16,3 (MacBook Pro modern)
set /p MACCHOICE=Masukkan pilihan [1-4] (default 1): 

if "%MACCHOICE%"=="2" (
  set DMI_PRODUCT=iMac19,3
  set DMI_BOARD=Iloveapple
) else if "%MACCHOICE%"=="3" (
  set DMI_PRODUCT=iMacPro1,1
  set DMI_BOARD=Iloveapple
) else if "%MACCHOICE%"=="4" (
  set DMI_PRODUCT=MacBookPro16,3
  set DMI_BOARD=MacBookPro
) else (
  set DMI_PRODUCT=iMac20,1
  set DMI_BOARD=Iloveapple
)

echo Dipilih: %DMI_PRODUCT%
echo.

:: --- Terapkan EFI & SMBIOS settings
echo [*] Menerapkan EFI/SMBIOS...
VBoxManage setextradata "%VMNAME%" "VBoxInternal/Devices/efi/0/Config/DmiSystemProduct" "%DMI_PRODUCT%"
VBoxManage setextradata "%VMNAME%" "VBoxInternal/Devices/efi/0/Config/DmiSystemVersion" "1.0"
VBoxManage setextradata "%VMNAME%" "VBoxInternal/Devices/efi/0/Config/DmiBoardProduct" "%DMI_BOARD%"

:: --- SMC Settings (gunakan GetKeyFromRealSMC = 0 untuk Windows host)
echo [*] Menerapkan SMC settings...
VBoxManage setextradata "%VMNAME%" "VBoxInternal/Devices/smc/0/Config/DeviceKey" "ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
VBoxManage setextradata "%VMNAME%" "VBoxInternal/Devices/smc/0/Config/GetKeyFromRealSMC" 0

:: --- Timer fix
echo [*] Menerapkan timer fix...
VBoxManage setextradata "%VMNAME%" "VBoxInternal/TM/TSCMode" "RealTSCOffset"

echo.

:: --- Pilih resolusi layar
echo Pilih resolusi layar untuk VM "%VMNAME%":
echo [1] 1280x720  (HD)
echo [2] 1920x1080 (Full HD)
echo [3] 2560x1440 (2K QHD)
echo [4] 3840x2160 (4K UHD)
set /p RESCHOICE=Masukkan pilihan [1-4] (default 2): 

if "%RESCHOICE%"=="1" set RES=1280x720
if "%RESCHOICE%"=="3" set RES=2560x1440
if "%RESCHOICE%"=="4" set RES=3840x2160
if "%RESCHOICE%"=="" set RES=1920x1080
if not defined RES set RES=1920x1080

echo [*] Menetapkan resolusi %RES%...
VBoxManage setextradata "%VMNAME%" "VBoxInternal2/EfiGraphicsResolution" "%RES%"

echo.
echo ============================================
echo Selesai — semua setting diterapkan ke VM "%VMNAME%".
echo - Pastikan VM dimatikan saat mengaplikasikan perubahan.
echo - Restart Windows setelah script ini selesai (disarankan).
echo - Boot VM lewat OpenCore.iso untuk proses install/boot macOS.
echo ============================================
pause
