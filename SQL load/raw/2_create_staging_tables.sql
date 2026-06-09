CREATE SCHEMA IF NOT EXISTS raw;


-- ────────────────────────────────────────────────────────────
-- MIXPANEL
-- ────────────────────────────────────────────────────────────
CREATE TABLE raw.events(
    distinct_id TEXT,
    event_type TEXT, -- renamed from 'event' in source
    time TIMESTAMP,
    mp_country_code TEXT,
    platform TEXT,
    feature_name TEXT,
    plan TEXT,
    session_id TEXT,
    insert_id TEXT, -- renamed from $insert_id (Mixpanel reserved field)

     -- deduplication: Mixpanel guarantees insert_id uniqueness
    CONSTRAINT events_raw_pk UNIQUE (insert_id)
);


-- ────────────────────────────────────────────────────────────
-- STRIPE
-- ────────────────────────────────────────────────────────────

CREATE TABLE raw.customers(
    customer_id TEXT, --renamed from 'id' in source
    email TEXT,
    date_created TIMESTAMP, --renamed from 'created' in scource
    currency TEXT,
    delinquent BOOLEAN,
    description  TEXT,
    name TEXT,
    plan_at_signup TEXT, --renamed from 'metadata.plan_at_signup' in source
    acquisition_channel TEXT, --renamed from 'metadata.acquisition_channel' in source
    country TEXT, --renamed from 'metadata.country' in source
    CONSTRAINT customers_raw_pk UNIQUE (customer_id)
);

-- ------------------------------------------------------------

CREATE TABLE raw.products (
    product_id      TEXT        NOT NULL,   -- renamed from 'id'
    name            TEXT,
    description     TEXT,
    active          TEXT,                   -- load as TEXT, cast to BOOLEAN in dim_plans
    date_created    TIMESTAMPTZ,            -- renamed from 'created'
    date_updated    TIMESTAMPTZ,            -- renamed from 'updated'
    tier            TEXT,                   -- renamed from 'metadata.tier'

    CONSTRAINT products_raw_pk UNIQUE (product_id)
);

-- ------------------------------------------------------------

CREATE TABLE raw.prices (
    price_id            TEXT        NOT NULL,   -- renamed from 'id'
    product_id          TEXT,                   -- renamed from 'product', FK to raw.products
    unit_amount         INTEGER,                -- in cents e.g. 2500 = $25.00
    currency            TEXT,
    billing_interval    TEXT,                   -- renamed from 'recurring.interval'
    interval_count      INTEGER,                -- renamed from 'recurring.interval_count'
    active              TEXT,
    nickname            TEXT,

    CONSTRAINT prices_raw_pk UNIQUE (price_id)
);


-- ------------------------------------------------------------

CREATE TABLE raw.subscriptions (
    subscription_id         TEXT        NOT NULL,   -- renamed from 'id'
    customer_id             TEXT,                   -- renamed from 'customer', FK to raw.customers
    status                  TEXT,                   -- active | canceled | past_due
    current_period_start    TIMESTAMPTZ,
    current_period_end      TIMESTAMPTZ,
    canceled_at             TIMESTAMPTZ,            -- NULL = still active
    cancel_at_period_end    TEXT,
    plan_id                 TEXT,                   -- renamed from 'plan.id', FK to raw.prices
    plan_amount             INTEGER,                -- renamed from 'plan.amount', in cents
    plan_interval           TEXT,                   -- renamed from 'plan.interval'
    plan_product            TEXT,                   -- renamed from 'plan.product'
    quantity                INTEGER,
    trial_start             TIMESTAMPTZ,
    trial_end               TIMESTAMPTZ,
    acquisition_channel     TEXT,                   -- renamed from 'metadata.acquisition_channel'

    CONSTRAINT subscriptions_raw_pk UNIQUE (subscription_id)
);


-- ------------------------------------------------------------

CREATE TABLE raw.invoices (
    invoice_id      TEXT        NOT NULL,   -- renamed from 'id'
    customer_id     TEXT,                   -- renamed from 'customer', FK to raw.customers
    status          TEXT,                   -- paid | uncollectible | void
    amount_due      INTEGER,                -- in cents
    amount_paid     INTEGER,                -- in cents
    currency        TEXT,
    period_start    TIMESTAMPTZ,
    period_end      TIMESTAMPTZ,
    date_created    TIMESTAMPTZ,            -- renamed from 'created'
    subscription_id TEXT,                   -- renamed from 'subscription'
    plan_product    TEXT,                   -- renamed from 'plan.product'

    CONSTRAINT invoices_raw_pk UNIQUE (invoice_id)
);


