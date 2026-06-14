
# TaskFlow SaaS Growth Analytics

End-to-end analytics project for **TaskFlow**, a fictional B2B subscription SaaS (productivity software, Starter / Pro / Business plans). Built to demonstrate a realistic analyst workflow: raw multi-source data → PostgreSQL star schema → Power BI dashboard.

> **Portfolio project by Briggs Odimate**

📊 [View Dashboard](./Dashboard/Power%20BI%20dashbord/) &nbsp;·&nbsp; 📁 [SQL Files](./SQL%20load) &nbsp;·&nbsp; 📂 [Raw Data](./SQL%20load/raw)

---

## 📋 Background & Overview

TaskFlow is a B2B productivity SaaS serving small and medium businesses across three subscription tiers. The business runs on a standard SaaS toolstack Stripe for billing, Mixpanel for product analytics, HubSpot for CRM, Typeform for customer feedback, and Google/LinkedIn Ads for paid acquisition.

The analytics team identified a critical gap: despite having data across all these tools, no unified view existed to support monthly growth decisions. Revenue, churn, customer acquisition costs, and NPS were all tracked in isolation making it impossible to understand the full health of the business at a glance.

This project addresses that gap by:

- **Centralising** 11 raw data sources into a single PostgreSQL star schema
- **Calculating** the 10 core SaaS KPIs across 4 metric families
- **Presenting** findings in a stakeholder-ready Power BI dashboard designed for the head of growth

The insights produced by this analysis would feed directly into monthly budget decisions, acquisition channel strategy, and retention prioritisation. outputs typically shared between the growth analyst, marketing analyst, and finance team.

> **Tech stack:** PostgreSQL · Python (data generation) · Power BI (DAX + dashboard) · Git

---

## 🗂️ Data Structure

11 synthetic CSVs mimicking real SaaS tool exports — 400 customers, ~321K product events, 18 months (Jan 2024 – Jun 2025).

### Source Files

| Source Tool | File(s) | Rows | What it captures |
|---|---|---|---|
| Stripe | `stripe_customers`, `stripe_products`, `stripe_prices`, `stripe_subscriptions`, `stripe_invoices` | 400 / 3 / 6 / 400 / 3,849 | Billing, subscription lifecycle, revenue |
| Mixpanel | `mixpanel_events` | ~321,244 | Product usage events by user |
| HubSpot | `hubspot_contacts` | 460 | CRM contacts incl. 60 unconverted leads |
| Typeform | `typeform_nps_responses` | 1,562 | Quarterly NPS survey responses |
| Google Ads | `google_ads_campaigns` | 108 | Paid acquisition — search campaigns |
| LinkedIn Ads | `linkedin_ads_campaigns` | 72 | Paid acquisition — B2B campaigns |
| Auth DB | `auth_users` | 400 | User identity and authentication |

### Star Schema (PostgreSQL)

The raw data was modelled into a 3-layer star schema:

```
raw.*         — 11 staging tables, mirror source exports with no transforms
dimensions.*  — 4 dimension tables built by joining raw sources
facts.*       — 4 fact tables with calculated measures and foreign keys
```

**Entity Relationship Diagram:**

![ERD](assests\erd.png)
<!-- Add your ERD image to the assets/ folder and it will render here -->

| Table | Layer | Primary Key | Powers |
|---|---|---|---|
| `dim_date` | Dimension | `date_key` | Time intelligence across all facts |
| `dim_plans` | Dimension | `price_id` | Plan tier, pricing, billing interval |
| `dim_channels` | Dimension | `channel_id` | Acquisition channel attribution |
| `dim_customers` | Dimension | `customer_id` | Customer demographics, lifecycle |
| `fact_subscriptions` | Fact | `subscription_id` | MRR, churn, retention, LTV |
| `fact_nps` | Fact | `response_id` | NPS score and category |
| `fact_marketing_spend` | Fact | `(channel_id, date_key)` | CAC, spend by channel |
| `fact_product_usage` | Fact | `(user_id, year_month)` | Engagement score, feature usage |

**SQL run order:** [`SQL load/raw`](./SQL%20load/raw) → [`SQL load/dimensions`](./SQL%20load/dimensions) → [`SQL load/facts`](./SQL%20load/facts) → [`SQL load/metrics`](./SQL%20load/metrics)

---

## 📊 Executive Summary

