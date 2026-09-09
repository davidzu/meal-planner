# 03 — Data Model (ERD)

Status: Draft v2 · Format: Mermaid erDiagram — renders natively on GitHub
Contract: `schema.rb` and migrations must match this 1:1. Change both in the same commit.
Naming: entities in Spanish (domain language); Rails tables pluralize (`platillos`, `menu_dias`).

## v2 diagram

```mermaid
erDiagram
    HOGAR ||--o{ USUARIO : tiene
    HOGAR ||--o{ SEMANA : planifica
    SEMANA ||--|{ DIA : contiene
    DIA ||--o{ MENU_DIA : compone
    PLATILLO ||--o{ MENU_DIA : ocupa
    PLATILLO ||--|{ PLATILLO_INGREDIENTE : requiere
    INGREDIENTE ||--o{ PLATILLO_INGREDIENTE : aparece_en
    PLATILLO ||--o{ PLATILLO_ETIQUETA : etiquetado_con
    ETIQUETA ||--o{ PLATILLO_ETIQUETA : aplica_a
    SEMANA ||--o| LISTA_COMPRAS : genera
    LISTA_COMPRAS ||--|{ ITEM_LISTA : contiene
    INGREDIENTE ||--o{ ITEM_LISTA : aparece_en

    HOGAR {
        int id PK
        string nombre
    }
    USUARIO {
        int id PK
        string email UK
        int id_hogar FK
        string rol "planificador | cocinero"
    }
    SEMANA {
        int id PK
        date fecha_inicio UK "siempre lunes"
        int num_personas "escala listas de compra"
        int id_hogar FK
    }
    DIA {
        int id PK
        date fecha UK "nombre_dia se deriva de fecha"
        int id_semana FK
    }
    MENU_DIA {
        int id PK
        int id_dia FK
        string tipo_comida "desayuno | comida | cena"
        int id_platillo FK NOT_NULL "slot vacío = no existe la fila"
        int numero_porciones
    }
    PLATILLO {
        int id PK
        string nombre
        text descripcion "resumen corto para la tarjeta"
        text instrucciones "pasos de preparación"
        int tiempo_preparacion_min
        int porciones_base "rinde de la receta original"
        int calorias_por_porcion
        int id_autor FK "USUARIO — chef"
    }
    PLATILLO_INGREDIENTE {
        int id_platillo PK,FK
        int id_ingrediente PK,FK
        decimal cantidad NOT_NULL
        string unidad NOT_NULL
        string nota_prep "picado, al gusto..."
    }
    INGREDIENTE {
        int id PK
        string nombre
        string unidad_base "unidad canónica para merge"
        decimal precio_unitario "habilita costo por lista"
        string categoria "verduleria | carniceria | abarrotes | otros"
    }
    ETIQUETA {
        int id PK
        string nombre UK "cena, desayuno_rapido, oaxaqueño..."
        text descripcion
    }
    LISTA_COMPRAS {
        int id PK
        int id_semana FK,UK "una por semana"
    }
    ITEM_LISTA {
        int id PK
        int id_lista_compras FK
        int id_ingrediente FK
        decimal cantidad_total "sumada sobre todos los MENU_DIA"
        string unidad
        boolean comprado
    }
```

## Required constraints (migrations)

- `MENU_DIA`: unique index `(id_dia, tipo_comida)` → máximo un platillo por tipo y día; duplicar platillo en el mismo día sigue permitido vía otro tipo.
- `DIA`: unique index `(id_semana, fecha)`.
- `SEMANA`: unique index `(id_hogar, fecha_inicio)`.
- `PLATILLO_INGREDIENTE` y `PLATILLO_ETIQUETA`: PK surrogate `id` + unique index sobre el par de FKs (Rails no soporta PK compuestas nativamente).
- **Escalado (regla v1)**: cantidad de cada `PLATILLO_INGREDIENTE` se multiplica por `MENU_DIA.numero_porciones / PLATILLO.porciones_base` al generar `ITEM_LISTA`. Implementado en `ShoppingList#regenerate!`.
- **Merge (regla v1)**: `ITEM_LISTA` suma cantidades solo entre unidades idénticas; 500 g + 1 kg produce dos renglones. Conversión de unidades es decisión v2.

## Design decisions embedded here

- **`tipo_comida` vive en `MENU_DIA`, no en `PLATILLO`.** Un platillo no es inherentemente comida o cena; sugerencias de filtrado van como `ETIQUETA`.
- **Campos derivados no se almacenan**: `nombre_dia` ← `fecha`; número de semana y año ← `fecha_inicio`. Calcularlos en Ruby evita inconsistencia.
- **Ingredientes normalizados** para que `ITEM_LISTA` pueda sumar cantidades sobre los 21 slots. Merge solo entre unidades iguales en v1 (500 g + 1 kg → dos renglones).
- **Escalado**: cantidades se multiplican por `numero_porciones / platillo.porciones_base`.

## Open questions

- [ ] Batch cooking ("un guiso → tres comidas"): ¿entidad `COMPONENTE` ahora o v2? Si el journal muestra reuse >2×/semana, modelarlo en v1.
- [ ] `precio_unitario`: ¿quién lo mantiene actualizado? Si nadie, el costo calculado será mentira — decidir si v1 lo muestra o solo lo acumula.
- [ ] Fotos de platillos (ActiveStorage): necesaria para las tarjetas — decidir en wireframes (SCREEN-02/03).
- [ ] Enum vs tabla para `tipo_comida`: hoy es string con validación; migrar a tabla propia si crece (colaciones, horarios cliente).
