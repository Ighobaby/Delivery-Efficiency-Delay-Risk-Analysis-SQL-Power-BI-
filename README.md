DELIVERY EFFICIENCY AND DELAY RISK ANALYSIS

SQL Server • Power BI • Operational Analytics


## Project Overview

  This project analyzes delivery performance across routes, drivers, and vehicle types to identify delay risk, cost exposure, and operational inefficiencies in a simulated logistics network.
  
  The workflow mirrors a real world analytics setup:
  
  SQL Server is used for data modeling, feature engineering, and business logic
  
  Power BI is used for KPI tracking, risk analysis, and decision support visualisation
  
  The result is a BI ready operational dashboard that logistics and supply chain teams could use to monitor reliability, cost efficiency, and delay drivers.


## Business Problems Addressed

  How reliable is the delivery operation overall?
  
  Which routes pose the highest delay risk?
  
  Are some drivers consistently more exposed to delays?
  
  What are the main operational causes of late deliveries?
  
  How does cost efficiency trade off against reliability?
  
  Where should operations teams focus intervention first?


## Data Model & Architecture

  The dataset is modeled using normalized operational tables:
  
  Shipments
  
  Routes
  
  Drivers
  
  Vehicles
  
  Warehouses
  
  A single consolidated SQL view vw_delivery_efficiency serves as the analytics layer consumed directly by Power BI.


## Key Engineered Fields (SQL)

  DeliveryDays: Delivery duration in days
  
  IsDelayed: Binary delay flag (on time vs delayed)
  
  DelayReason: Operational cause of delay
  
  CostPerKM: Cost efficiency metric
  
  DelayRiskScore: Composite operational risk score
  
  RouteName: Human readable From → To route
  
  This layered design mirrors production grade BI architecture, separating raw operational data from analytical logic.


## Dashboard Overview (Power BI)

  The Power BI report answers the business questions through the following views:

KPI SUMMARY

  Total Shipments
  
  Shipments Delayed
  
  Overall Delay Rate
  
  Average Delay Risk Score
  
  Average Cost per KM


ROUTE RISK ANALYSIS

  Routes ranked by average delay risk
  
  Identification of structurally risky routes (not just high volume)


DELAY DRIVERS

  Breakdown of delay reasons by route
  
  Highlights operational bottlenecks such as:
  
  Traffic congestion
  
  Vehicle breakdowns
  
  Staff shortages
  
  Warehouse backlog
  
  Severe weather


DRIVER RISK & RELIABILITY

  Driver level shipment volume
  
  Delay rate per driver
  
  Average risk score
  
  Experience vs reliability comparison


COST EFFICIENCY VS DELAY RISK

  Scatter plot comparing:
  
  Cost per KM (efficiency)
  
  Delay risk exposure
  
  Demonstrates that cheapest routes are not always the most reliable


DELIVERY TIME DISTRIBUTION

  Distribution of delivery durations (1, 2, 3+ days)
  
  Highlights consistency and variability in service levels



## Key Insights

  36% of shipments were delayed, indicating meaningful operational risk
  
  Certain routes show high risk despite low volume, suggesting structural issues
  
  Driver performance varies significantly, exposing hidden reliability risk
  
  Lower cost per KM does not guarantee delivery reliability
  
  Delay reasons provide actionable levers for operational improvement
  
  Risk scoring enables prioritisation of high impact interventions


## Tools & Skills Demonstrated

SQL Server (T-SQL)

  Views, joins, CASE logic, aggregations

  Business rule implementation

Power BI

  DAX measures

  KPI cards

  Drill-downs & tooltips

Data modeling & BI layer design

Operational & logistics analytics

Translating raw data into executive ready insights


## Outcome

  A realistic, interview ready logistics analytics project demonstrating the ability to:
  
  Design a clean analytical data layer
  
  Engineer operational risk metrics
  
  Build clear, decision focused BI dashboards
  
  Communicate insights relevant to supply chain and operations teams
