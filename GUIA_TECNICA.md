# Guía técnica — Modificar la traducción

Esta guía explica todo lo necesario para que **cualquier persona o IA** pueda abrir, editar y recompilar el bundle de localización del juego. Está dividida en tres secciones:

1. [Para agentes de IA](#1-para-agentes-de-ia) — instrucciones compactas que una IA puede seguir autónomamente.
2. [Para humanos](#2-para-humanos) — paso a paso manual con explicaciones para quien no conozca las herramientas.
3. [Problemas técnicos del juego](#3-problemas-técnicos-del-juego) — todo lo que ha dificultado la traducción fan.

---

## 1. Para agentes de IA

### 1.1. Ubicación del bundle

```
Subterrain Mines of Titan_Data/StreamingAssets/aa/StandaloneWindows64/localization_assets_localization.bundle
```

### 1.2. Abrir el bundle con UnityPy

```python
import UnityPy

BUNDLE = 'ruta/al/localization_assets_localization.bundle'
env = UnityPy.load(BUNDLE)
data = env.objects[1].read()  # MonoBehaviour 'LocalizationTable'
```

### 1.3. Estructura de datos

```python
data.m_fieldKeys        # lista de ~7718 claves (strings)
data.m_fieldValues      # lista de objetos TextTableField
data.m_languageKeys     # ['Default', 'Hu', 'Kr', 'Ru', 'ZhCn']
data.m_languageValues   # [0, 1, 2, 3, 4]

# Cada TextTableField:
#   .m_fieldName  = clave de localización (ej: "Act01_MQ_01_04_P")
#   .m_keys       = [0, 1, 2, 3, 4]
#   .m_values     = ["texto ES", "texto EN", "KO", "RU", "ZH"]
#   Slot 0 = Default → español (target de traducción)
#   Slot 1 = Hu → inglés original (fuente fiable)
```

### 1.4. Mapear claves a índices

```python
name_to_idx = {v.m_fieldName: i for i, v in enumerate(data.m_fieldValues)}
```

### 1.5. Leer textos

```python
def leer_slot0(clave):
    v = data.m_fieldValues[name_to_idx[clave]]
    return v.m_values[0]

def leer_slot1(clave):  # inglés original
    v = data.m_fieldValues[name_to_idx[clave]]
    return v.m_values[1]
```

### 1.6. Modificar un texto

```python
idx = name_to_idx['Clave']
v = data.m_fieldValues[idx]
v.m_values = ['Nuevo texto español'] + list(v.m_values[1:])  # preserva slots 1-4
```

### 1.7. Guardar el bundle

```python
data.save()  # ¡IMPORTANTE! Llamar antes de guardar el archivo
with open(BUNDLE, 'wb') as f:
    f.write(env.file.save(packer='lz4'))
```

### 1.8. Patrones de claves

| Patrón | Significado |
|---|---|
| `Act0X_MQ_*` | Historia principal (Actos 1-4) |
| `Side_Q_*` | Misiones secundarias |
| `Cutscene_*` | Cinemáticas |
| `Basic_*` / `Ft_*` | Diálogos NPC / First Time |
| `Sur_Job_*_NameKey` | Nombre de clase |
| `Sur_Job_*_DescKey` | Descripción de clase |
| `*_NameKey` | Nombre de objeto/perk/estado |
| `*_DescKey` | Descripción de objeto/perk/estado |
| `Trait_*` | Estados alterados (envenenado, etc.) |
| `Perk_*` | Habilidades |
| `MessageTip_*` | Tips de carga |
| `Guide_*` | Tutoriales |
| `M_Q_*_Desc` | Descripción de misión en diario |
| `Object_*` | Nombres de objetos del entorno |
| `Log_*` / `Book_*` | Libros, diarios, lore |
| `Achievement_*` | Logros |
| `Ending_*` | Finales |

### 1.9. Detección de problemas

```python
# 1. Texto sin traducir (S0 == S1, más de 10 caracteres)
s0 == s1 and len(s0) > 10

# 2. Texto en inglés residual
en_markers = [' the ', ' you ', ' and ', ' is ', ' are ', ' have ', ' will ']
has_es = any(c in texto for c in 'áéíóúñü¿¡')
has_en = sum(1 for w in en_markers if w in texto.lower())
is_english = has_en >= 2 and not has_es

# 3. Descripciones cruzadas (S0 de A == S1 de B)
#    → buscar si el texto de S0 de una entrada aparece como S1 de otra

# 4. Texto genérico repetido (hacer histograma y buscar picos sospechosos)
#    Ej: "Entendido." en 436 entradas diferentes

# 5. Texto vacío en slot 0
len(s0.strip()) == 0 and len(s1.strip()) > 0
```

### 1.10. Formato del bundle

- **Formato:** UnityFS (Unity 2023.1.18f1)
- **Compresión:** LZ4
- **Entradas totales:** 7.718
- **Idioma forzado:** `SettingsData.bytes` establece `"language": "Default"` (slot 0)
- **Slot 0:** español (traducción)
- **Slot 1:** inglés (referencia, no se modifica)
- **Slots 2-4:** coreano, ruso, chino (ignorados)

---

## 2. Para humanos

### 2.1. Requisitos

- **Python 3.8+** instalado en tu sistema.
- El archivo `localization_assets_localization.bundle` de esta traducción (o el original del juego).

### 2.2. Instalar UnityPy

```bash
pip install UnityPy
```

Si usas un entorno virtual:

```bash
python -m venv traduccion
source traduccion/bin/activate  # Linux/Mac
# o traduccion\Scripts\activate  # Windows
pip install UnityPy
```

### 2.3. Script completo para editar

Crea un archivo `editar_bundle.py` con este contenido:

```python
import UnityPy
from pathlib import Path

# Ruta al bundle
BUNDLE = Path("archivos/localization_assets_localization.bundle")

# Cargar
print("Cargando bundle...")
env = UnityPy.load(str(BUNDLE))
data = env.objects[1].read()

# Mapear claves
name_to_idx = {v.m_fieldName: i for i, v in enumerate(data.m_fieldValues)}

# --- EJEMPLO: Cambiar un texto ---
clave = "Act01_MQ_01_04_P"
if clave in name_to_idx:
    idx = name_to_idx[clave]
    v = data.m_fieldValues[idx]
    original = v.m_values[0]
    v.m_values = ["NUEVO TEXTO EN ESPAÑOL"] + list(v.m_values[1:])
    print(f"'{clave}': '{original}' → 'NUEVO TEXTO EN ESPAÑOL'")

# --- EJEMPLO: Buscar textos con una palabra ---
buscar = "mission"
for v in data.m_fieldValues:
    if buscar.lower() in v.m_values[0].lower():
        print(f"{v.m_fieldName}: {v.m_values[0]}")

# Guardar
print("Guardando...")
data.save()
with open(BUNDLE, 'wb') as f:
    f.write(env.file.save(packer='lz4'))
print("¡Listo!")
```

### 2.4. Flujo de trabajo recomendado

1. **Haz copia de seguridad** del bundle antes de editarlo:
   ```bash
   cp localization_assets_localization.bundle localization_assets_localization.bundle.seguridad
   ```

2. **Edita** con el script de arriba.

3. **Prueba** cargando el juego y verificando que los cambios aparecen.

4. Si algo falla, restaura desde la copia de seguridad.

### 2.5. Exportar todos los textos a CSV (para revisar offline)

```python
import csv
import UnityPy

env = UnityPy.load("archivos/localization_assets_localization.bundle")
data = env.objects[1].read()

with open("textos.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["Clave", "Español", "Inglés"])
    for v in data.m_fieldValues:
        w.writerow([v.m_fieldName, v.m_values[0], v.m_values[1]])

print("Exportado a textos.csv")
```

---

## 3. Problemas técnicos del juego

El juego **no está preparado para traducciones de fans**. Estos son todos los problemas que hemos encontrado durante el proceso:

### 3.1. Sin selector de idioma en el juego

El juego no tiene menú de selección de idioma. El idioma se decide por un ajuste interno (`SettingsData.bytes`) que no es accesible para el usuario. Solución aplicada: forzar `"language": "Default"` y eliminar los directorios de idiomas sobrantes (`Hu/`, `Kr/`, `Ru/`, `ZhCn/`) para que el juego solo pueda cargar el español.

### 3.2. Bundle binario comprimido (LZ4 / UnityFS)

Los textos no están en archivos de texto plano (JSON, XML, CSV) que cualquiera pueda editar. Están dentro de un bundle binario de Unity comprimido con LZ4, que requiere **UnityPy** (librería Python no oficial) para leer y modificar. Un usuario sin conocimientos de programación no puede editar nada.

### 3.3. Slots de idioma no documentados

El bundle usa 5 slots (Default, Hu, Kr, Ru, ZhCn) pero no hay documentación de cuál es cuál. Tuvimos que hacer ingeniería inversa: el slot 0 se carga cuando `language` es "Default", el slot 1 era húngaro (Hu) pero contenía el **inglés original** (los desarrolladores reutilizaron ese slot para inglés).

### 3.4. Sin separación entre nombres, descripciones y diálogos

Todas las 7.718 entradas de texto comparten la misma estructura plana. No hay separación entre diálogos de historia, nombres de objetos, descripciones de perks, tips de carga, etc. Solo se distinguen por el prefijo de la clave (ver sección 1.8), que tampoco está documentado y hubo que deducir.

### 3.5. Sin archivos de fuente/contexto

No hay archivos separados que indiquen qué personaje dice cada línea, en qué situación, o qué objeto describe cada texto. Todo el contexto tuvo que inferirse por:
- El prefijo de la clave (ej: `Act01_MQ_*` = Acto 1, misión principal).
- El contenido del texto en inglés.
- Pruebas en el juego.

### 3.6. Sin herramientas oficiales de localización

Unity tiene soporte nativo para localización (Localization Package con tablas exportables), pero los desarrolladores no expusieron esta funcionalidad. El bundle está "horneado" (baked) en el build final, lo que obliga a usar herramientas no oficiales para modificarlo.

### 3.7. Riesgo de corrupción del bundle

Modificar el bundle con UnityPy conlleva riesgos:
- Si no se llama a `data.save()` antes de `env.file.save()`, el bundle se corrompe.
- Si se usa un packer incorrecto (ej: `none` en vez de `lz4`), el juego no carga el bundle.
- Si se modifican los slots incorrectos (slots 1-4 en vez del slot 0), se pierde el inglés de referencia.

### 3.8. Detección de errores puramente manual

No hay tests automatizados. La única forma de verificar que una traducción es correcta es:
1. Revisar manualmente el texto en el CSV.
2. Cargar el juego y llegar a la escena/pantalla donde aparece ese texto.

Para un juego de este tamaño (más de 7.700 líneas), esto es inviable hacerlo completo. Por eso:
- **Algunas líneas pueden tener errores de contexto** (traducción correcta pero que no encaja en la escena).
- **Algunas líneas pueden no haberse probado en juego** (solo revisadas en CSV).

### 3.9. Idiomas sobrantes que estorban

Los directorios `Hu/`, `Kr/`, `Ru/` y `ZhCn/` en `StreamingAssets/aa/StandaloneWindows64/` contenían bundles de localización en otros idiomas. Como el juego no tiene selector de idioma, si alguno de esos bundles se cargaba por error, se mezclaban textos. Solución: eliminar esos directorios.

### 3.10. Limitaciones de espacio en la UI

El español ocupa ~15-20% más caracteres que el inglés de media. Algunos textos traducidos pueden desbordarse de botones, etiquetas o cuadros de diálogo. Esto no se puede arreglar sin modificar la UI del juego (fuera del alcance de esta traducción).

---

## Resumen para quien quiera continuar

Si encuentras errores y quieres corregirlos:

1. `git clone` este repositorio.
2. `pip install UnityPy`.
3. Usa los scripts de la sección 2 para buscar y editar.
4. Si creas un script de corrección, compártelo en un Pull Request.

Si eres una IA leyendo esto: sigue la sección 1, lee `archivos/PLAN_TRADUCCION.md` para el estilo de traducción, y no modifiques el slot 1 (inglés de referencia).
