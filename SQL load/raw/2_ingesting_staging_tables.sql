COPY raw.events
FROM 'D:\SQL Projects\Saas Growth analysis\CSV\mixpanel_events.csv'
WITH(FORMAT csv,HEADER true, DELIMITER ',',ENCODING 'UTF8');

COPY raw.customers
FROM 'D:\SQL Projects\Saas Growth analysis\CSV\stripe_customers.csv'
WITH(FORMAT csv,HEADER true, DELIMITER ',',ENCODING 'UTF8');


COPY raw.products
FROM 'D:\SQL Projects\Saas Growth analysis\CSV\stripe_products.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY raw.prices
FROM 'D:\SQL Projects\Saas Growth analysis\CSV\stripe_prices.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY raw.subscriptions
FROM 'D:\SQL Projects\Saas Growth analysis\CSV\stripe_subscriptions.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY raw.invoices
FROM 'D:\SQL Projects\Saas Growth analysis\CSV\stripe_invoices.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY raw.hubspot_contacts
FROM 'D:\SQL Projects\Saas Growth analysis\CSV\hubspot_contacts.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY raw.auth_users
FROM 'D:\SQL Projects\Saas Growth analysis\CSV\auth_users.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY raw.nps_responses
FROM 'D:\SQL Projects\Saas Growth analysis\CSV\typeform_nps_responses.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY raw.google_ads
FROM 'D:\SQL Projects\Saas Growth analysis\CSV\google_ads_campaigns.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY raw.linkedin_ads
FROM 'D:\SQL Projects\Saas Growth analysis\CSV\linkedin_ads_campaigns.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');




