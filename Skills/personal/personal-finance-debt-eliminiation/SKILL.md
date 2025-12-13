---
name: personal-finance-debt-elimination
description: Personal finance strategy and debt elimination plan for Mike Heckathorn. Use when reviewing monthly finances, running YNAB analysis scripts, making spending decisions, checking budget fit, calculating debt payoff progress, planning travel fund usage, evaluating budget adjustments, or creating financial reports. Triggers on "budget", "debt payoff", "YNAB", "spending", "financial analysis", or finance-related requests for Mike.
---

# Personal Finance & Debt Elimination Strategy

**Owner:** Stegmaier
**Budget:** Joint Checking (YNAB)
**Analysis Date:** November 11, 2025
**Analysis Period:** Last 3 months (Aug-Nov 2025)
**Target Debt-Free:** February 2027 (15 months)

---

## FINANCIAL OVERVIEW

### Income
- **Monthly Income:** $11,666

### Current Debt (Joint Checking Only)
**Total Debt:** $33,395

| Debt | Balance | APR | Minimum | Current Payment | Notes |
|---|---|---|---|---|---|
| USAA Credit Card | $28,204 | 13.90% | $576 | $1,239 | Primary debt to eliminate |
| Sewing & More Synchrony | $2,451 | 0.00% | $84 | $84 | 0% promo until July 2028 |
| Subaru Auto Loan | $2,741 | 2.79% | $252 | $252 | Paying minimums only (may transfer to son) |

