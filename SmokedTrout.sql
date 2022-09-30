/*
* 
* 1) Rename this file according to the instructions in the assignment statement.
* 2) Use this file to insert your solution.
*
*
* Author: Commander, Samuel
* Student ID Number: XXXXXXX
* Institutional mail prefix: XXXXXXX
*/


/*
*  Assume a user account 'fsad' with password 'fsad2022' with permission
* to create  databases already exists. You do NO need to include the commands
* to create the user nor to give it permission in you solution.
* For your testing, the following command may be used:
*
* CREATE USER fsad PASSWORD 'fsad2022' CREATEDB;
* GRANT pg_read_server_files TO fsad;
*/


/* *********************************************************
* Exercise 1. Create the Smoked Trout database
* 
************************************************************ */

-- The first time you login to execute this file with \i it may
-- be convenient to change the working directory.	

-- In PostgreSQL, folders are identified with '/'


-- 1) Create a database called SmokedTrout.						

CREATE DATABASE "SmokedTrout" 
WITH OWNER = fsad
ENCODING = 'UTF8'
CONNECTION LIMIT = -1;

-- 2) Connect to the database								

\c "SmokedTrout" fsad


/* *********************************************************
* Exercise 2. Implement the given design in the Smoked Trout database
* 
************************************************************ */

-- 1) Create a new ENUM type called materialState for storing the raw material state	

CREATE TYPE "MaterialState" AS ENUM ('Solid', 'Liquid', 'Gas', 'Plasma');


-- 2) Create a new ENUM type called materialComposition for storing whether	
-- a material is Fundamental or Composite.

CREATE TYPE "MaterialComposition" AS ENUM ('Fundamental', 'Composite');


-- 3) Create the table TradingRoute with the corresponding attributes.

CREATE TABLE "TradingRoute" (
"MonitoringKey" SERIAL,
"FleetSize" int,
"OperatingCompany" varchar(40),
"LastYearRevenue" real NOT NULL,
PRIMARY KEY ("MonitoringKey")
);


-- 4) Create the table Planet with the corresponding attributes.

CREATE TABLE "Planet" (
"PlanetID" SERIAL,
"StarSystem" varchar(30),
"Name" varchar(30),
"Population" integer,
PRIMARY KEY ("PlanetID")
);


-- 5) Create the table SpaceStation with the corresponding attributes.

CREATE TABLE "SpaceStation" (
"StationID" SERIAL,
"PlanetID" integer,
"Name" varchar(30),
"Longitude" varchar(15),
"Latitude" varchar(15),
PRIMARY KEY ("StationID"),
FOREIGN KEY ("PlanetID") REFERENCES "Planet"("PlanetID") ON DELETE CASCADE ON UPDATE CASCADE
);


-- 6) Create the parent table Product with the corresponding attributes. X

CREATE TABLE "Product" (
"ProductID" SERIAL,
"Name" varchar(30),
"VolumePerTon" real,
"ValuePerTon" real,
PRIMARY KEY ("ProductID")
);


-- 7) Create the child table RawMaterial with the corresponding attributes. x

CREATE TABLE "RawMaterial" (								
"FundamentalOrComposite" "MaterialComposition",
"State" "MaterialState",
PRIMARY KEY ("ProductID")
) INHERITS("Product");


-- 8) Create the child table ManufacturedGood. x

CREATE TABLE "ManufacturedGood" (
PRIMARY KEY ("ProductID")
) INHERITS("Product");


-- 9) Create the table MadeOf with the corresponding attributes.

CREATE TABLE "MadeOf" (
"ManufacturedGoodID" integer,
"ProductID" integer
);


-- 10) Create the table Batch with the corresponding attributes.			

CREATE TABLE "Batch" (
"BatchID" SERIAL,
"ProductID" integer,
"ExtractionOrManufacturingDate" DATE,
"OriginalFrom" integer,
PRIMARY KEY ("BatchID"),
FOREIGN KEY ("OriginalFrom") REFERENCES "Planet"("PlanetID") ON DELETE CASCADE ON UPDATE CASCADE
);


-- 11) Create the table Sells with the corresponding attributes.

CREATE TABLE "Sells" (
"BatchID" SERIAL,
"StationID" integer,
PRIMARY KEY ("BatchID", "StationID"),
FOREIGN KEY ("StationID") REFERENCES "SpaceStation"("StationID") ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY ("BatchID") REFERENCES "Batch"("BatchID") ON DELETE CASCADE ON UPDATE CASCADE
);


-- 12)  Create the table Buys with the corresponding attributes.

CREATE TABLE "Buys" (									
"BatchID" SERIAL,
"StationID" integer,
PRIMARY KEY ("BatchID", "StationID"),
FOREIGN KEY ("StationID") REFERENCES "SpaceStation"("StationID") ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY ("BatchID") REFERENCES "Batch"("BatchID") ON DELETE CASCADE ON UPDATE CASCADE
);


