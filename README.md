# 🛒 Comparador de Compras — Base de Datos del Proyecto

> **⚠️ DATOS DE PRUEBA — NO SON REALES**  
> Esta base de datos contiene datos ficticios generados para un ejercicio académico. Los productos, precios, especificaciones y URLs **no corresponden a productos ni precios reales** de ninguna tienda. No deben usarse como referencia de compra ni con fines comerciales.

> **Gestión de Proyectos de Software** · Universidad Antonio Nariño · 2026-I  
> **Profesor:** Ing. Jhonatan Sneider Rico Pinto MSc.  
> **Repositorio:** [github.com/jsricop](https://github.com/jsricop/)

---

## Descripción

Base de datos simulada de productos de tecnología disponibles en tiendas colombianas. Es la fuente de datos para el proyecto del semestre: **Comparador de Compras de Productos de Tecnología**.

| Dato | Valor |
|------|-------|
| Productos | **617** |
| Registros de precios | **2.167** |
| Categorías | 5 |
| Marcas | 35 |
| Tiendas | 5 |
| Moneda | COP (pesos colombianos) |
| Rango de precios | $55.900 — $10.991.990 |

---

## Estructura del repositorio

```
├── README.md                  ← Este archivo
├── csv/                       ← Datos en CSV (1 archivo por tabla)
│   ├── categories.csv
│   ├── brands.csv
│   ├── stores.csv
│   ├── products.csv
│   └── product_prices.csv
├── json/
│   └── data.json              ← Todos los datos en un solo JSON (~1 MB)
├── sql/
│   ├── schema.sql             ← Solo estructura (sin datos)
│   └── schema_and_data.sql    ← Estructura + datos para PostgreSQL
└── dbml/
    └── schema.dbml            ← Modelo E-R para dbdiagram.io
```

---

## ¿Qué archivo usar según mi stack?

No necesitan usar todos los archivos. Elijan **el formato que mejor encaje** con las tecnologías que eligieron.

### Mapa de decisión rápida

```
¿Su backend usa una base de datos relacional (SQL)?
  ├── Sí → ¿PostgreSQL?
  │         ├── Sí → sql/schema_and_data.sql (importar directo)
  │         └── No → sql/schema.sql como referencia + importar csv/
  │
  └── No → ¿Usan un backend con Node.js, Python, etc.?
            ├── Sí → json/data.json (cargar en memoria o en su BD)
            └── No → ¿Frontend-only (sin backend)?
                      └── Sí → json/data.json (importar como módulo)
```

---

### 📄 `sql/schema_and_data.sql` — Bases de datos PostgreSQL

**Qué contiene:** Estructura completa de tablas + todos los datos listos para insertar.

**Usar cuando:** Su backend se conecta a una base de datos PostgreSQL, ya sea local o en la nube.

**Plataformas compatibles:**
- **PostgreSQL local** — Importar directamente con `psql`
- **Supabase** — Ir a SQL Editor, pegar el contenido y ejecutar. Supabase es PostgreSQL, así que funciona tal cual. Después pueden usar la API REST automática de Supabase para consultar desde el frontend.
- **Railway** — Crear un servicio PostgreSQL, conectarse con `psql` o un cliente como DBeaver y ejecutar el archivo.
- **Render** — Crear una base PostgreSQL y ejecutar el SQL desde el dashboard o por terminal.
- **Neon** — Igual que Supabase: pegar en el SQL Editor y ejecutar.
- **ElephantSQL** — Conectar por `psql` o pgAdmin e importar.

```bash
# Ejemplo: importar en PostgreSQL local
psql -U usuario -d nombre_base < sql/schema_and_data.sql
```

### 📄 `sql/schema.sql` — Solo la estructura (sin datos)

**Qué contiene:** Las sentencias `CREATE TABLE` con tipos, llaves primarias, foráneas e índices. Sin `INSERT`.

**Usar cuando:** Quieren entender el modelo relacional, crear las tablas vacías y cargar datos desde otro formato (CSV, JSON), o adaptar la estructura a otro motor SQL.

**Plataformas compatibles:**
- **MySQL / MariaDB** — Adaptar: cambiar `SERIAL` por `INT AUTO_INCREMENT`, `JSONB` por `JSON`, quitar el índice GIN.
- **SQLite** — Adaptar: cambiar `SERIAL` por `INTEGER PRIMARY KEY AUTOINCREMENT`, `JSONB` por `TEXT`, quitar el índice GIN. Luego importar los CSV con `.import`.
- **PlanetScale** — Adaptar a MySQL. PlanetScale no soporta foreign keys, así que quitar las cláusulas `REFERENCES`.
- **Cualquier ORM** (Prisma, Sequelize, TypeORM, Django ORM) — Usar como referencia para crear sus modelos. No importar el SQL directamente sino definir los modelos en el ORM con la misma estructura.

---

### 📦 `json/data.json` — Todo en un solo archivo

**Qué contiene:** Las 5 tablas como arrays dentro de un objeto JSON. ~1 MB.

**Estructura:**
```json
{
  "metadata": { "generated": "...", "version": "1.0" },
  "categories": [...],
  "brands": [...],
  "stores": [...],
  "products": [...],
  "product_prices": [...]
}
```

**Usar cuando:** No quieren manejar una BD relacional, o quieren cargar todo en memoria y filtrarlo desde la aplicación.

**Plataformas y usos compatibles:**

- **Node.js / Express / Next.js** — `require('./data.json')` o `JSON.parse(fs.readFileSync(...))`. Pueden servirlo como API, filtrarlo con JavaScript, o cargarlo en una BD al iniciar.
- **Python / Flask / Django / FastAPI** — `json.load(open('data.json'))`. Cargar al arranque y servir desde endpoints.
- **Frontend-only (React, Vue, Angular, Svelte)** — Importar el JSON como módulo estático. Funciona si no necesitan backend: toda la lógica de búsqueda y filtrado corre en el navegador.
- **Firebase Firestore** — Escribir un script que lea el JSON y haga `batch.set()` para subir cada producto como documento. Firestore es NoSQL, así que las relaciones se manejan con IDs de referencia.
- **MongoDB / MongoDB Atlas** — Usar `mongoimport` o un script que tome cada array del JSON y lo inserte como colección.
- **Supabase (alternativa al SQL)** — Si prefieren no correr SQL, pueden escribir un script que lea el JSON y use la librería `supabase-js` para insertar los datos vía API.

```javascript
// Ejemplo: Node.js — cargar y filtrar
const data = require('./json/data.json');

// Todos los celulares Samsung disponibles
const result = data.products
  .filter(p => p.category_id === 2)
  .filter(p => {
    const brand = data.brands.find(b => b.id === p.brand_id);
    return brand.name === 'Samsung';
  });
```

```python
# Ejemplo: Python — cargar y filtrar
import json
with open('json/data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Precio más bajo de cada producto
from itertools import groupby
prices_by_product = {}
for pp in data['product_prices']:
    pid = pp['product_id']
    if pid not in prices_by_product or pp['price'] < prices_by_product[pid]:
        prices_by_product[pid] = pp['price']
```

---

### 📊 `csv/*.csv` — Tablas individuales en CSV

**Qué contiene:** 5 archivos CSV, uno por tabla. El campo `specifications` en `products.csv` es un string JSON.

| Archivo | Registros |
|---------|-----------|
| `categories.csv` | 5 |
| `brands.csv` | 36 |
| `stores.csv` | 5 |
| `products.csv` | 617 |
| `product_prices.csv` | 2.167 |

**Usar cuando:** Necesitan importar datos en una herramienta que lea CSV, o quieren cargar tablas por separado.

**Plataformas y usos compatibles:**

- **SQLite** — `.mode csv` + `.import csv/products.csv products`
- **MySQL** — `LOAD DATA INFILE 'products.csv' INTO TABLE products`
- **pandas (Python)** — `pd.read_csv('csv/products.csv')`
- **Excel / Google Sheets** — Abrir directamente para explorar los datos antes de programar
- **Supabase** — Ir a Table Editor → Import CSV para cada tabla (crear las tablas primero con `schema.sql`)
- **DBeaver / pgAdmin / cualquier cliente SQL** — Función de importar CSV

```python
# Ejemplo: pandas — unir productos con precios
import pandas as pd

products = pd.read_csv('csv/products.csv')
prices = pd.read_csv('csv/product_prices.csv')
stores = pd.read_csv('csv/stores.csv')

# Productos con su precio más bajo
best_prices = prices.groupby('product_id')['price'].min().reset_index()
merged = products.merge(best_prices, left_on='id', right_on='product_id')
```

---

### 🗂️ `dbml/schema.dbml` — Modelo E-R

**Qué contiene:** Definición del modelo relacional en formato DBML (Database Markup Language).

**Usar para:**

- **Visualizar el diagrama E-R** — Pegar en [dbdiagram.io](https://dbdiagram.io) para ver las tablas y relaciones gráficamente
- **Documentación** — Incluir el diagrama generado en su presentación del proyecto
- **Generar SQL para otros motores** — dbdiagram.io permite exportar a PostgreSQL, MySQL, SQL Server

No es un archivo de datos: es solo la definición de la estructura.

---

## Diagrama E-R

Para visualizar el modelo relacional:

1. Abrir [dbdiagram.io](https://dbdiagram.io)
2. Copiar el contenido de [`dbml/schema.dbml`](dbml/schema.dbml)
3. Pegarlo en el editor

### Relaciones

```
categories  1 ──── N  products
brands      1 ──── N  products
products    1 ──── N  product_prices
stores      1 ──── N  product_prices
```

Un producto pertenece a una categoría y una marca. Un producto puede tener múltiples precios (uno por cada tienda que lo vende).

---

## Modelo de datos

### `categories`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | int PK | Identificador |
| `name` | varchar | Nombre |
| `slug` | varchar | URL-friendly |

**Valores:** Computadores, Celulares, Tablets, Periféricos, Componentes.

### `brands`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | int PK | Identificador |
| `name` | varchar | Nombre de la marca |
| `slug` | varchar | URL-friendly |

35 marcas: Acer, AMD, Apple, ASUS, Bose, Corsair, Crucial, Dell, EVGA, Gigabyte, Honor, HP, Huawei, HyperX, Intel, JBL, Kingston, Lenovo, LG, Logitech, Motorola, MSI, Nothing, OnePlus, Oppo, Razer, Realme, Redragon, Samsung, Seagate, Sony, SteelSeries, Trust, Western Digital, Xiaomi.

### `stores`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | int PK | Identificador |
| `name` | varchar | Nombre de la tienda |
| `slug` | varchar | URL-friendly |
| `url` | varchar | URL base |
| `city` | varchar | Ciudad o "Nacional" |

**Tiendas:** Alkosto (Bogotá), Éxito (Medellín), Falabella (Bogotá), Mercado Libre (Nacional), Amazon Colombia (Nacional).

### `products`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | int PK | Identificador |
| `category_id` | int FK → categories | Categoría |
| `brand_id` | int FK → brands | Marca |
| `name` | varchar | Nombre completo |
| `model` | varchar | Modelo o línea |
| `description` | text | Descripción legible |
| `image_url` | varchar | URL ficticia de imagen |
| `specifications` | JSON | Specs técnicas (varían por categoría) |
| `created_at` | timestamp | Fecha de creación |

**Distribución:**

| Categoría | Productos | Incluye |
|-----------|-----------|---------|
| Computadores | 125 | Laptops de trabajo, gaming y ultrabooks |
| Celulares | 130 | Gama alta, media y entrada |
| Tablets | 100 | Android y iPadOS |
| Periféricos | 137 | Mouse, teclado, audífonos, monitor, webcam, parlante |
| Componentes | 125 | GPU, CPU, RAM, SSD, fuentes, tarjetas madre |

### `product_prices`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | int PK | Identificador |
| `product_id` | int FK → products | Producto |
| `store_id` | int FK → stores | Tienda |
| `price` | int | Precio actual en COP |
| `original_price` | int (nullable) | Precio antes de descuento |
| `currency` | varchar | Siempre "COP" |
| `availability` | varchar | `disponible`, `pocas_unidades` o `agotado` |
| `url` | varchar | URL ficticia del producto en la tienda |
| `last_updated` | date | Última actualización |

Cada producto aparece en 2–5 tiendas con precios distintos (variación ±15%). ~60% tienen precio con descuento. Disponibilidad: 69% disponible, 20% pocas unidades, 11% agotado.

---

## Campo `specifications` (JSON)

Las specs varían por categoría. El JSON es flexible: cada categoría tiene campos distintos.

<details>
<summary><strong>Computadores</strong></summary>

```json
{
  "processor": "Intel Core i7-13700H",
  "ram_gb": 16,
  "storage": "512GB SSD",
  "screen_size": "15.6\"",
  "operating_system": "Windows 11 Home",
  "gpu": "NVIDIA GeForce RTX 4060",
  "weight_kg": 2.1,
  "battery_hours": 8
}
```
</details>

<details>
<summary><strong>Celulares</strong></summary>

```json
{
  "ram_gb": 8,
  "storage": "256GB",
  "screen_size": "6.7\"",
  "battery_mah": 5000,
  "main_camera": "108MP",
  "operating_system": "Android 14",
  "color": "Negro",
  "5g": true,
  "weight_g": 195
}
```
</details>

<details>
<summary><strong>Tablets</strong></summary>

```json
{
  "ram_gb": 8,
  "storage": "128GB",
  "screen_size": "11\"",
  "battery_mah": 8000,
  "operating_system": "Android 14",
  "color": "Gris",
  "weight_g": 500,
  "connectivity": "Wi-Fi + LTE",
  "stylus_included": false
}
```
</details>

<details>
<summary><strong>Periféricos</strong> (ejemplo: Mouse)</summary>

```json
{
  "peripheral_type": "Mouse",
  "dpi": 16000,
  "connectivity": "Wireless 2.4GHz",
  "buttons": 6,
  "weight_g": 80,
  "rgb": true
}
```

Tipos: Mouse, Teclado, Audífonos, Monitor, Webcam, Parlante. Cada tipo tiene campos distintos.
</details>

<details>
<summary><strong>Componentes</strong> (ejemplo: Tarjeta Gráfica)</summary>

```json
{
  "component_type": "Tarjeta Gráfica",
  "vram": "12GB GDDR6X",
  "interface": "PCIe 4.0 x16",
  "tdp_w": 285,
  "outputs": "3x DisplayPort 1.4a, 1x HDMI 2.1"
}
```

Tipos: Tarjeta Gráfica, Procesador, Memoria RAM, Almacenamiento SSD, Fuente de Poder, Tarjeta Madre. Cada tipo tiene campos distintos.
</details>

---

## Notas importantes

> **⚠️ TODOS LOS DATOS SON FICTICIOS.** Esta base de datos fue generada para un ejercicio académico en la Universidad Antonio Nariño. Los nombres de productos, precios, especificaciones y disponibilidad no corresponden a datos reales de ninguna tienda. No deben usarse como referencia de compra ni con fines comerciales.

1. **Las URLs de imágenes y productos son ficticias.** Los equipos pueden ignorarlas o reemplazarlas con imágenes reales.

2. **Los precios son simulados** con rangos realistas para Colombia, pero no son precios reales de ninguna tienda. Las marcas y modelos de productos son reales como referencia, pero las combinaciones (variantes, colores, especificaciones) son generadas aleatoriamente.

3. **Los datos son estáticos.** Si quieren simular historial de precios (funcionalidad opcional), deben generar esos datos adicionales.

4. **El campo `specifications` es JSON flexible.** Cada categoría tiene campos diferentes. Deben parsearlo según la categoría para mostrar las specs correctas.

5. **Cualquier formato sirve.** No es necesario usar todos los archivos. Elijan el que mejor se adapte a su stack.

---

## Consultas de ejemplo (SQL)

```sql
-- Productos con su categoría y marca
SELECT p.name, c.name AS category, b.name AS brand
FROM products p
JOIN categories c ON p.category_id = c.id
JOIN brands b ON p.brand_id = b.id
LIMIT 10;

-- Precio más bajo por producto
SELECT p.name, MIN(pp.price) AS min_price, MAX(pp.price) AS max_price
FROM products p
JOIN product_prices pp ON p.id = pp.product_id
GROUP BY p.id, p.name
ORDER BY min_price DESC
LIMIT 10;

-- Productos de una categoría con precios en una tienda
SELECT p.name, pp.price, pp.availability, s.name AS store
FROM products p
JOIN product_prices pp ON p.id = pp.product_id
JOIN stores s ON pp.store_id = s.id
WHERE p.category_id = 1  -- Computadores
  AND pp.availability = 'disponible'
ORDER BY pp.price ASC;

-- Filtrar por specs en JSON (PostgreSQL)
SELECT name, specifications->>'processor' AS processor, specifications->>'ram_gb' AS ram
FROM products
WHERE category_id = 1
  AND (specifications->>'ram_gb')::int >= 16
  AND specifications->>'gpu' IS NOT NULL;
```

---

**Gestión de Proyectos de Software · UAN · 2026-I**