**Additional Debt (Not in Joint Checking):**
- Megan Student Loans: $32,000 @ 4.5% APR, $300/month (paid from Megan's personal account)

### Bills (Monthly): $5,848
Breakdown:
- Mortgage: $2,975
- Property Taxes: $1,033
- Child Support: $473
- Megan Auto Lease: $312 (NOT debt - keeping as bill)
- Insurance: $183
- Internet: $200
- Phone: $162
- Utilities: $134
- Other bills: $376

---

## CURRENT SPENDING (3-Month Average)

### Food: $2,534/month (61% OVER TARGET)
- Groceries: $1,637
- Restaurants: $449
- Take-Out: $377
- Coffee: $71

**Problem:** Shopping at Hy-Vee every 1.7 days (106 visits in 6 months)

### Discretionary: $2,781/month
**Mike Categories ($783/month):**
- Mike Stuff: $222
- Gym/BJJ: $166 (actual dues: $123)
- Comics & Books: $160
- Therapy: $77 (keep - mental health)
- Mike Savings: $75
- Clothes: $42
- Guitar: $40

**Megan Categories ($539/month):**
- Megan Clothes: $218
- Megan Fitness: $166 (increasing to $200)
- Megan Stuff: $141
- Crafts: $15

**Goals & Debt ($167/month):**
- Mike Roth IRA: $167 (pausing during debt payoff)

**Family ($338/month):**
- Pet Stuff: $207 (KEEP - essential healthcare, reimbursed)
- Judah Stuff: $109
- Gas Money: $22

**General Expenses ($921/month):**
- Home Repairs & Maintenance: $402
- Entertainment: $269
- Subscriptions: $187
- Healthcare/Medical: $59
- Donations: $3

### Current Debt Payments: $1,575/month
- USAA Credit Card: $1,239
- Synchrony: $84 (included in USAA CC category)
- Subaru: $252

**Total Current Expenses:** $12,738
**Monthly Shortfall:** -$1,072 (going deeper into debt)

---

## AGGRESSIVE DEBT ELIMINATION PLAN

### Strategy: Debt Snowball (Smallest to Largest, Excluding Subaru)

**Total Cuts Required:** $2,213/month
- Food cuts: $959/month
- Discretionary cuts: $1,254/month

**Allocation:**
- Balance budget: $1,072/month
- Travel savings (HYSA): $100/month
- **Aggressive debt payoff: $1,041/month**

### Adjusted Spending Targets

**FOOD: $1,575/month** (Cut $959)
- Groceries: $1,000 (shop at Aldi once per week)
- Restaurants: $400
- Take-Out: $150
- Coffee: $25

**MIKE: $325/month** (Cut $458)
- Mike Stuff: $50
- **Mike BJJ: $123** (KEEP - non-negotiable, actual dues)
- Comics & Books: $50
- **Therapy: $77** (KEEP - mental health)
- Mike Savings: $0 (redirect to debt)
- Clothes: $25
- Guitar: $0 (pause)

**MEGAN: $320/month** (Cut $219)
- Megan Clothes: $50
- **Megan Fitness: $200** (INCREASE - prioritized)
- Megan Stuff: $70
- Crafts: $0 (pause)

**GOALS & DEBT: $100/month** (Cut $67)
- Roth IRA: $0 (pause during debt payoff)
- **Travel Fund: $100** (NEW - save to HYSA)

**FAMILY: $257/month** (Cut $81)
- **Pet Stuff: $207** (KEEP - essential pet healthcare, insulin/meds reimbursed)
- Judah Stuff: $50
- Gas Money: $0

**GENERAL EXPENSES: $528/month** (Cut $393)
- Home Repairs: $250 (emergency only)
- Entertainment: $100
- Subscriptions: $150 (audit and cancel)
- Healthcare: $25 (defer non-urgent)
- Donations: $0 (pause)

### Debt Payoff Timeline

**Phase 1: Synchrony (Months 1-3)**
- Aggressive payment: $1,125/month ($84 + $1,041 extra)
- **Paid off: February 2026** (Month 3)

**Phase 2: USAA Credit Card (Months 4-15)**
- Aggressive payment: $1,701/month ($576 + $1,041 extra + $84 from Synchrony)
- **Paid off: February 2027** (Month 15)

**Subaru Decision Point:**
- Continue minimum payments
- May transfer to son
- Or pay off after USAA cleared

**Interest Saved:** $1,800
**Time Saved:** 12 months earlier than current path

---

## KEY ACTION ITEMS

### Week 1 Critical Actions:
- [ ] Delete DoorDash, Uber Eats, Grubhub apps
- [ ] Delete Amazon app (Mike & Megan)
- [ ] Delete Starbucks app
- [ ] Set up all YNAB budgets
- [ ] Open/link HYSA for travel fund
- [ ] Start Sunday meal planning
- [ ] Switch to Aldi for groceries
- [ ] Cancel unused subscriptions

### YNAB Budget Categories Setup:
All categories listed above with specific monthly targets

### Monthly Tracking:
Run these scripts on day 1 of each month:
```bash
cd ~/github_repos/Finance-Bot

# 3-month spending analysis
python scripts/ynab_analysis/spending_analyzer.py

# 3-month food analysis
python scripts/ynab_analysis/food_analyzer.py

# 3-month cashflow & debt projections
python scripts/ynab_analysis/cashflow_analyzer.py
```

---

## FOOD SPENDING STRATEGIES

### Groceries (Cut $637/month):
- Shop ONCE per week at Aldi (not Hy-Vee)
- Meal plan every Sunday
- Use shopping list (no impulse buys)
- Buy generic/store brands
- Never shop hungry
- Use grocery pickup
- Reduce meat consumption

### Take-Out (Cut $227/month):
- DELETE all delivery apps
- Meal prep every Sunday (3-4 meals)
- Keep emergency quick meals
- Crockpot meals
- Double batch and freeze

### Coffee (Cut $46/month):
- Make at home (invest in good coffee maker)
- Buy beans in bulk
- Limit Starbucks to 1x/month

### Restaurants (Cut $49/month):
- Limit to 2-3x per month
- Share entrees
- Skip appetizers/drinks
- Water instead of soda

---

## SPENDING INSIGHTS FROM ANALYSIS

### Food Patterns:
- **Hy-Vee visits:** 106 in 6 months = every 1.7 days (TOO FREQUENT)
- **Fast food:** Taco Bell (23x), McDonald's (17x) = $854 in 6 months
- **Coffee shops:** Starbucks 26 visits = $373
- **Highest spending days:** Monday & Sunday

### Discretionary Patterns:
- **Megan Stuff (Amazon):** 111 transactions in 6 months = 18.5/month
- **Mike Stuff:** Random purchases need 48-hour rule
- **Subscriptions:** Need audit and cancellation

---

## NON-NEGOTIABLES (Keep/Prioritize)

1. **Mike BJJ:** $123/month - Physical and mental health
2. **Mike Therapy:** $77/month - Mental health
3. **Megan Fitness:** $200/month - Physical health (increased from $166)
4. **Pet Stuff:** $207/month - Essential healthcare for aging dog (insulin/meds reimbursed after $1k deductible)
5. **Travel Fund:** $100/month - Saves to HYSA for motivation and rewards

---

## MILESTONE CELEBRATIONS

- **Month 3 (Feb 2026):** Synchrony PAID OFF → Dinner at home
- **Month 8 (Jul 2026):** Halfway through USAA CC + $600 travel fund → Weekend getaway
- **Month 15 (Feb 2027):** USAA CC PAID OFF + $1,500 travel fund → **Celebration trip!**

---

## POST-DEBT-FREE PLAN (March 2027+)

**Monthly cash flow freed:** $1,701

**Recommended allocation:**
- Resume Roth IRA: $500/month
- Increase travel fund: $500/month (5x increase)
- Savings: $300/month
- Resume hobbies: $100/month
- Extra mortgage principal: $300/month

**Or help Megan with student loans:**
- Combined with Megan's $300 = $2,001/month
- Student loans paid in 17 months
- **Completely debt-free (all debt): July 2028**

---

## IMPORTANT CONTEXT

### Budget Accounts:
- Joint Checking has 4 accounts:
  - USAA Main Checking (cash)
  - Amazon Card (credit)
  - Chase Freedom (credit)
  - Chase Sapphire (credit)
- Credit card spending IS captured and categorized
- "Uncategorized" transactions are account transfers (paying off cards)

### Special YNAB Categories (Exclude from Overspending Analysis):
- **Travel:** Employer reimbursed
- **Uncategorized:** Not yet categorized (needs attention)
- **Surplus:** Temporary holding for savings/debt allocation
- **Stuff I Forgot to Budget For:** Budget buffer
- **USAA Credit Card:** Debt payment category

### Analysis Period:
- Use **3 months** for current spending analysis
- Provides more accurate recent picture
- 6-month analysis showed higher discretionary ($4,281) due to one-time purchases
- 3-month average shows discretionary at $2,781 (more realistic)

---

## SUCCESS METRICS

Track monthly:

| Metric | Current | Target | Status |
|---|---|---|---|
| Monthly Shortfall | -$1,072 | $0 | 🔴 Critical |
| Food Spending | $2,534 | $1,575 | 🔴 Cut $959 |
| Discretionary | $2,781 | $1,470 | 🔴 Cut $1,311 |
| Travel Fund (HYSA) | $0 | +$100/mo | 🎯 New |
| Extra Debt Payment | $663 | $1,041 | 🔴 Increase |
| Total Debt | $33,395 | Decreasing | Track |
| Months to Freedom | 27 | 15 | 🎯 Save 12mo |

---

## REPOSITORY & FILES

**Location:** `/Users/heckatron/github_repos/Finance-Bot/`

**Key Files:**
- `Files/YNAB PAT.md` - YNAB API token
- `scripts/ynab_analysis/ynab_client.py` - YNAB API wrapper
- `scripts/ynab_analysis/spending_analyzer.py` - Overall spending analysis
- `scripts/ynab_analysis/food_analyzer.py` - Food-specific analysis
- `scripts/ynab_analysis/cashflow_analyzer.py` - Cashflow & debt projections
- `docs/debt_elimination_plan.md` - Original debt plan (Sept 2027 target)

**Current Reports:**
- `reports/FINAL_AGGRESSIVE_PLAN.md` - Complete plan with all adjustments
- `reports/AGGRESSIVE_DEBT_PAYOFF_PLAN.md` - Detailed action plans
- `reports/DEBT_ELIMINATION_SUMMARY.md` - Quick reference
- `reports/COMPLETE_FINANCIAL_ANALYSIS_3MONTH.md` - 3-month analysis
- `reports/cashflow_analysis_AGGRESSIVE_2025-11-11.txt` - Latest output

---

## PHILOSOPHY

**This is not deprivation - it's prioritization:**
- Cutting waste, not life
- Pausing non-essentials temporarily (15 months)
- Maintaining health and wellness
- Building travel fund for motivation
- Still supporting family

**The goal:** 15 months of focused effort = Lifetime of financial freedom

**Balance:** Aggressive debt payoff + essential quality of life + small rewards (travel fund)
