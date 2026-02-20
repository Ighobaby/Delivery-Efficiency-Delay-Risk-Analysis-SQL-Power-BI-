--------------------------------------------------------
-- DELIVERY EFFICIENCY AND DELAY RISK ANALYSIS
--------------------------------------------------------


-- Warehouses
CREATE TABLE dbo.Warehouses (
    WarehouseID INT PRIMARY KEY,
    WarehouseName VARCHAR(60),
    City VARCHAR(40)
);

INSERT INTO dbo.Warehouses VALUES
(1, 'GXO Logistics Edinburgh', 'Edinburgh'),
(2, 'M&S CraigMiller', 'Edinburgh'),
(3, 'Sainsbury Aberdeen', 'Aberdeen'),
(4, 'TK Maxx London', 'London'),
(5, 'Primark Newcastle', 'Newcastle'),
(6, 'Tesco Distribution Midlands', 'Birmingham');


-- Drivers
CREATE TABLE dbo.Drivers (
    DriverID INT PRIMARY KEY,
    DriverName VARCHAR(50),
    ExperienceYears INT
);

INSERT INTO dbo.Drivers VALUES
(1, 'Okoko Ngbede', 6),
(2, 'Mildred Igho', 4),
(3, 'Wambai Bizzu', 5),
(4, 'Shom Dave', 3),
(5, 'Andy Willz', 7),
(6, 'Zaki Jackson', 2),
(7, 'Akpos Trace', 4);

-- Vehicles
CREATE TABLE dbo.Vehicles (
    VehicleID INT PRIMARY KEY,
    VehicleType VARCHAR(20),
    CapacityKg INT,
    Status VARCHAR(20)
);

INSERT INTO dbo.Vehicles VALUES
(1, 'Truck', 12000, 'Active'),
(2, 'Truck', 10000, 'Active'),
(3, 'Van', 3500, 'Active'),
(4, 'Van', 3000, 'Maintenance'),
(5, 'Lorry', 8000, 'Active');


-- Routes
CREATE TABLE dbo.Routes (
    RouteID INT PRIMARY KEY,
    FromWarehouseID INT,
    ToWarehouseID INT,
    DistanceKM INT
);

INSERT INTO dbo.Routes VALUES
(1, 1, 2, 35),
(2, 1, 3, 200),
(3, 2, 4, 650),
(4, 3, 5, 300),
(5, 6, 4, 180),
(6, 5, 1, 290);

-- Shipments
CREATE TABLE dbo.Shipments (
    ShipmentID INT PRIMARY KEY,
    RouteID INT,
    DriverID INT,
    VehicleID INT,
    ShipmentDate DATE,
    DeliveryDate DATE,
    WeightKg INT,
    Cost DECIMAL(10,2),
    Status VARCHAR(20),
    DelayReason VARCHAR(50)
);

INSERT INTO dbo.Shipments VALUES
(1, 1, 1, 1, '2026-02-01', '2026-02-01', 8500, 950.00, 'Delivered', NULL),
(2, 1, 4, 3, '2026-02-02', '2026-02-03', 3000, 420.00, 'Delayed', 'Traffic Congestion'),

(3, 2, 2, 2, '2026-02-01', '2026-02-02', 9800, 1600.00, 'Delivered', NULL),
(4, 2, 6, 1, '2026-02-02', '2026-02-04', 11000, 1750.00, 'Delayed', 'Vehicle Breakdown'),

(5, 3, 5, 5, '2026-02-01', '2026-02-03', 7800, 2100.00, 'Delayed', 'Warehouse Backlog'),
(6, 3, 3, 5, '2026-02-03', '2026-02-03', 7600, 2050.00, 'Delivered', NULL),

(7, 4, 7, 3, '2026-02-02', '2026-02-02', 3200, 880.00, 'Delivered', NULL),
(8, 4, 6, 3, '2026-02-03', '2026-02-05', 3400, 920.00, 'Delayed', 'Staff Shortage'),

(9, 5, 4, 4, '2026-02-01', '2026-02-02', 2800, 650.00, 'Delayed', 'Vehicle Maintenance'),
(10,5, 2, 2, '2026-02-03', '2026-02-03', 9000, 1200.00, 'Delivered', NULL),

(11,6, 1, 1, '2026-02-02', '2026-02-04', 10500, 1450.00, 'Delayed', 'Severe Weather'),
(12,6, 5, 1, '2026-02-04', '2026-02-04', 9800, 1400.00, 'Delivered', NULL);


