# Australian Formula Step 1 V0 - Population & Payouts

## Basic Population Data (2025 estimates)

| Category | Count | Source |
|----------|--------|---------|
| Total Population | 27,300,000 | ABS 2025 projection |
| Adults (20+) | 21,600,000 | 79% of total (ABS age pyramid) |
| Youth (under 20) | 5,700,000 | 21% of total |

## Per-Person Allocation (Version 0.1)

### Adults (20+): $416,000 each
| Component | Amount | Notes |
|-----------|---------|-------|
| Income-producing assets | $104,000 | Business/investment credit |
| Housing credit | $104,000 | Mortgage offset or deposit assistance |
| Weekly cash (5 years) | $208,000 | $800/week × 260 weeks |
| **Total per adult** | **$416,000** | |

### Youth (under 20): $416,000 each
| Component | Amount | Notes |
|-----------|---------|-------|
| Income-producing assets | $104,000 | Held in trust until 20 |
| Housing credit | $52,000 | Half allocation |
| Weekly cash (5 years) | $104,000 | $400/week × 260 weeks |
| Future trust fund | $156,000 | Additional trust for age 20+ |
| **Total per youth** | **$416,000** | |

## Total Funding Required

| Category | Population | Per Person | Total Cost |
|----------|------------|------------|------------|
| Adults | 21,600,000 | $416,000 | $8,985,600,000,000 |
| Youth | 5,700,000 | $416,000 | $2,371,200,000,000 |
| **GRAND TOTAL** | **27,300,000** | **$416,000** | **$11,356,800,000,000** |

## Summary
- **Total required funding: $11.36 trillion**
- **Available national wealth: $19 trillion**
- **After debt clearance ($1.5T) and 5-year government pre-funding ($4.5T): $13T available**
- **Buffer remaining: $1.64 trillion** (14.4% safety margin)

## Formulas (for Excel/spreadsheet recreation)
```
Adult_total = Adults_count × Adult_payout
Youth_total = Youth_count × Youth_payout
Grand_total = Adult_total + Youth_total
Buffer = Available_wealth - Grand_total
Safety_margin = Buffer ÷ Grand_total
```

## Status: ✅ FEASIBLE
The mathematics work. Total requirement ($11.36T) is well within available national wealth after essential allocations.

---
*Version 0.1 - Created [Date]*  
*Next step: Asset mapping to identify funding sources*
