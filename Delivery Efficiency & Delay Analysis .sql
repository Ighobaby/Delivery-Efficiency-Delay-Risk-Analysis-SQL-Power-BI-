--------------------------------------------------------
-- DELIVERY EFFICIENCY AND DELAY RISK ANALYSIS
--------------------------------------------------------

/* =====================================================
   1. WAREHOUSES
   ===================================================== */
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


/* =====================================================
   2. DRIVERS
   ===================================================== */
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
(7, 'Akpos Trace', 4),
(8, 'Kelvin Richards', 5),
(9, 'Twetwe Iweka', 3);


/* =====================================================
   3. VEHICLES
   ===================================================== */
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


/* =====================================================
   4. ROUTES
   ===================================================== */
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


/* =====================================================
   5. SHIPMENTS (FACT TABLE)
   ===================================================== */
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


/* =====================================================
   6. SEED 50 SHIPMENTS WITH PROBABILISTIC DELAYS
   ===================================================== */
DECLARE @i INT = 1;

WHILE @i <= 50
BEGIN
    DECLARE 
        @RouteID INT = (ABS(CHECKSUM(NEWID())) % 6) + 1,
        @DriverID INT = (ABS(CHECKSUM(NEWID())) % 9) + 1,
        @VehicleID INT = (ABS(CHECKSUM(NEWID())) % 5) + 1,
        @ShipDate DATE = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 10, '2026-02-01'),
        @Distance INT,
        @DelayFlag INT,
        @DeliveryDate DATE,
        @DelayReason VARCHAR(50);

    SELECT @Distance = DistanceKM
    FROM dbo.Routes
    WHERE RouteID = @RouteID;

    SET @DelayFlag =
        CASE
            WHEN @Distance <= 100 AND RAND(CHECKSUM(NEWID())) < 0.20 THEN 1
            WHEN @Distance BETWEEN 101 AND 300 AND RAND(CHECKSUM(NEWID())) < 0.30 THEN 1
            WHEN @Distance > 300 AND RAND(CHECKSUM(NEWID())) < 0.50 THEN 1
            ELSE 0
        END;

    SET @DeliveryDate =
        CASE 
            WHEN @DelayFlag = 1 
                THEN DATEADD(DAY, 2 + ABS(CHECKSUM(NEWID())) % 2, @ShipDate)
            ELSE DATEADD(DAY, 1, @ShipDate)
        END;

    SET @DelayReason =
        CASE 
            WHEN @DelayFlag = 0 THEN NULL
            ELSE CHOOSE(
                (ABS(CHECKSUM(NEWID())) % 5) + 1,
                'Traffic Congestion',
                'Vehicle Breakdown',
                'Warehouse Backlog',
                'Staff Shortage',
                'Severe Weather'
            )
        END;

    INSERT INTO dbo.Shipments VALUES (
        @i,
        @RouteID,
        @DriverID,
        @VehicleID,
        @ShipDate,
        @DeliveryDate,
        2000 + ABS(CHECKSUM(NEWID())) % 9000,
        400 + ABS(CHECKSUM(NEWID())) % 1800,
        CASE WHEN @DelayFlag = 1 THEN 'Delayed' ELSE 'Delivered' END,
        @DelayReason
    );

    SET @i += 1;
END;


/* =====================================================
   7. DATA HYGIENE 
   ===================================================== */
UPDATE dbo.Shipments
SET DelayReason = 'Unspecified'
WHERE Status = 'Delayed'
  AND DelayReason IS NULL;


/* =====================================================
   8. ANALYTICS VIEW
   ===================================================== */
CREATE VIEW vw_delivery_efficiency AS
SELECT
    s.ShipmentID,
    s.ShipmentDate,
    s.DeliveryDate,
    s.WeightKg,
    s.Cost,
    s.Status,
    s.DelayReason,

    DATEDIFF(DAY, s.ShipmentDate, s.DeliveryDate) AS DeliveryDays,
    CASE 
        WHEN DATEDIFF(DAY, s.ShipmentDate, s.DeliveryDate) <= 1 THEN 0 
        ELSE 1 
    END AS IsDelayed,

    d.DriverName,
    d.ExperienceYears,

    v.VehicleType,
    v.CapacityKg AS VehicleCapacityKg,

    r.RouteID,
    r.DistanceKM,

    wf.WarehouseName AS FromWarehouse,
    wt.WarehouseName AS ToWarehouse,

    CONCAT(wf.WarehouseName, ' to ', wt.WarehouseName) AS RouteName,

    CAST(s.Cost / NULLIF(r.DistanceKM, 0) AS DECIMAL(10,2)) AS CostPerKM,

 
    /* =====================================================
   9. DELAY RISK SCORE (COMPOSITE OPERATIONAL RISK METRIC)
   ===================================================== */
(
    (r.DistanceKM / 10.0) +
    CASE 
        WHEN d.ExperienceYears < 3 THEN 20
        WHEN d.ExperienceYears BETWEEN 3 AND 5 THEN 10
        ELSE 0
    END +
    CASE 
        WHEN v.VehicleType = 'Van' THEN 10
        WHEN v.VehicleType = 'Lorry' THEN 5
        ELSE 0
    END
) AS DelayRiskScore

FROM dbo.Shipments s
JOIN dbo.Drivers d ON s.DriverID = d.DriverID
JOIN dbo.Vehicles v ON s.VehicleID = v.VehicleID
JOIN dbo.Routes r ON s.RouteID = r.RouteID
JOIN dbo.Warehouses wf ON r.FromWarehouseID = wf.WarehouseID
JOIN dbo.Warehouses wt ON r.ToWarehouseID = wt.WarehouseID;

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






