# Colorado Independent Wealth Management Industry Analysis

## Objective

Describe Colorado's SEC-registered investment advisory firms and identify which firms that offer financial planning are growing.

## Datasets

### SEC Registered Investment Adviser Reports

- Source: U.S. Securities and Exchange Commission (monthly Investment Adviser Information Reports, based on Form ADV filings)
- Snapshots: January 2026 and November 2026
- Coverage: Firms with a main office in Colorado (293 in January and 279 in November)
- Metrics:
  - Regulatory Assets Under Management
  - Number of Employees
  - Number and Type of Clients
  - Fee Arrangements (percentage of assets, hourly, fixed, performance-based)
  - Financial Planning Services

## Tools and Techniques

- MySQL
- Data Cleaning (reducing 452 columns to 25, converting text-formatted dollar amounts to numbers and standardizing city names and dates)
- Data Validation
- Self Joins
- Common Table Expressions (CTEs)
- Window Functions (LAG, ROW_NUMBER)
- Ranking Functions
- Conditional Aggregation
- Growth Analysis

## Analysis Process

- Imported and cleaned two monthly SEC adviser reports.
- Selected the 25 relevant columns from the original 452 and gave them readable names.
- Converted asset values stored as text with spaces and commas into numeric values.
- Treated blank client counts as zero, since Form ADV leaves these fields blank when a firm has no clients of that type.
- Standardized city names and converted filing dates to a consistent format.
- Validated the import by checking row counts, zero-asset firms and filing date ranges.
- Compared firms by city, size and whether they offer financial planning.
- Grouped firms into size bands to compare fee structures.
- Matched each firm across the two snapshots to calculate asset growth.
- Ranked the fastest-growing firms that offer financial planning.
- Identified firms that joined or left the Colorado list between snapshots.

## Key Findings

### Location and Size

Analysis showed that Colorado's advisory industry is heavily concentrated in Denver.

Denver had 123 of Colorado's 279 SEC-registered firms (44%), far more than the next city, Greenwood Village, with 26. Denver firms also managed almost three times as much money ($878.6 billion compared with $300.3 billion).

| City              | Firms | Total Assets ($B) | Average Employees |
|-------------------|-------|-------------------|-------------------|
| Denver            | 123   | 878.6             | 41                |
| Greenwood Village | 26    | 300.3             | 331               |
| Boulder           | 23    | 23.2              | 11                |
| Colorado Springs  | 18    | 9.2               | 8                 |
| Centennial        | 11    | 6.3               | 5                 |
| Englewood         | 10    | 12.4              | 32                |

Greenwood Village's average of 331 employees is misleading because one firm, Empower, reports about 8,000 employees. Boulder had 23 firms managing $23.2 billion with an average of 11 employees.

These results suggest that outside Denver the industry is made up largely of small firms, and that averages can be distorted by a single very large company.

### Financial Planning Firms

164 of 279 firms (59%) offered financial planning. A typical planning firm was much smaller than a typical non-planning firm.

| Measure                         | Offers Planning | Does Not Offer Planning |
|---------------------------------|-----------------|-------------------------|
| Firms                           | 164             | 115                     |
| Median Assets                   | ~$300M          | ~$800M                  |
| Median Employees                | 6               | 12                      |
| Serve Individual Clients        | 100%            | 37%                     |
| Charge Hourly Fees              | 60%             | 8%                      |
| Charge Fixed Fees               | 76%             | 23%                     |
| Charge Performance Fees         | 6%              | 53%                     |

Every planning firm served individual clients, while non-planning firms were far more likely to charge performance fees, which suggests they are mainly fund or institutional managers.

These results suggest that financial planning work in Colorado is concentrated in small firms of around six employees that serve individuals directly.

### Fee Structures by Firm Size

Smaller firms were more likely to offer financial planning and to charge hourly or fixed fees.

| Firm Size     | Firms | Offer Planning | Hourly Fees | Fixed Fees | Performance Fees |
|---------------|-------|----------------|-------------|------------|------------------|
| Under $500M   | 152   | 69%            | 47%         | 59%        | 16%              |
| $500M–$2B     | 84    | 56%            | 31%         | 50%        | 32%              |
| Over $2B      | 43    | 28%            | 21%         | 47%        | 44%              |

