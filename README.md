# Onda 🎵 — Reproductor de Música Local para Android

Onda es un reproductor de música local para Android moderno, rápido, adaptativo y libre de anuncios. Diseñado para ofrecer una experiencia musical premium con una interfaz elegante y controles fluidos respetando tu privacidad.

---

## 🌟 Características Principales

*   **Identidad Visual Moderna:** Icono neon minimalista y diseño elegante con estética de cristal (glassmorphism).
*   **Temas Personalizados (Persistentes):** Selector rápido de fondos con 4 presets premium (*Espacio Profundo, Onda Púrpura, Aurora Rosa, Océano Eléctrico*). El tema seleccionado se guarda automáticamente en el dispositivo.
*   **Controles en Pantalla de Bloqueo:** Integración nativa con los controles multimedia de Android (barra de notificaciones, pantalla de bloqueo y dispositivos vinculados).
*   **Diseño 100% Adaptativo:** La interfaz se adapta automáticamente a cualquier relación de aspecto de pantalla, detectando y respetando los márgenes del bisel y la barra de navegación del sistema (gestual o clásica por botones).
*   **Mostrar en Carpeta Inteligente:** Abre el gestor de archivos nativo de Android enfocando y resaltando directamente la canción seleccionada (compatible con DocumentsUI / Files de Google).
*   **Barrido y Sincronización Manual:** Función para forzar la detección e indexación instantánea de archivos de audio recién descargados o recibidos (por ejemplo, audios de WhatsApp o descargas de Google Drive).

---

## 🚀 Instrucciones de Compilación y Ejecución

Si deseas compilar la aplicación localmente en tu entorno de desarrollo, sigue estos pasos:

### Prerrequisitos
*   Tener instalado el SDK de Flutter.
*   Tener configurado el SDK de Android.

### Comandos de Consola

1.  **Limpiar la caché del proyecto:**
    ```bash
    flutter clean
    ```
2.  **Obtener las dependencias de pubspec:**
    ```bash
    flutter pub get
    ```
3.  **Ejecutar en modo depuración (Debug) en tu smartphone:**
    ```bash
    flutter run --debug -d <ID_DE_TU_DISPOSITIVO>
    ```
4.  **Compilar el paquete oficial de producción (Android App Bundle) para la Play Store:**
    ```bash
    flutter build appbundle
    ```

---

## 👨‍💻 Autor y Soporte

*   **Desarrollador:** Damián Arenas
*   **Repositorio oficial:** [https://github.com/MataKbras/reproductor](https://github.com/MataKbras/reproductor)
*   **Correo de contacto:** [kakalavacalexera@gmail.com](mailto:kakalavacalexera@gmail.com)

---

## ⚖️ Licencia (GPL v3)

Este proyecto se distribuye bajo la licencia **GNU General Public License v3.0 (GPL v3)**.

> [!IMPORTANT]
> **Condiciones Obligatorias:**
> 1.  **Obligada mención (Atribución):** Se deben mantener de forma visible todos los créditos de autoría del desarrollador original en cualquier redistribución o interfaz.
> 2.  **Obligado Open Source (Copyleft):** Si decides bifurcar (fork) este repositorio, modificar el código o utilizarlo en tu propio proyecto, **estás obligado** a liberar tu código fuente bajo la misma licencia libre y abierta (GPL v3).
