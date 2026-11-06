-- script pour supprimer les chauffeurs et les services affiliés lorsque le chauffeur a quitté le depot depuis plus de 5 ans. 
USE ROLE TRANSFORMER;
USE WAREHOUSE NYC_TAXI_WH;

DELETE FROM NYC_TAXI.RAW.DRIVER_SHIFTS
WHERE driver_id in (
    SELECT driver_id
    FROM NYC_TAXI.RAW.DRIVERS
    WHERE end_date IS NOT NULL
        AND end_date <= DATEADD(YEAR, -5, CURRENT_DATE())
);
DELETE FROM NYC_TAXI.RAW.DRIVERS
WHERE end_date IS NOT NULL
  AND end_date <= DATEADD(year, -5, CURRENT_DATE());

DELETE FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY
WHERE driver_id in (
    SELECT driver_id
    FROM NYC_TAXI.MARTS.DIM_DRIVER
    WHERE end_date IS NOT NULL
        AND end_date <= DATEADD(YEAR, -5, CURRENT_DATE())
);
DELETE FROM NYC_TAXI.MARTS.DIM_DRIVER
WHERE end_date IS NOT NULL
  AND end_date <= DATEADD(year, -5, CURRENT_DATE());