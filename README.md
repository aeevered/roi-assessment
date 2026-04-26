# roi-assessment

Transform the provided **Marketplace** dataset into a **star schema** with **dbt**, plus analytics for **top sellers**, **top products**, and **top customer locations** (with **dense-rank** columns on key measures).

## Prerequisites

- **Docker** (for Postgres)
- **Python 3.8+** (for dbt)
- **Git** (to clone or update the sibling **job-assessment** repository)

## Seed Data (from `job-assessment`)

Keep **`job-assessment`** as a **separate Git repository** in the **same parent directory** as **roi-assessment** (siblings), not inside this repo:

```text
your-projects/
  job-assessment/     # clone here — contains ddl.sql, data.sql
  roi-assessment/     # this dbt project (docker-compose lives here)
```

Clone or update **job-assessment** next to this project (replace **`OWNER`** with the GitHub org or user that hosts that repo):

```bash
cd /path/to/your-projects   # parent folder that will hold both repos

git clone https://github.com/OWNER/job-assessment.git
# clone or copy roi-assessment into the same parent if you have not already

# Later: refresh SQL files
git -C job-assessment pull
```

`docker-compose.yml` mounts **`../job-assessment`** (sibling path) into the container as `/sql`; `db/init` runs `\i /sql/ddl.sql` and `\i /sql/data.sql` on first database boot. Run **`docker compose`** from **`roi-assessment/`** so the relative path resolves.

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
| **Sources**   | `public`                       | `models/sources.yml` → `marketplace` |
| **Staging**   | `models/staging/` → `staging`  | `stg_marketplace__*`|
| **Marts**     | `models/marts/` → `marts`      | `dim_customer`, `dim_customer_address`, `dim_seller`, `dim_product`, `fct_order_items`|
| **Analytics** | `models/analytics/` → `analytics` | `top_sellers`, `top_products`, `top_customer_locations` (metrics + `dense_rank` per measure) |
| **Examples**  | `models/examples/` → `examples` | **`int_orders_incremental`** |
| **Snapshots** | `snapshots/` → `snapshots`     | `scd_seller_product_price` |

### Tests and quality

- **Generic tests** in `models/staging/schema.yml` and `models/marts/schema.yml` (`not_null`, `unique`, `relationships`, custom **`non_negative`** macro in `macros/tests/non_negative.sql`).
- **Singular tests** in `tests/`.
