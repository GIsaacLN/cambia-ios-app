# Cambia 🌆

**¡Bienvenido! Te recomendamos leer todo este README para comprender mejor [cómo instalar](#instalación-📲)  y usar Cambia, y apreciar el potencial de esta aplicación en la planificación urbana frente a desastres.**

<p align="center">
  <img src="https://github.com/user-attachments/assets/15578ef3-2ff3-47c8-96db-249625b09358" alt="SCMC_Cambia_Banner 001" height="300" style="display: block; margin: 0 auto">
</p>

Cambia es una aplicación iOS diseñada para empoderar a urbanistas, funcionarios gubernamentales y coordinadores de respuesta ante emergencias con conocimientos basados en datos. Permite desarrollar planes de acción preventiva en ciudades vulnerables a desastres naturales. Desarrollada como parte del Changemakers Social Challenge (CSC) 2024, Cambia está alineada con el [Objetivo de Desarrollo Sostenible 11.5 de la ONU](https://agenda2030lac.org/es/ods/11-ciudades-y-comunidades-sostenibles/metas/115), que busca reducir las muertes y pérdidas económicas causadas por desastres naturales por medio de la planificación urbana basada en datos.

---


## Instalación 📲

Sigue estos pasos para configurar Cambia en tu máquina local:

1. **Clona el Repositorio**:
   
   ```bash
   git clone <url_del_repositorio>
   cd Cambia
   ```
   
3. **Abre el Proyecto**:
   
   - Abre el archivo `Cambia.xcodeproj` en Xcode.
  
5. **Configura los Archivos JSON Necesarios**:

   - En la raíz de este repositorio, encontrarás un archivo llamado `ArchivosComprimidos.zip`.
   - Descomprime este archivo y copia los archivos `.json` contenidos en el directorio del proyecto.
   - Crea una nueva estructura de carpetas si es necesario:
     
   ```bash
    Cambia/
    ├── App
    │   └── Resources
    │       ├── <Archivos JSON>
   ```

   - **IMPORTANTE**: Al agregar estos archivos en Xcode, selecciona **"Copy files to destination"** con el target configurado en **Cambia**.
    
7. **Compila y Ejecuta**:

   - Asegúrate de que tu dispositivo o simulador esté seleccionado.
   - Presiona `Cmd + R` para compilar y ejecutar el proyecto

---

## Funcionalidades Principales 🚀🖼️

Cambia ofrece una experiencia visual y funcional centrada en la planificación urbana basada en datos. A continuación, te mostramos algunas capturas de pantalla junto a sus funcionalidades destacadas:

<p align="center">
  <img src="https://github.com/user-attachments/assets/3d524bb7-415c-4023-9ccf-377904d44df1" alt="Panel de Métricas" height="300">
  <img src="https://github.com/user-attachments/assets/aecb0595-a859-4a7f-b702-5be68afb3b14" alt="Mapa Interactivo" height="300">
</p>

- **Panel de Métricas**: Visualiza estadísticas en tiempo real sobre infraestructura urbana, vulnerabilidad poblacional y riesgo de desastres.
  
- **Análisis Geolocalizado**: Ofrece insights detallados sobre áreas propensas a inundaciones y densidad poblacional, facilitando la planificación estratégica.

- **Mapas Interactivos**: Utiliza MapKit para mostrar capas visuales de datos específicos de vulnerabilidad urbana y facilitar la interpretación de riesgos en diferentes zonas.


---

## Arquitectura y Tecnologías 🏗️🛠️

Cambia está desarrollada en Swift y SwiftUI, con una arquitectura MVVM que permite una separación clara entre datos, interfaz y lógica, simplificando el mantenimiento y actualización de la app. Se apoya en:

- **MapKit** para geolocalización y visualización de mapas interactivos.
- **Charts** para la visualización de datos y gráficos en tiempo real.
- **CoreML**: El modelo de creacion propia integra los datos obtenidos para dar un analisis mas preciso a los usuarios sobre cada ciudad y municipio.
- **Componentes de UI Personalizados** para una experiencia visual profesional y adaptada a las necesidades de los usuarios.

Cambia está diseñada para ofrecer una experiencia intuitiva y orientada a datos, ayudando a los responsables de planificación urbana a anticipar y mitigar riesgos en sus ciudades.

---

## Licencia 📄

El código fuente de Cambia se proporciona bajo la licencia Creative Commons Universal 1.0 durante el Changemakers Social Challenge 2024. Tras el evento, la propiedad intelectual vuelve a pertenecer al equipo.

## Equipo SanGio 🌍

Nuestro equipo está comprometido a utilizar datos para lograr impactos reales en el mundo. Te invitamos a unirte a nosotros en la construcción de ciudades sostenibles para un futuro resiliente.

<div style="display: flex; align-items: center; justify-content: center;">

  <div style="margin-right: 20px;">
    <img src="https://github.com/user-attachments/assets/fa0221b6-6ada-4886-8f20-3defc67cbcec" alt="Equipo SanGio" height="200">
  </div>

  <div>
    <h3>Conoce a Nuestro Equipo</h3>
    <table>
      <tr>
        <th>Nombre</th>
        <th>Redes Sociales</th>
      </tr>
      <tr>
        <td><strong>Isaac López</strong></td>
        <td><a href="https://www.linkedin.com/in/gisaacln/">LinkedIn</a></td>
      </tr>
      <tr>
        <td><strong>Ara Castro</strong></td>
        <td><a href="https://www.linkedin.com/in/ary-castro/">LinkedIn</a></td>
      </tr>
      <tr>
        <td><strong>Yatziri Pineda</strong></td>
        <td><a href="https://www.linkedin.com/in/yatziri-pineda-cabrera/">LinkedIn</a></td>
      </tr>
      <tr>
        <td><strong>Raymundo Mondragon</strong></td>
        <td><a href="https://www.linkedin.com/in/raymundoml/">LinkedIn</a></td>
      </tr>
    </table>
  </div>

<p style="margin-top: 20px;">
  <blockquote>Juntos, somos SanGio, un equipo que trabaja para hacer posible el cambio a través de la tecnología y la colaboración.</blockquote>
</p>
</div>

---