TaskFlow shows strong top-line growth, MRR grew steadily from ~$1K in early 2024 to nearly $10K by mid-2025, with monthly churn averaging a healthy 2% and NPS holding at 45 (the "Great" tier). However, the acquisition strategy reveals a critical profitability problem: **Starter plan customers acquired through paid channels are unprofitable**, with a LTV:CAC ratio of 0.87x, meaning the business spends more to acquire them than it ever recovers. Business plan customers, by contrast, sit at 9.83x, making them the clear engine of sustainable growth.

These findings suggest an immediate opportunity to reallocate acquisition budget away from Starter tier and toward Business and Pro upsell, which would improve blended unit economics without requiring any increase in total spend.

![Dashboard Overview](assests\dashboard_overview.png)
<!-- Export a screenshot of your full Power BI dashboard and save it to assets/dashboard_overview.png -->

---

## 💡 Insights Deep Dive

### 1. MRR grew 10x over 18 months — but churn spikes reveal retention risk

MRR grew from ~$1K (Jan 2024) to ~$10K (Apr 2025), approximately 10x growth over 18 months. Monthly churn averaged 2% across the period, which sits within the healthy SaaS benchmark of 1–3%. However, two months stand out as anomalies: **April 2024 (4.04%)** and **February 2025 (3.25%)**, both roughly double the baseline. These spikes warrant investigation into whether they correlate with a product release, pricing change, or seasonal pattern.

![MRR and Churn Trend](assests\mrr_churn_trend.png)
<!-- Screenshot of your Zone 2 trend charts side by side -->

### 2. Starter plan is losing money on paid acquisition

The LTV:CAC breakdown by plan tier tells the clearest story in the data:

| Plan | ARPU | Churn Rate | LTV | Blended CAC | LTV:CAC |
|---|---|---|---|---|---|
| Business | $75.43 | 17.7% | $320.57 | $32.61 | **9.83x** ✅ |
| Pro | $24.08 | 15.9% | $113.63 | $32.61 | **3.48x** ✅ |
| Starter | $8.64 | 22.8% | $28.38 | $32.61 | **0.87x** ❌ |

Starter's LTV:CAC below 1.0x means every paid-acquired Starter customer costs more than they will ever generate in revenue. The combination of low ARPU ($8.64) and the highest churn rate (22.8%) makes the economics untenable at current ad spend levels.

![LTV CAC by Plan](assests\ltv_cac_plan.png)
<!-- Screenshot of your LTV:CAC by plan bar chart from Zone 3 -->

### 3. LinkedIn's high CAC is still justified — for the right customers

Google Ads delivers a CAC of $27.77 vs LinkedIn's $102.34 — a 3.7x difference. On the surface this makes LinkedIn look inefficient. However, LinkedIn's B2B targeting skews heavily toward Business plan customers, where LTV is $320.57. A $102 CAC against a $320 LTV produces a 3.1x ratio on LinkedIn alone — still healthy. The issue is not LinkedIn's cost; it is whether Starter customers are being reached through either channel.

![CAC by Channel](assests\cac_by_channel.png)
<!-- Screenshot of your CAC by channel bar chart from Zone 3 -->

### 4. NPS is healthy but detractors deserve attention

NPS of 45 places TaskFlow in the "Great" tier (30–50 range). Promoters account for 60% of respondents, passives 25%, and detractors 15%. While the headline number is strong, 15% detractors at 1,562 responses represents approximately 234 customers actively dissatisfied, a cohort worth engaging through the open-text feedback fields already captured in the Typeform data.

![NPS Breakdown](assests\nps_breakdown.png)
<!-- Screenshot of your NPS stacked bar chart from Zone 3 -->

---

## 🔁 Recommendations

**1. Remove Starter tier from paid acquisition targeting immediately**
With a 0.87x LTV:CAC, every $1 spent acquiring a Starter customer generates a net loss. Redirect that budget to Business and Pro campaigns where returns are 9.83x and 3.48x respectively. Consider making Starter organic-only — word of mouth, SEO, and referral — where CAC is effectively zero.

**2. Investigate April 2024 and February 2025 churn spikes**
Both months saw churn roughly double the baseline. A product, pricing, or external market event likely explains the pattern. Cross-referencing these dates with product changelog and support ticket volume would help the product analyst identify and address the root cause.

**3. Prioritise Business plan upsell from the Pro tier**
Pro customers show a 3.48x LTV:CAC and a lower churn rate than Starter (15.9% vs 22.8%). An in-product upgrade prompt or account expansion motion targeting Pro customers who have been active for 3+ months could move them to Business tier — the highest-value segment — without additional acquisition spend.

**4. Engage the detractor cohort through existing NPS data**
The Typeform NPS responses already capture open-text reasons for low scores. Routing these 234 detractor responses to a customer success workflow — with a 48-hour response SLA — could convert a meaningful share before they churn.