Almost every firm in every size band charged a percentage of assets (95% to 98%), so the differences between firms lie in the additional fee types they offer.

These findings indicate that as firms grow larger they shift away from planning-based fees and toward investment management and performance-based fees.

### Asset Growth

Of the 257 firms that filed updated figures between the two snapshots, 214 grew and 43 shrank. Median growth in assets was about 14%, and total assets for firms present in both snapshots rose from $1,043 billion to $1,274 billion.

Because most firms invest client money in stocks and bonds, a large part of this growth likely reflects rising markets rather than new clients.

These results suggest that firms growing well above the median are a more meaningful signal of business growth than growth alone.

### Fastest-Growing Financial Planning Firms

Among firms that offer financial planning and manage under $5 billion, the following grew the fastest.

| Firm                        | City              | Assets Jan ($M) | Assets Nov ($M) | Growth | Employees  |
|-----------------------------|-------------------|-----------------|-----------------|--------|------------|
| Israel Investment Advisors  | Denver            | 46              | 96              | 110%   | 4          |
| Tandem Financial            | Greenwood Village | 291             | 542             | 86%    | 6          |
| Heirloom Wealth Management  | Greenwood Village | 614             | 1,108           | 81%    | 18 (+7)    |
| Peak Investment Advisors    | Colorado Springs  | 140             | 235             | 68%    | 2          |
| JFG Family Office           | Denver            | 2,745           | 4,529           | 65%    | 62 (+15)   |
| Jim Saulnier & Associates   | Fort Collins      | 180             | 286             | 59%    | 7          |
| Parsonex Advisory Services  | Englewood         | 175             | 271             | 55%    | 24 (+19)   |
| Infinium Investment Advisors| Denver            | 102             | 155             | 53%    | 2          |
| Cimarron Wealth Management  | Montrose          | 230             | 327             | 42%    | 14         |
| WealthBuilders Investments  | Greenwood Village | 122             | 173             | 41%    | 8          |

Heirloom Wealth Management, JFG Family Office and Parsonex Advisory Services also added staff during the period.

These findings indicate that firms combining strong asset growth with rising headcount are the clearest candidates for continued hiring.

### Firms Joining and Leaving

15 firms joined the Colorado list and 29 left between the two snapshots.

Of the 15 new firms, 10 managed between $100 million and $120 million and 12 offered financial planning. This pattern is consistent with small planning firms growing past the roughly $100 million level at which they move from state to SEC registration.

The data does not explain why firms left. The 29 departures include three Charles Schwab entities in Lone Tree that no longer report a Colorado main office, along with firms that may have closed, merged or relocated.

These results suggest that the SEC list understates the number of small planning firms in Colorado, many of which only appear once they cross the registration threshold.

## Limitations

- Firms under roughly $100 million register with the state rather than the SEC and are not included.
- National firms with Colorado branch offices appear under their headquarters state.
- Asset growth combines market returns with new business, and the data cannot separate the two.
- Two snapshots cover only about one year of change.
- Figures are self-reported. Some values appear to reflect reporting changes rather than real change, such as Empower's employee count rising from 822 to 8,051.

## Conclusion

This analysis shows that Colorado's advisory industry is concentrated in Denver but is made up largely of small firms, particularly among those offering financial planning. A typical planning firm manages around $300 million and employs about six people, roughly half the size of a typical firm that does not offer planning.

Fee structures change with firm size. Smaller firms rely more on hourly and fixed planning fees, while larger firms lean toward investment management and performance-based fees.

Most firms grew their assets over the period, although much of this growth likely reflects market performance. Firms that grew well above the median and added staff, such as Heirloom Wealth Management, JFG Family Office and Parsonex Advisory Services, stand out as the strongest signals of business expansion.

Overall, the findings suggest that opportunities in Colorado financial planning are spread across many small, growing firms rather than concentrated in a few large employers, and that public regulatory data can be used to identify them.