-- 13)  Create the table CallsAt with the corresponding attributes.

CREATE TABLE "CallsAt" (									
"MonitoringKey" integer,
"StationID" integer,
"VisitOrder" integer,
PRIMARY KEY ("MonitoringKey", "StationID"),
FOREIGN KEY ("MonitoringKey") REFERENCES "TradingRoute"("MonitoringKey") ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY ("StationID") REFERENCES "SpaceStation"("StationID") ON DELETE CASCADE ON UPDATE CASCADE
);


-- 14)  Create the table Distance with the corresponding attributes.

CREATE TABLE "Distance" (									
"PlanetOrigin" integer,
"PlanetDestination" integer,
"AvgDistance" real,
PRIMARY KEY ("PlanetOrigin", "PlanetDestination"),
FOREIGN KEY ("PlanetOrigin") REFERENCES "Planet"("PlanetID") ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY ("PlanetDestination") REFERENCES "Planet"("PlanetID") ON DELETE CASCADE ON UPDATE CASCADE
);


/* *********************************************************
* Exercise 3. Populate the Smoked Trout database
* 
************************************************************ */
/* *********************************************************
* NOTE: The copy statement is NOT standard SQL.
* The copy statement does NOT permit on-the-fly renaming columns,
* hence, whenever necessary, we:
* 1) Create a dummy table with the column name as in the file
* 2) Copy from the file to the dummy table
* 3) Copy from the dummy table to the real table
* 4) Drop the dummy table (This is done further below, as I keep
*    the dummy table also to imporrt the other columns)
************************************************************ */



-- 1) Unzip all the data files in a subfolder called data from where you have your code file 
-- NO CODE GOES HERE. THIS STEP IS JUST LEFT HERE TO KEEP CONSISTENCY WITH THE ASSIGNMENT STATEMENT

-- 2) Populate the table TradingRoute with the data in the file TradeRoutes.csv.

CREATE TABLE dummy (
"MonitoringKey" SERIAL,
"FleetSize" int,
"OperatingCompany" varchar(40),
"LastYearRevenue" real NOT NULL
);

\copy dummy FROM './data/TradeRoutes.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "TradingRoute" ("MonitoringKey", "FleetSize", "OperatingCompany", "LastYearRevenue")
SELECT "MonitoringKey", "FleetSize", "OperatingCompany", "LastYearRevenue" FROM dummy;

DROP TABLE dummy;


-- 3) Populate the table Planet with the data in the file Planets.csv.

CREATE TABLE dummy (
"PlanetID" SERIAL,
"StarSystem" varchar(30),
"Planet" varchar(30),
"Population" integer
);

\copy dummy FROM './data/Planets.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "Planet" ("PlanetID", "StarSystem", "Name", "Population")
SELECT "PlanetID", "StarSystem", "Planet", "Population" FROM dummy;

DROP TABLE dummy;


-- 4) Populate the table SpaceStation with the data in the file SpaceStations.csv.

CREATE TABLE dummy (
"StationID" SERIAL,
"PlanetID" integer,
"SpaceStations" varchar(30),
"Longitude" varchar(15),
"Latitude" varchar(15)
);

\copy dummy FROM './data/SpaceStations.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "SpaceStation" ("StationID", "PlanetID", "Name", "Longitude", "Latitude")
SELECT "StationID", "PlanetID", "SpaceStations", "Longitude", "Latitude" FROM dummy;

DROP TABLE dummy;


-- 5) Populate the tables RawMaterial and Product with the data in the file Products_Raw.csv.

CREATE TABLE dummy (
"ProductID" SERIAL,
"Product" varchar(30),
"Composite" text,
"VolumePerTon" real,
"ValuePerTon" real,
"State" "MaterialState"
);

\copy dummy FROM './data/Products_Raw.csv' WITH (FORMAT CSV, HEADER);

UPDATE dummy
SET "Composite" = 'Fundamental'
WHERE "Composite" = 'No';

UPDATE dummy
SET "Composite" = 'Composite'
WHERE "Composite" = 'Yes';

ALTER TABLE dummy
ALTER COLUMN "Composite" TYPE "MaterialComposition" USING "Composite"::"MaterialComposition";

INSERT INTO "RawMaterial" ("ProductID", "Name", "VolumePerTon", "ValuePerTon", "FundamentalOrComposite", "State")
SELECT "ProductID", "Product", "VolumePerTon", "ValuePerTon", "Composite", "State" FROM dummy;

DROP TABLE dummy;


-- 6) Populate the tables ManufacturedGood and Product with the data in the file  Products_Manufactured.csv.

