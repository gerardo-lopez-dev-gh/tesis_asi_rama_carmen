# Etapa 1: Construcción del binario
FROM python:3.10-slim AS builder

# Instalación de herramientas necesarias para construir el binario
RUN apt-get update && apt-get install -y gcc libpq-dev && rm -rf /var/lib/apt/lists/*

# Establecer el directorio de trabajo para la etapa de construcción
WORKDIR /build

# Mostrar el directorio actual (depuración)
RUN pwd

# Copiar los archivos necesarios al contenedor
COPY requirements.txt ./  
RUN pwd && ls -la  # Mostrar contenido después de copiar requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install pyinstaller

# Copiar el código fuente
COPY . .  

# Mostrar el contenido del directorio después de copiar el código
RUN pwd && ls -la

# Construir el binario con PyInstaller
RUN pyinstaller --onefile index.py
RUN pwd && ls -la /build/dist  # Verificar que el binario se haya creado

# Etapa 2: Imagen final para ejecución
FROM alpine:latest

# Crear un directorio de trabajo
WORKDIR /app

# Mostrar el directorio actual (depuración)
RUN pwd

# Copiar el binario generado en la etapa de construcción
COPY --from=builder /build/dist/index /app/index  # Asegúrate de copiarlo en /app/index

# Mostrar el contenido del directorio después de copiar el binario
RUN pwd && ls -la

# Exponer el puerto en el que corre la aplicación
EXPOSE 5000

# Ejecutar el binario
CMD ["./index"]
