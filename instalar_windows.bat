@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
title Traduccion al espanol - Subterrain: Mines of Titan

echo === Traduccion al espanol - Subterrain: Mines of Titan ===
echo.

set "BUNDLE_SRC=%~dp0archivos\localization_assets_localization.bundle"
set "BUNDLE_REL=Subterrain Mines of Titan_Data\StreamingAssets\aa\StandaloneWindows64\localization_assets_localization.bundle"

:: Buscar Steam
set "STEAM="
for /f "tokens=2*" %%a in ('reg query "HKCU\Software\Valve\Steam" /v SteamPath 2^>nul') do set "STEAM=%%b"

if not defined STEAM (
    echo No se encontro Steam automaticamente.
    echo.
    set /p "RUTA=Introduce la ruta completa a la carpeta del juego: "
    if not exist "!RUTA!" (
        echo ERROR: La ruta no existe.
        pause
        exit /b 1
    )
    set "GAME_DIR=!RUTA!"
) else (
    set "GAME_DIR=!STEAM!\steamapps\common\Subterrain Mines of Titan"
)

if not exist "!GAME_DIR!" (
    echo No se encontro el juego en: !GAME_DIR!
    echo.
    set /p "GAME_DIR=Introduce la ruta completa a la carpeta del juego: "
)

set "BUNDLE_DST=!GAME_DIR!\!BUNDLE_REL!"

if not exist "!BUNDLE_DST!" (
    echo ERROR: No se encontro el bundle en: !BUNDLE_DST!
    echo Seguro que es la carpeta correcta del juego?
    pause
    exit /b 1
)

:: Backup
if not exist "!BUNDLE_DST!.bak" (
    echo Creando copia de seguridad...
    copy "!BUNDLE_DST!" "!BUNDLE_DST!.bak" >nul
) else (
    echo Ya existe una copia de seguridad (.bak).
)

:: Instalar
echo Instalando traduccion...
copy "!BUNDLE_SRC!" "!BUNDLE_DST!" >nul
echo.
echo Traduccion instalada correctamente.
echo El juego ahora cargara en espanol.
pause
endlocal
