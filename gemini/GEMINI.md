# Configuracion de Gemini

## Creacion de Archivos de Obsidian

Cuando se solicite la creacion de un nuevo archivo de Obsidian, se deben seguir las siguientes directrices:

1.  **Anadir Propiedades (Properties):** Todos los archivos de Obsidian deben incluir las siguientes propiedades en la parte superior del archivo:

    ```yaml
    ---
    id: <ID_UNICO>
    fecha_modificacion: <FECHA_ACTUAL>
    etiquetas: []
    ---
    ```

    -   `id`: Un identificador unico para la nota. Puede ser un timestamp o un UUID.
    -   `fecha_modificacion`: La fecha y hora en que se modifica el archivo.
    -   `etiquetas`: Una lista de etiquetas relevantes para la nota.

2.  **Anadir un Titulo:** Todos los archivos de Obsidian deben tener un titulo principal (encabezado de nivel 1) que sea descriptivo y acertado para el contenido de la nota.

    ```markdown
    # Titulo de la Nota
    ```
