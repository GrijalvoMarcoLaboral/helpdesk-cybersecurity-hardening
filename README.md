# Laboratorio de Ciberseguridad: Análisis de Logs y Mitigación para Mesa de Ayuda

Repositorio dedicado a herramientas de soporte técnico preventivo y detección de incidentes de seguridad en primer nivel (Help Desk).

## Herramientas incluidas:
1. **Analizador de Logs:** Script que identifica direcciones IP con múltiples inicios de sesión fallidos (Simulación de alertas SOC/Mesa de Ayuda).
2. **Guía de Hardening:** Checklists de configuración segura para sistemas operativos corporativos (Desactivación de puertos vulnerables, políticas de contraseñas).

```markdown
# 🛡️ SIEM/SOC Lite - Analizador de Incidentes de Seguridad

Este repositorio contiene un script en Bash automatizado y optimizado para el análisis de archivos de log de autenticación (`auth.log`). Está diseñado para entornos de seguridad (SOC) con el fin de detectar ataques de fuerza bruta por SSH, identificar direcciones IP sospechosas que superan un umbral crítico y sugerir acciones inmediatas de mitigación.

## 🚀 Código del Script

Guarda el siguiente código en un archivo llamado `security_analyzer.sh`:

```bash
#!/bin/bash

# Ruta simulada del archivo de log de autenticación
AUTH_LOG="./auth_simulated.log"
THRESHOLD=3

# Creación de datos de prueba si el archivo no existe (Optimizado con bloques para SC2129)
if [ ! -f "$AUTH_LOG" ]; then
    echo "Creating simulated auth log for testing..."
    {
        echo "$(date '+%b %d %H:%M:%S') server1 sshd[1024]: Failed password for invalid user admin from 192.168.1.50 port 54321 ssh2"
        echo "$(date '+%b %d %H:%M:%S') server1 sshd[1024]: Failed password for invalid user admin from 192.168.1.50 port 54322 ssh2"
        echo "$(date '+%b %d %H:%M:%S') server1 sshd[1024]: Failed password for invalid user admin from 192.168.1.50 port 54323 ssh2"
        echo "$(date '+%b %d %H:%M:%S') server1 sshd[1025]: Failed password for root from 203.0.113.5 port 49152 ssh2"
    } > "$AUTH_LOG"
fi

echo "=== ANALIZADOR DE INCIDENTES DE SEGURIDAD ==="
echo "Buscando direcciones IP con más de $THRESHOLD intentos fallidos..."
echo "------------------------------------------------"

# Extracción de IPs con intentos fallidos y filtrado por umbral (Corregido con read -r para SC2162)
awk '/Failed password/ {for(i=1;i<=NF;i++) if($i=="from") print $(i+1)}' "$AUTH_LOG" | \
sort | uniq -c | while read -r count ip; do
    if [ "$count" -ge "$THRESHOLD" ]; then
        echo "[ALERTA SOC] La IP $ip registra $count intentos fallidos de inicio de sesión."
        echo "Acción recomendada: Bloqueo preventivo en Firewall y escalado a Nivel 2."
        echo "------------------------------------------------"
    fi
done

```

---

## 🛠️ Cómo Ejecutar la Demostración

1. **Dar permisos de ejecución** al script:
```bash
chmod +x security_analyzer.sh

```


2. **Ejecutar el analizador**:
```bash
./security_analyzer.sh

```



---

## 📈 Demostración de Salida en Terminal

Se utilizan estructuras de tablas estáticas para garantizar la visualización de alto contraste con fondo oscuro independientemente del tema activo del usuario en GitHub:

```text
=== ANALIZADOR DE INCIDENTES DE SEGURIDAD ===
Buscando direcciones IP con más de 3 intentos fallidos...
------------------------------------------------
[ALERTA SOC] La IP 192.168.1.50 registra 3 intentos fallidos de inicio de sesión.
Acción recomendada: Bloqueo preventivo en Firewall y escalado a Nivel 2.
------------------------------------------------

```

> 💡 **Nota del Analizador:** La IP maliciosa simulada `192.168.1.50` genera la alerta de inmediato por alcanzar el umbral exacto de 3 intentos. La IP externa `203.0.113.5` es ignorada de forma correcta por el script al poseer únicamente un evento de fallo.

---

## 🐳 Buenas Prácticas y Correcciones ShellCheck

* **Procesamiento Seguro de Cadenas (`SC2162`):** Implementación del parámetro `-r` en el comando `while read -r count ip`. Esto evita que Bash interprete caracteres de escape o barras invertidas (`\`) inesperadas dentro de cadenas complejas de texto o logs.
* **Optimización de Entrada/Salida (`SC2129`):** Agrupación del bloque de creación de logs mediante el constructor `{ cmd1; cmd2; } > archivo`. El sistema abre el descriptor de archivos una sola vez para volcar todas las líneas simuladas en lugar de generar operaciones de apertura/cierre repetitivas.
* **Entorno Seguro de Pruebas:** Se configuraron rutas locales (`./auth_simulated.log`) omitiendo la ruta de producción (`/var/log/auth.log`) para asegurar la compatibilidad y portabilidad de la demo sin requerir privilegios administrativos (`sudo`).

```

```
