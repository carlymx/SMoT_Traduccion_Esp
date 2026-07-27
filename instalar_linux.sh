#!/bin/bash
# Instalador de la traducción al español para Subterrain: Mines of Titan
# Ejecutar desde la raíz de este repositorio

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUNDLE_SRC="$SCRIPT_DIR/archivos/localization_assets_localization.bundle"
BUNDLE_DST_REL="Subterrain Mines of Titan_Data/StreamingAssets/aa/StandaloneWindows64/localization_assets_localization.bundle"

echo "=== Traducción al español — Subterrain: Mines of Titan ==="
echo ""

# Buscar la carpeta del juego
GAME_DIRS=(
    "$HOME/.local/share/Steam/steamapps/common/Subterrain Mines of Titan"
    "$HOME/.steam/steam/steamapps/common/Subterrain Mines of Titan"
    "/run/media/mmcblk0p1/steamapps/common/Subterrain Mines of Titan"
    "$HOME/Games/Heroic/Subterrain Mines of Titan"
    "$HOME/.wine/drive_c/Program Files (x86)/Steam/steamapps/common/Subterrain Mines of Titan"
)

FOUND=""
for dir in "${GAME_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        FOUND="$dir"
        break
    fi
done

if [ -z "$FOUND" ]; then
    echo "No se encontró la instalación del juego automáticamente."
    echo "Introduce la ruta completa a la carpeta del juego:"
    read -r FOUND
    if [ ! -d "$FOUND" ]; then
        echo "ERROR: La ruta no existe."
        exit 1
    fi
fi

echo "Juego encontrado en: $FOUND"
BUNDLE_DST="$FOUND/$BUNDLE_DST_REL"

if [ ! -f "$BUNDLE_DST" ]; then
    echo "ERROR: No se encontró el bundle en: $BUNDLE_DST"
    echo "¿Seguro que es la carpeta correcta del juego?"
    exit 1
fi

# Backup
if [ ! -f "$BUNDLE_DST.bak" ]; then
    echo "Creando copia de seguridad..."
    cp "$BUNDLE_DST" "$BUNDLE_DST.bak"
else
    echo "Ya existe una copia de seguridad (.bak)."
fi

# Instalar
echo "Instalando traducción..."
cp "$BUNDLE_SRC" "$BUNDLE_DST"
echo ""
echo "¡Traducción instalada correctamente!"
echo "El juego ahora cargará en español."