CREATE TABLE dummy (
"ProductID" SERIAL,
"Product" varchar(30),
"VolumePerTon" real,
"ValuePerTon" real
);

\copy dummy FROM './data/Products_Manufactured.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "ManufacturedGood" ("ProductID", "Name", "VolumePerTon", "ValuePerTon" )
SELECT "ProductID", "Product", "VolumePerTon", "ValuePerTon" FROM dummy;

DROP TABLE dummy;


-- 7) Populate the table MadeOf with the data in the file MadeOf.csv.

CREATE TABLE dummy (
"ManufacturedGoodID" integer,
"ProductID" integer
);

\copy dummy FROM './data/MadeOf.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "MadeOf" ("ManufacturedGoodID", "ProductID")
SELECT "ManufacturedGoodID", "ProductID" FROM dummy;

DROP TABLE dummy;


-- 8) Populate the table Batch with the data in the file Batches.csv.

CREATE TABLE dummy (
"BatchID" SERIAL,
"ProductID" integer,
"ExtractionOrManufacturingDate" DATE,
"OriginalFrom" integer
);

\copy dummy FROM './data/Batches.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "Batch" ("BatchID", "ProductID", "ExtractionOrManufacturingDate", "OriginalFrom")
SELECT "BatchID", "ProductID", "ExtractionOrManufacturingDate", "OriginalFrom" FROM dummy;

DROP TABLE dummy;


-- 9) Populate the table Sells with the data in the file Sells.csv.

CREATE TABLE dummy (
"BatchID" SERIAL,
"StationID" integer
);

\copy dummy FROM './data/Sells.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "Sells" ("BatchID", "StationID")
SELECT "BatchID", "StationID" FROM dummy;

DROP TABLE dummy;


-- 10) Populate the table Buys with the data in the file Buys.csv.

CREATE TABLE dummy (									
"BatchID" SERIAL,
"StationID" integer
);

\copy dummy FROM './data/Buys.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "Buys" ("BatchID", "StationID")
SELECT "BatchID", "StationID" FROM dummy;

DROP TABLE dummy;


-- 11) Populate the table CallsAt with the data in the file CallsAt.csv.

CREATE TABLE dummy (									
"MonitoringKey" integer,
"StationID" integer,
"VisitOrder" integer
);

\copy dummy FROM './data/CallsAt.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "CallsAt" ("MonitoringKey", "StationID", "VisitOrder")
SELECT "MonitoringKey", "StationID", "VisitOrder" FROM dummy;

DROP TABLE dummy;


-- 12) Populate the table Distance with the data in the file PlanetDistances.csv.

CREATE TABLE dummy (									
"PlanetOrigin" integer,
"PlanetDestination" integer,
"Distance" real
);

\copy dummy FROM './data/PlanetDistances.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "Distance" ("PlanetOrigin", "PlanetDestination", "AvgDistance")
SELECT "PlanetOrigin", "PlanetDestination", "Distance" FROM dummy;

DROP TABLE dummy;


/* *********************************************************
* Exercise 4. Query the database
* 
************************************************************ */

-- 4.1 Report last year taxes per company

-- 1) Add an attribute Taxes to table TradingRoute

ALTER TABLE "TradingRoute"
ADD "Taxes" real;


-- 2) Set the derived attribute taxes as 12% of LastYearRevenue

ALTER TABLE "TradingRoute"
DROP "Taxes";

ALTER TABLE "TradingRoute"
ADD "Taxes" real GENERATED ALWAYS AS ("LastYearRevenue" / 100 * 12) STORED;


-- 3) Report the operating company and the sum of its taxes group by company.

SELECT "OperatingCompany", SUM("Taxes") AS "TotalTaxes"
FROM "TradingRoute"
GROUP BY "OperatingCompany";


-- 4.2 What's the longest trading route in parsecs?

-- 1) Create a dummy table RouteLength to store the trading route and their lengths.						
-- Storing each entire trading route (including all hops) in one number, as well as an identifying MonitoringKey,
-- which is the same as TradingRoute's monitoring key.
-- Think of RouteLength as an additional part of TradingRoute

CREATE TABLE "RouteLength" (												
"MonitoringKey" SERIAL,
"Length" decimal
);

-- 2) Create a view EnrichedCallsAt that brings together trading route, space stations and planets.				
-- Uses CallsAt inner joined to SpaceStation ON StationID.
-- Trading route (MonitoringKey), space stations (StationID) and planets (PlanetID).
-- CallsAt has MonitoringKey, StationID and VisitOrder, EnrichedCallsAt adds PlanetID from SpaceStation.

