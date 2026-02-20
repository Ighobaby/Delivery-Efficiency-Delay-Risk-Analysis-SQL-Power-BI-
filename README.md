# Delivery Efficiency & Delay Risk Analysis (SQL + Power BI)

## Project Overview

This project analyzes delivery performance across routes, drivers, vehicles, and warehouses to identify delay risks, cost inefficiencies, and operational bottlenecks.

Using SQL for data modeling and business logic, and Power BI for visualization, the project simulates a real world logistics analytics workflow used by operations and supply chain teams to monitor reliability, cost efficiency, and risk exposure.

---

## Business Questions Answered

- What percentage of shipments are delayed overall?
- Which routes have the highest delivery delay risk?
- Which drivers and vehicle types are most exposed to delays?
- What are the main operational reasons for delivery delays?
- How do cost efficiency and delivery reliability compare across routes?
- Which shipments represent the highest operational risk (delayed and high cost)?

---

## Data Model & Architecture

The dataset is modeled using normalized operational tables:

- **Shipments**
- **Drivers**
- **Vehicles**
- **Routes**
- **Warehouses**

A centralized analytical SQL view, **`vw_delivery_efficiency`**, consolidates joins, derives delivery metrics, and serves as a clean BI-ready layer for Power BI.

### Key Engineered Fields
- `DeliveryDays`
- `IsDelayed`
- `CostPerKM`
- `RouteName` (From → To warehouse)
- Driver, Vehicle, Route, and Warehouse attributes

This layered approach mirrors production grade analytics design used in operational reporting systems.

---

## Key Insights

- **33% of shipments were delayed**, indicating meaningful operational risk.
- Several routes show **high delay rates despite low shipment volume**, suggesting structural or operational issues rather than scale effects.
- **Driver level delay rates vary significantly**, revealing risk not visible at aggregate level.
- **Cost efficient routes are not always the most reliable**, highlighting trade offs between speed and cost.
- Delay reasons (weather, staffing, vehicle breakdowns, warehouse backlog) provide **actionable levers for operational improvement**.
- High risk shipments combine **delay + high cost**, enabling prioritization for intervention.

---

## Tools & Skills Used

- **SQL Server (T-SQL)**  
  - Views, Joins, CASE statements, Aggregations
- **Power BI**  
  - DAX Measures, KPIs, Conditional Formatting
- Data Modeling & BI Layer Design
- Operational Analytics (Logistics / Supply Chain)

---

## Outcome

A scalable logistics analytics model that supports:
- Delivery performance monitoring
- Delay risk identification
- Cost efficiency analysis
- Operational decision-making via BI dashboards
