# Delivery Efficiency & Delay Risk Analysis (SQL + Power BI)

## Project Overview
This project analyzes delivery performance across routes, drivers, vehicles, and warehouses to identify **delay risk**, **cost inefficiencies**, and **operational bottlenecks**.

The solution mirrors a real world logistics analytics workflow used by operations and supply chain teams, combining **SQL based data modeling** with **Power BI dashboards** for decision support.

---

## Business Questions Answered
- What percentage of shipments are delayed overall?
- Which routes carry the highest delivery delay risk?
- How do driver experience and vehicle type impact delivery reliability?
- What are the primary operational causes of delays?
- How do cost efficiency and delivery reliability trade off across routes?
- Which shipments represent the highest operational risk (delay + cost)?

---

## Data Model & Architecture
The dataset is modeled using normalized operational tables:
- **Shipments** (fact table)
- **Drivers**
- **Vehicles**
- **Routes**
- **Warehouses**

A centralized analytics view, **`vw_delivery_efficiency`**, consolidates joins, derives business metrics, and acts as a **BI ready semantic layer** for Power BI.

### Key Engineered Metrics
- `DeliveryDays`
- `IsDelayed`
- `CostPerKM`
- `DelayRiskScore` (composite operational risk metric)
- Route, Driver, Vehicle, and Warehouse attributes

This layered design reflects **production grade BI architecture** used in operational reporting systems.

---

## Power BI Dashboard Overview

### Executive KPIs
- **Total Shipments**
- **Overall Delay Rate**
- **Average Delivery Days**
- **Average Cost per KM**

These KPIs provide an at a glance view of delivery performance and risk exposure.

### Operational Risk Analysis
- **Delay Rate by Route**: identifies structurally risky routes
- **Driver Delay Rate**: highlights reliability variation across drivers
- **Vehicle Type vs Delay Rate**: surfaces asset related risk
- **Primary Delay Causes**: operational bottleneck breakdown

### Cost vs Reliability
- **Cost Efficiency vs Delay Risk** scatter plot highlights trade offs between cost and reliability.
- High risk shipments (delayed + high cost) are easily identifiable for prioritised intervention.

---

## Key Insights
- Approximately **one-third of shipments experience delays**, indicating material operational risk.
- Several routes show **high delay rates despite low shipment volume**, suggesting structural issues.
- **Driver level delay rates vary significantly**, revealing risk not visible at aggregate level.
- **Cost efficient routes are not always the most reliable**, highlighting operational trade offs.
- Delay reasons (traffic, weather, staffing, vehicle issues) provide **clear levers for improvement**.
- The **DelayRiskScore** enables proactive risk prioritisation rather than reactive reporting.

---

## Tools & Skills Used
- **SQL Server (T-SQL)**
  - Views, Joins, CASE logic, Aggregations
- **Power BI**
  - DAX Measures, KPIs, Tooltips, Risk Visualisation
- Data Modeling & BI Layer Design
- Logistics & Operational Analytics

---

## Outcome
A scalable, BI ready logistics analytics model that supports:
- Delivery performance monitoring
- Risk based operational decision making
- Cost vs reliability evaluation
- Executive and operational reporting

This project demonstrates end-to end analytics capability: **data modeling → insight → decision support**.
