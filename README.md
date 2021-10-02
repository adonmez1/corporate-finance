# corporate-finance

- "north-america-daily-cumulative-returns.sas" calculates 1, 3, 6, and 12 months cumulative raw returns from Compustat North America daily security data using WRDS Cloud Database.

- "cumulative-return-between-two-arbitrary-dates.sas" calculates the cumulative raw returns between two arbitary dates for observations having a dummy variable equal to 1. This code assumes that Compusast daily security data has unique observations in gvkey-date pair.

- "compustat-fundamentals-key-variables.dta" generates several firm-specific variables such as market value, leverage ratio, and book-to-market ratio from Compustat North America annual fundamentals data.
