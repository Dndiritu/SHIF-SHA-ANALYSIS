#📊 SHIF/SHA Effectiveness Evaluation Dashboard By David Ndiritu
#Project Overview
This project explores and evaluates the effectiveness of the Social Health Insurance Fund (SHIF) and the Social Health Authority (SHA) using mock-generated healthcare data. It simulates real-world health insurance operations in Kenya and examines contribution behavior, healthcare utilization, claim approvals, and subsidy allocations.

The goal is to demonstrate how data analysis and visualization tools like Excel, Power BI, and Tableau can support policy evaluation, performance monitoring, and strategic decisions in the healthcare sector.

## 🎯 Objectives & Analytical Tasks

### 1. Enrollment & Demographics
- Distribution of members by *income level* and *employment status*
- Comparison of *subsidized vs. non-subsidized* members by region
- *Average age* of members by region 

### 2. Contributions & Penalties
- Total **monthly contributions
- Members with *penalties above 100 KES*
- *Top 5 employers* by contribution amount

### 3. Healthcare Services Utilization
- Most *utilized healthcare services*
- *Out-of-pocket expenses* by service type and region
- High-cost members with *low insurance coverage* 

### 4. Provider Performance
- Providers with the *highest service volumes*
- Analysis of *recently accredited providers* and their *claim approval rates*

### 5. Claims Analysis
- Total *claim amounts* segmented by status (Approved, Pending, Rejected)
- Detection of *discrepancies* between claim amount and covered services

### 6. Survey & Sentiment
- *Average satisfaction scores* by region
- Relationship between *trust* and *satisfaction levels* 

### 7. Legal Risks
- Count of *pending legal cases*
- Legal cases by *impact level* and *average filing duration*

### 🔍 Advanced Insights
- *Healthcare utilization profile* for each member 
- Combining *high-penalty* and *low-satisfaction* members into a *high-risk group* 

#⚙️ Tools & Technologies
SQL – For querying and joining relational datasets

Excel – Preliminary data cleaning and exploration

Power BI – Interactive dashboards with DAX measures and rolling averages

Tableau – Advanced visual storytelling and KPI monitoring

GitHub – Project collaboration and sharing

#📁 Project Structure
sql
Copy
Edit
📂 SHIF-SHA-Dashboard-Project
│
├── 📊 Excel Analysis/
│   └── Pre-aggregated insights & pivot charts
│
├── 📈 PowerBI/
│   └── PBIX file with Core Dashboard Pages (KPIs, Claims, Financial Trends)
│
├── 📉 Tableau/
│   └── TWB or TDSX file with calculated fields and sparklines
│
├── 📑 SQL Queries/
│   └── Sample joins, KPI calculations, claim approval logic
│
├── 📄 README.md

#📌 Key Dashboards & Questions Answered
🔹 Core Member & Financial Overview
Monthly contributions and 3-month rolling averages

Contribution gaps by region vs. target

Members by income level, employment, subsidy

🔹 Claims & Utilization Insights
Claim approval trends over time and service types

Out-of-pocket vs. cost covered by insurance

Services utilized by members (heatmaps and treemaps)

🔹 Executive Summary (Tableau)
KPI Cards with sparklines:

Average Contribution

% Subsidized

Average Utilization

Approval Rate

🧠 Learning Objectives
Build ETL-like data workflows from raw to dashboard

Practice DAX & calculated fields for KPIs

Apply rolling averages, filters, and conditional formatting

Learn how to present complex health financing systems visually

## 📊 Dashboards & Visuals

> ✨ Below are sample dashboards and visuals generated from the analysis

### Tableau Dashboard
![Screenshot 2025-05-04 164902](https://github.com/user-attachments/assets/c87dee88-46eb-476e-aaf3-90e09eb09e02)
![Screenshot 2025-05-04 165052](https://github.com/user-attachments/assets/9a760046-b812-45eb-887d-8431686080aa)

### Power BI Dashboard
![Screenshot 2025-05-04 164420](https://github.com/user-attachments/assets/0fdb0ebf-ecbc-4de2-99dc-462faede2bb1)

### Excel Summary Chart
![Screenshot 2025-05-04 164142](https://github.com/user-attachments/assets/052ac0f3-359c-4179-a2f2-b414378beb02)

## 📝 Notes  This analysis was performed on a synthetic dataset and does not reflect real-world SHIF/SHA data

📬 Feedback & Contributions
Feel free to open issues or pull requests if you'd like to improve or extend this mock evaluation. This is a sandbox project for educational and analytical growth.

