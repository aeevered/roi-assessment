# roi-assessment

Transform the provided **Marketplace** dataset into a **star schema** with **dbt**, plus analytics for **top sellers**, **top products**, and **top customer locations** (with **dense-rank** columns on key measures).

## Prerequisites

- **Docker** (for Postgres)
- **Python 3.8+** (for dbt)
- A **`job-assessment/`** directory **inside this repository** at the project root (next to `docker-compose.yml`) containing **`ddl.sql`** and **`data.sql`** (same files as the assessment bundle). Docker mounts `./job-assessment` into Postgres init.

## Repository layout and data

Expected paths **in this repo**:

- **`job-assessment/ddl.sql`** — table definitions  
- **`job-assessment/data.sql`** — seed inserts  

`docker-compose.yml` mounts **`./job-assessment`** as `/sql` in the container; `db/init` runs `\i /sql/ddl.sql` and `\i /sql/data.sql` on first database boot.

**Data note:** the seed has **100 orders** but only **60** have any `order_line` rows. The fact table is **line-level** and uses an **inner join** to orders, so header-only orders do not appear in `fct_order_items` or downstream analytics.

## Quickstart

```bash
cd /path/to/roi-assessment
```

## Database setup (Docker Compose)

```bash
docker compose up -d
```

Connection details (match **`.dbt/profiles.yml`**):

| Setting   | Value            |
|-----------|------------------|
| host      | `localhost`      |
| port      | `5432`           |
| database  | `roi_assessment` |
| user      | `roi`            |
| password  | `roi`            |

Reset the database (re-runs init scripts):

```bash
docker compose down -v
docker compose up -d
```

## dbt project (`roi_assessment`)

### Install

```bash
python -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

### Profile

Use the project-local profile: **`.dbt/profiles.yml`**. Copy from **`profiles.yml.example`** if needed.

dbt does **not** read `profiles-dir` from `dbt_project.yml`. You can either pass **`--profiles-dir ./.dbt`** on each command, or set the environment variable **`DBT_PROFILES_DIR`** once (from this repo root) so every `dbt` command uses **`.dbt/`** by default:

```bash
export DBT_PROFILES_DIR="$PWD/.dbt"
dbt debug
dbt build
```

For a persistent default while you work only in this directory, use **[direnv](https://direnv.net/)** with **`.envrc`** containing `export DBT_PROFILES_DIR="$PWD/.dbt"`, or merge the same `outputs` block into **`~/.dbt/profiles.yml`** under **`roi_assessment`** so the global default profile applies.

### Common commands

If you did **not** set `DBT_PROFILES_DIR`, add **`--profiles-dir ./.dbt`** to each command below.

```bash
# Models + tests
dbt build --profiles-dir ./.dbt

# Source freshness (customer, orders, seller_product_price — see models/sources.yml)
dbt source freshness --profiles-dir ./.dbt

# Type-2 snapshot on seller_product_price
dbt snapshot --profiles-dir ./.dbt -s scd_seller_product_price

# Example incremental model
dbt run --profiles-dir ./.dbt -s int_orders_incremental
```

### Layering (schemas)

Configured in **`dbt_project.yml`**: staging and analytics default to **views**; marts default to **tables**.

| Layer         | Path / schema                  | Contents |
|---------------|--------------------------------|----------|
| **Sources**   | `public`                       | `models/sources.yml` → `marketplace` (includes **freshness** on selected tables) |
| **Staging**   | `models/staging/` → `staging`  | `stg_marketplace__*` views over raw tables |
| **Marts**     | `models/marts/` → `marts`      | `dim_customer`, `dim_customer_address`, `dim_seller`, `dim_product`, **`fct_order_items`** (`item_amount = quantity * unit_price_at_sale`) |
| **Analytics** | `models/analytics/` → `analytics` | `top_sellers`, `top_products`, `top_customer_locations` (metrics + `dense_rank` per measure) |
| **Examples**  | `models/examples/` → `examples` | **`int_orders_incremental`** — incremental merge pattern on orders |
| **Snapshots** | `snapshots/` → `snapshots`     | **`scd_seller_product_price`** — SCD2 via `timestamp` strategy on `updated_at` |

### Tests and quality

- **Generic tests** in `models/staging/schema.yml` and `models/marts/schema.yml` (`not_null`, `unique`, `relationships`, custom **`non_negative`** macro in `macros/tests/non_negative.sql`).
- **Singular tests** in `tests/`.