CREATE VIEW "EnrichedCallsAt" AS
SELECT "CallsAt"."MonitoringKey", "CallsAt"."StationID", "CallsAt"."VisitOrder", "SpaceStation"."PlanetID" AS "Planet"
FROM "CallsAt"
INNER JOIN "SpaceStation"
ON "CallsAt"."StationID" = "SpaceStation"."StationID";


-- 3) Add the support to execute an anonymous code block as follows;									

DO
$$

-- 4) Within the declare section, declare a variable of type real to store a route total distance.					

DECLARE "RouteDistance" real;


-- 5) Within the declare section, declare a variable of type real to store a hop partial distance.				
-- Hop partial distance means one single hop, with total distance being made up of several hops

DECLARE "HopPartialDistance" real;


-- 6) Within the declare section, declare a variable of type record to iterate over routes.						
						
DECLARE "rRoute" record;


-- 7) Within the declare section, declare a variable of type record to iterate over hops.				

DECLARE "rHops" record;


-- 8) Within the declare section, declare a variable of type text to transiently build dynamic queries.			
-- Used as string for queries to sit within.

DECLARE "BuildsDynamicQueries" text;							


-- 9) Within the main body section, loop over routes in TradingRoutes							
-- Here we are cycling through all MonitoringKeys / routes.

BEGIN

FOR "rRoute" IN SELECT "MonitoringKey" FROM "TradingRoute" 
LOOP


-- 10) Within the loop over routes, get all visited planets (in order) by this trading route.			
-- Gets the currently cycle-selected route's visited planets in order.
-- For this entire query station and planet mean the same thing.
-- Code taken directly from pdf.

"BuildsDynamicQueries" := 'CREATE VIEW "PortsOfCall" AS '
|| 'SELECT "Planet", "VisitOrder" '
|| 'FROM "EnrichedCallsAt" '
|| 'WHERE "MonitoringKey" = ' || "rRoute"."MonitoringKey"
|| ' ORDER BY "VisitOrder" ';


-- 11) Within the loop over routes, execute the dynamic view					

EXECUTE "BuildsDynamicQueries";


-- 12) Within the loop over routes, create a view Hops for storing the hops of that route.		
-- One way of doing this is by INNER JOINing the view created in Step 10 with 
-- itself ON the visit order (being consecutive).
-- A hop is a jump between two planets.
-- 
-- Locked to a particular route (via loop) because of connection to "PortsOfCall"
-- (which itself is specific to MonitoringKey).
-- Needs 2 columns both planets,


CREATE VIEW "Hops" AS
SELECT "Planet",
LEAD("Planet") OVER (ORDER BY "VisitOrder") AS "NextPlanet"
FROM "PortsOfCall";


-- 13) Within the loop over routes, initialize the route total distance to 0.0.			

"RouteDistance" = 0.0;


-- 14) Within the loop over routes, create an inner loop over the hops				
-- rHops is a record (row)

FOR "rHops" IN SELECT "Planet", "NextPlanet" FROM "Hops" WHERE "NextPlanet" IS NOT NULL
LOOP


-- 15) Within the loop over hops, get the partial distances of the hop.				
-- Use a dynamic query over table Distance, and for which its WHERE clause will be dependent 
-- on the hop origin and destination planets.

"BuildsDynamicQueries" := 'SELECT "AvgDistance" '
|| 'FROM "Distance" '
|| 'WHERE "PlanetOrigin" = ' || "rHops"."Planet"
|| 'AND "PlanetDestination" = ' || "rHops"."NextPlanet";


-- 16)  Within the loop over hops, execute the dynamic view and store the outcome INTO the hop partial distance.		

EXECUTE "BuildsDynamicQueries" INTO "HopPartialDistance";


-- 17)  Within the loop over hops, accumulate the hop partial distance to the route total distance.			
-- As we cycle through hops, each one is added to the route total distance, gradually increasing 
-- until all hops in the route are added.

"RouteDistance" := "RouteDistance" + "HopPartialDistance";

END LOOP;


-- 18)  Go back to the routes loop and insert into the dummy table RouteLength the pair (RouteMonitoringKey,RouteTotalDistance).

INSERT INTO "RouteLength" ("MonitoringKey", "Length") VALUES("rRoute"."MonitoringKey", "RouteDistance");


-- 19)  Within the loop over routes, drop the view for Hops (and cascade to delete dependent objects).				

DROP VIEW "Hops" CASCADE;


-- 20)  Within the loop over routes, drop the view for PortsOfCall (and cascade to delete dependent objects).			

DROP VIEW "PortsOfCall" CASCADE;

END LOOP;

END;
$$;


-- 21)  Finally, just report the longest route in the dummy table RouteLength.					

SELECT "MonitoringKey", "Length"
FROM "RouteLength"
WHERE "Length" = (SELECT MAX("Length") FROM "RouteLength");						
