# Business Insights & Recommendations

## Project
Olist E-Commerce Business Analysis

## Objective
Translate the SQL analysis into clear business insights and actionable recommendations for management.

---

## 1. Revenue and Product Strategy

The business generated approximately $13.59 million in product revenue.

Revenue is distributed across several strong product categories rather than depending on only one category. The top 10 categories account for approximately 62.36% of total product revenue.

The strongest categories include:

- health_beauty: $1,258,681.34 in revenue
- watches_gifts: $1,205,005.68
- bed_bath_table: $1,036,988.68
- sports_leisure: $988,048.97
- computers_accessories: $911,954.32

health_beauty is the largest revenue-generating category.

watches_gifts is also strategically important because it generates very high revenue while selling fewer units than some other categories. Its average item price is approximately 201.14.

bed_bath_table has the highest sales volume with 11,115 items sold, but its lower average price results in less revenue than health_beauty and watches_gifts.

### Recommendation

Management should protect inventory availability and marketing support for high-performing categories such as health_beauty, watches_gifts, and bed_bath_table.

The company should also distinguish between high-volume categories and high-value categories when making pricing, inventory, and promotional decisions.

---

## 2. Growth Opportunities

Several product categories experienced strong growth when comparing January-August 2017 with January-August 2018.

Notable growth included:

- home_appliances_2: 597.90%
- home_appliances: 295.72%
- stationery: 264.46%
- baby: 262.77%
- electronics: 247.10%
- watches_gifts: 237.15%
- health_beauty: 211.49%

watches_gifts and health_beauty are particularly attractive because they combine strong growth with already high revenue.

### Recommendation

Management should prioritize categories that combine:

1. Strong existing revenue
2. Strong year-over-year growth
3. Consistent customer demand

watches_gifts and health_beauty appear especially promising for continued investment.

---

## 3. Customer Retention

Customer retention is one of the clearest business opportunities identified in the analysis.

Most customers purchase only once.

Only approximately 3.12% of unique customers placed more than one order in the overall orders dataset.

Among customers with item-level purchase data:

- Repeat customers averaged 310.49 in total spending per customer.
- One-time customers averaged 161.49.
- Repeat customers averaged 2.11 orders.
- One-time customers averaged 1.00 order.

Repeat customers spend approximately 92% more per customer than one-time customers, highlighting a significant retention opportunity.

### Recommendation

The company should focus on converting more first-time buyers into repeat customers.

Potential strategies include:

- Personalized follow-up offers
- Loyalty rewards
- Repeat-purchase discounts
- Product recommendations based on previous purchases
- Email or app re-engagement campaigns

Even a modest improvement in repeat purchasing could create meaningful additional revenue.

---

## 4. Geographic Market Performance

SP is the company's largest market by a significant margin.

SP generated approximately 5.20 million in product revenue and had the largest number of customers and orders.

However, SP's average order value was approximately 143.12, which is lower than several smaller markets.

Some smaller states showed stronger spending per customer.

For example:

- BA average order value: 182.10
- GO average order value: 173.25
- SC average order value: 168.94

This shows that the largest market is not necessarily the market with the highest customer-level value.

### Recommendation

The company should continue protecting its strong position in SP while also investigating opportunities to expand in markets where customers spend more per order.

Regional marketing strategies should consider both total market size and customer value.

---

## 5. Delivery Performance

Delivery performance is generally strong, but meaningful problems remain.

Among 96,470 delivered orders with usable delivery information:

- 88,644 were delivered on time.
- 7,826 were delivered late.
- The late-delivery rate was 8.11%.

Several states had considerably higher late-delivery rates:

- AL: 23.93%
- MA: 19.67%
- PI: 15.97%
- CE: 15.32%
- SE: 15.22%
- BA: 14.04%
- RJ: 13.47%

RJ deserves special attention because it combines a relatively high late-delivery rate with very large delivery volume.

### Recommendation

Management should investigate logistics performance by state rather than relying only on the national delivery rate.

Priority should be given to regions that combine:

- High late-delivery rates
- Large order volumes
- High customer value

Improving logistics in these markets could improve customer satisfaction and potentially support customer retention.

---

## Final Business Recommendations

Based on the analysis, management should focus on four major priorities:

1. Improve customer retention because repeat customers spend significantly more than one-time customers.
2. Reduce late deliveries, especially in high-volume states such as RJ.
3. Protect and expand high-performing categories such as health_beauty and watches_gifts.
4. Use regional strategies that consider both market size and spending per customer.

---

## Analysis Notes

The dataset contains incomplete activity in late 2018, so year-over-year comparisons were made using January-August periods where appropriate.

Some orders do not have matching item-level records, so analyses involving revenue or product information use only orders with available order-item data.

Data-quality issues identified earlier were documented rather than automatically deleting affected records.