-- ────────────────────────────────────────────────────────────
-- HUBSPOT
-- ────────────────────────────────────────────────────────────

CREATE TABLE raw.hubspot_contacts (
    vid                     INTEGER     NOT NULL,   -- HubSpot contact ID
    email                   TEXT,
    firstname               TEXT,
    lastname                TEXT,
    date_created            TIMESTAMPTZ,            -- renamed from 'createdate'
    date_modified           TIMESTAMPTZ,            -- renamed from 'lastmodifieddate'
    lead_status             TEXT,                   -- renamed from 'hs_lead_status'
    lifecycle_stage         TEXT,
    acquisition_source      TEXT,                   -- renamed from 'hs_analytics_source'
    country                 TEXT,
    company                 TEXT,
    job_title               TEXT,                   -- renamed from 'jobtitle'
    num_associated_deals    INTEGER,
    stripe_customer_id      TEXT,                   -- custom property, joins to raw.customers
    auth_user_id            TEXT,                   -- custom property, joins to raw.auth_users

    CONSTRAINT hubspot_contacts_raw_pk UNIQUE (vid)
);



-- ────────────────────────────────────────────────────────────
-- AUTH / APP DATABASE
-- ────────────────────────────────────────────────────────────

CREATE TABLE raw.auth_users (
    user_id             TEXT        NOT NULL,   -- renamed from 'id', UUID
    email               TEXT,
    email_verified      TEXT,                   -- load as TEXT, cast later
    date_created        TIMESTAMPTZ,            -- renamed from 'created_at'
    date_updated        TIMESTAMPTZ,            -- renamed from 'updated_at'
    last_sign_in_at     TIMESTAMPTZ,
    auth_provider       TEXT,                   -- renamed from 'raw_app_meta_data.provider'
    stripe_customer_id  TEXT,                   -- join key to raw.customers
    is_deleted          TEXT,                   -- load as TEXT, cast later
    timezone            TEXT,
    locale              TEXT,

    CONSTRAINT auth_users_raw_pk UNIQUE (user_id)
);


-- ────────────────────────────────────────────────────────────
-- TYPEFORM (NPS)
-- ────────────────────────────────────────────────────────────

CREATE TABLE raw.nps_responses (
    response_id         TEXT        NOT NULL,   -- renamed from 'response_id'
    submitted_at        TIMESTAMPTZ,
    user_id             TEXT,                   -- renamed from 'hidden.user_id', joins to raw.auth_users
    plan                TEXT,                   -- renamed from 'hidden.plan'
    country             TEXT,                   -- renamed from 'hidden.country'
    nps_score           INTEGER,                -- renamed from 'question.nps_score', 0–10
    reason              TEXT,                   -- renamed from 'question.reason'
    feature_request     TEXT,                   -- renamed from 'question.feature_request'

    CONSTRAINT nps_responses_raw_pk UNIQUE (response_id)
);


-- ────────────────────────────────────────────────────────────
-- AD PLATFORMS
-- ────────────────────────────────────────────────────────────

CREATE TABLE raw.google_ads (
    date                    DATE        NOT NULL,
    campaign_name           TEXT,
    campaign_id             TEXT,
    impressions             INTEGER,
    clicks                  INTEGER,
    cost_usd                NUMERIC(10,2),
    conversions             INTEGER,
    ctr                     NUMERIC(6,2),       -- click-through rate %
    avg_cpc_usd             NUMERIC(8,2),       -- renamed from 'avg_cpc_usd'
    conversion_rate         NUMERIC(6,2),
    cost_per_conversion     NUMERIC(10,2)       -- NULL when conversions = 0
);


-- ------------------------------------------------------------

CREATE TABLE raw.linkedin_ads (
    start_date          DATE,
    end_date            DATE,
    campaign_name       TEXT,
    campaign_id         TEXT,
    impressions         INTEGER,
    clicks              INTEGER,
    spend_usd           NUMERIC(10,2),
    leads               INTEGER,
    avg_cpc_usd         NUMERIC(8,2),
    cost_per_lead_usd   NUMERIC(10,2),          -- NULL when leads = 0
    objective           TEXT
);

