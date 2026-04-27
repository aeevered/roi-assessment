# roi-assessment

Transform the provided Marketplace dataset into a star schema with dbt, plus analytics for top sellers, top products, and top customer locations.

## Prerequisites

- **Docker**
- **Python 3.8+**

## Quickstart

```bash
cd /path/to/roi-assessment
```

### Seed Data (from job-assessment)

Clone `job-assessment` as a separate Git repository to the same parent directory as roi-assessment:

```text
your-projects/
  job-assessment/     # clone here — contains ddl.sql, data.sql
  roi-assessment/     # this dbt project
```

### Database setup

```bash
docker compose up -d
```

Connection details (match **`.dbt/profiles.yml`**):

| Setting   | Value          |
|-----------|----------------|
| host      | localhost     |
| port      | 5432          |
| database  | roi_assessment |
| user      | roi            |
| password  | roi            |

Reset the database (re-runs init scripts):

```bash
docker compose down -v
docker compose up -d
```

## dbt project

### Install

```bash
python -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

### Profile

Use the project-local profile: **`.dbt/profiles.yml`**. Copy from **`profiles.yml.example`** if needed.

dbt does not read `profiles-dir` from `dbt_project.yml`. You can either pass `--profiles-dir ./.dbt` on each command, or set the environment variable `DBT_PROFILES_DIR` once (from this repo root) so every `dbt` command uses `.dbt/` by default:

```bash
export DBT_PROFILES_DIR="$PWD/.dbt"
dbt debug
dbt build
```

### Common commands

If you did not set `DBT_PROFILES_DIR`, include `--profiles-dir ./.dbt` for each command.

```bash
# Models + tests
dbt build --profiles-dir ./.dbt

# Source freshness
dbt source freshness --profiles-dir ./.dbt

# Type-2 snapshot Example
dbt snapshot --profiles-dir ./.dbt -s scd_seller_product_price

# Incremental Model Example
dbt run --profiles-dir ./.dbt -s int_orders_incremental
```

### Data Transformation Layers

Configured in `dbt_project.yml`

| Layer         | Path / Schema                  | Contents |
|---------------|--------------------------------|----------|
| **Sources**   | `public`                       | `models/sources.yml` → `marketplace` |
| **Staging**   | `models/staging/` → `staging`  | `stg_marketplace__*`|
| **Marts**     | `models/marts/` → `marts`      | `dim_customer`, `dim_customer_address`, `dim_seller`, `dim_product`, `fct_order_items`|
| **Analytics** | `models/analytics/` → `analytics` | `top_sellers`, `top_products`, `top_customer_locations` (metrics + `dense_rank` per measure) |
| **Examples**  | `models/examples/` → `examples` | `int_orders_incremental` |
| **Snapshots** | `snapshots/` → `snapshots`     | `scd_seller_product_price` |

### Tests and quality

- **Generic tests** in `models/staging/schema.yml` and `models/marts/schema.yml` (`not_null`, `unique`, `relationships`, custom `non_negative` macro in `macros/tests/non_negative.sql`).
- **Singular tests** in `tests/`.