---

## ⚠️ Caveats & Assumptions

- **COGS fixed at 25%** — gross margin is hardcoded at 75% using an industry-standard placeholder for SaaS hosting, payment processing, and support costs. Real gross margin would require actual cost data from the finance team.
- **Conversion rate (81%) is inflated** — the synthetic data generation process created most records as already-active subscriptions, skipping the trial-to-paid conversion step. This metric is not reliable and has been excluded from dashboard recommendations.
- **CAC is blended across channels** — marketing spend data does not include plan-level attribution, so CAC cannot be broken down by which plan a paid-acquired customer converted to. The plan-level LTV:CAC analysis uses blended CAC as a proxy.
- **Monthly churn uses true monthly rate** — an early version of this analysis incorrectly calculated lifetime logo churn (% of all customers who ever cancelled), producing figures of 17–33%. The corrected metric uses customers lost this month ÷ customers active at the start of the month, which produces the 0.5–4% range shown in the dashboard. See the [learning moment](#-a-mistake-worth-documenting) section below.
- **400 synthetic customers** — all data is generated with a fixed random seed for reproducibility. Distribution assumptions: channels (Google 35%, LinkedIn 15%, Organic 25%, Referral 15%, Product Hunt 10%), plans (Starter 40%, Pro 40%, Business 20%), lifetime churn rate ~28–30%.

---

## 🧠 A Mistake Worth Documenting

During the churn calculation phase, three separate SQL queries — blended, by-month, and by-plan-tier — all returned values between 17% and 33%. The queries were syntactically correct and ran without errors.

The problem was not the SQL. It was the question being asked.

Each query was calculating **lifetime logo churn**: the percentage of all customers who had ever subscribed and subsequently cancelled. This is a useful metric for understanding historical retention, but it is not what a head of growth uses to make monthly decisions. What they need is **true monthly churn**: customers lost this month divided by customers active at the start of that month.

The fix required cross-joining the subscriptions table with a date spine — iterating month by month to ask "how many were active at the start of this month, and how many of those cancelled during it?" True monthly churn came back at 0.5–4%, right in the healthy SaaS range.

**The lesson:** syntactically correct SQL does not guarantee a correct metric. Every KPI definition needs to be pressure-tested — not just for whether the query runs, but for whether it is answering the right question.

---

## 📁 Repository Structure

```
Saas Growth analysis/
├── Dashboard/
│   ├── CSV/
│   │   ├── fact_marketing_spend.csv
│   │   ├── fact_nps.csv
│   │   ├── fact_product_usage.csv
│   │   └── fact_subscriptions.csv
│   ├── TaskFlow Growth Analysis.pbix
│   └── ~TaskFlow Growth Analysis_13996....  (autosave)
├── SQL load/
│   ├── dimensions/
│   │   ├── dim_customers.sql
│   │   ├── dim_date.sql
│   │   └── dim_plans.sql
│   ├── facts/
│   │   ├── fact_marketing_spend.sql
│   │   ├── fact_nps.sql
│   │   ├── fact_product_usage.sql
│   │   └── fact_subscriptions.sql
│   ├── metrics/
│   │   ├── 1_mrr_arpu.sql
│   │   ├── 2_cac.sql
│   │   ├── 3_gross_margin.sql
│   │   ├── 4_ltv.sql
│   │   ├── 5_ltv_cac_ratio.sql
│   │   ├── 6_nps.sql
│   │   ├── 7_churn_rate.sql
│   │   ├── 8_monthly_churn&retention_rate.sql
│   │   └── 9_coversion_rate.sql
│   └── raw/
│       ├── 1_create_staging_tables.sql
│       └── 2_ingesting_staging_tables.sql
├── assets/                             ← create this folder for images
│   ├── erd.png
│   ├── dashboard_overview.png
│   ├── mrr_churn_trend.png
│   ├── ltv_cac_by_plan.png
│   ├── cac_by_channel.png
│   └── nps_breakdown.png
└── README.md
```

---

## 🛠️ Tech Stack

| Tool | Purpose |
|---|---|
| **PostgreSQL** | Data warehouse, star schema, KPI calculations |
| **Python** | Synthetic data generation (seed=42 for reproducibility) |
| **Power BI Desktop** | DAX measures, dashboard build |
| **Git** | Version control (conventional commits: `feat:` `chore:` `fix:`) |

---

## 📬 Connect

Built this as part of my data analytics portfolio. If you're working on something similar or want to talk through the approach, feel free to connect on https://www.linkedin.com/in/briggsdev/