-- Create denormalized analytics view
CREATE VIEW vw_delivery_efficiency AS
SELECT
    /* =========================================================
       Shipment core facts (Shipments table)
       ========================================================= */
    s.ShipmentID,
    s.ShipmentDate,
    s.DeliveryDate,
    s.WeightKg,
    s.Cost,
    s.Status,
    s.DelayReason,

    /* =========================================================
       Delivery performance metrics (derived from Shipments)
       ========================================================= */
    DATEDIFF(DAY, s.ShipmentDate, s.DeliveryDate) AS DeliveryDays,
    CASE
        WHEN DATEDIFF(DAY, s.ShipmentDate, s.DeliveryDate) <= 1 THEN 0
        ELSE 1
    END AS IsDelayed,

    /* =========================================================
       Driver attributes (Drivers table)
       ========================================================= */
    d.DriverID,
    d.DriverName,
    d.ExperienceYears,

    /* =========================================================
       Vehicle attributes (Vehicles table)
       ========================================================= */
    v.VehicleID,
    v.VehicleType,
    v.CapacityKg AS VehicleCapacityKg,
    v.Status AS VehicleStatus,

    /* =========================================================
       Route attributes (Routes table)
       ========================================================= */
    r.RouteID,
    r.DistanceKM,

    /* =========================================================
       Warehouse context (Routes → Warehouses)
       ========================================================= */
    wFrom.WarehouseName AS FromWarehouse,
    wFrom.City AS FromCity,
    wTo.WarehouseName AS ToWarehouse,
    wTo.City AS ToCity,

    -- Readable route label (derived from warehouse endpoints) for BI visuals & reporting
    CONCAT(wFrom.WarehouseName, ' to ', wTo.WarehouseName) AS RouteName,
    /* =========================================================
       Cost efficiency metric (derived)
       ========================================================= */
    CASE
        WHEN r.DistanceKM = 0 THEN NULL
        ELSE CAST(s.Cost / r.DistanceKM AS DECIMAL(10,2))
    END AS CostPerKM

FROM Shipments s

/* Shipment ownership */
JOIN Drivers d
    ON s.DriverID = d.DriverID

JOIN Vehicles v
    ON s.VehicleID = v.VehicleID

/* Shipment routing */
JOIN Routes r
    ON s.RouteID = r.RouteID

/* Route endpoints */
JOIN Warehouses wFrom
    ON r.FromWarehouseID = wFrom.WarehouseID

JOIN Warehouses wTo
    ON r.ToWarehouseID = wTo.WarehouseID;

SELECT * FROM vw_delivery_efficiency;



-- Overall shipment performance summary
SELECT
    COUNT(*) AS TotalShipments,
    SUM(IsDelayed) AS DelayedShipments,
    CAST(
        SUM(IsDelayed) * 1.0 / COUNT(*) 
        AS DECIMAL(5,2)
    ) AS DelayRate
FROM vw_delivery_efficiency;



-- Identify routes with the highest delay risk
SELECT
    RouteID,
    RouteName,
    COUNT(*) AS TotalShipments,
    SUM(IsDelayed) AS DelayedShipments,
    CAST(
        SUM(IsDelayed) * 1.0 / COUNT(*) 
        AS DECIMAL(5,2)
    ) AS DelayRate
FROM vw_delivery_efficiency
GROUP BY RouteID, RouteName
ORDER BY DelayRate DESC;


-- Evaluate driver reliability based on delivery delays
SELECT
    DriverName,
    COUNT(*) AS TotalShipments,
    SUM(IsDelayed) AS DelayedShipments
FROM vw_delivery_efficiency
GROUP BY DriverName
ORDER BY DelayedShipments DESC;


-- Assess delay exposure by vehicle type
SELECT
    VehicleType,
    COUNT(*) AS TotalShipments,
    SUM(IsDelayed) AS DelayedShipments
FROM vw_delivery_efficiency
GROUP BY VehicleType
ORDER BY DelayedShipments DESC;



-- Analyze cost efficiency by route distance
SELECT
    RouteID,
    RouteName,
    DistanceKM,
    AVG(CostPerKM) AS AvgCostPerKM
FROM vw_delivery_efficiency
GROUP BY RouteID, RouteName, DistanceKM
ORDER BY AvgCostPerKM DESC;



-- Classify shipments as on time or delayed based on delivery duration
SELECT
    ShipmentID,
    ShipmentDate,
    DeliveryDate,
    DeliveryDays,
    CASE
        WHEN IsDelayed = 0 THEN 'On-Time'
        ELSE 'Delayed'
    END AS DeliveryPerformance
FROM vw_delivery_efficiency;


-- Identify high risk shipments: delayed and high cost
SELECT
    ShipmentID,
    Cost,
    RouteID,
    RouteName,
    Status
FROM vw_delivery_efficiency
WHERE IsDelayed = 1
ORDER BY Cost DESC;

-- Reasons for delay
SELECT
    DelayReason,
    COUNT(*) AS DelayedShipments
FROM vw_delivery_efficiency
WHERE IsDelayed = 1
GROUP BY DelayReason
ORDER BY DelayedShipments DESC;

-- Drivers risk rate
SELECT
    DriverName,
    COUNT(*) AS TotalShipments,
    SUM(IsDelayed) AS DelayedShipments,
    CAST(
        SUM(IsDelayed) * 1.0 / COUNT(*) 
        AS DECIMAL(5,2)
    ) AS DelayRate
FROM vw_delivery_efficiency
GROUP BY DriverName
ORDER BY DelayRate DESC;

-- Route profitability vs reliability
SELECT
    RouteID,
    RouteName,
    COUNT(*) AS TotalShipments,
    SUM(IsDelayed) AS DelayedShipments,
    AVG(CostPerKM) AS AvgCostPerKM
FROM vw_delivery_efficiency
GROUP BY RouteID, RouteName
ORDER BY AvgCostPerKM DESC;






