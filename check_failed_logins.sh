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
