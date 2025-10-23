-- Abdulla Al Harun
-- Question 2.2.3 Solution
USE VetDB;


-- 1) Add new pet and associated owner (with address)
START TRANSACTION;

INSERT INTO Addresses (line1, line2, city, postal_code, country)
VALUES ('Universitetsgata 10', NULL, 'Oslo', '0164', 'Norway');

INSERT INTO Owners (first_name, last_name, phone, email, address_id)
VALUES ('Noah','Johansen','+47 400 000 06','noah.johansen@example.com', LAST_INSERT_ID());

INSERT INTO Animals (name, date_of_birth, sex, owner_id, species_id)
VALUES (
  'Bella','2023-04-02','F',
  LAST_INSERT_ID(),
  (SELECT species_id FROM Species WHERE common_name='Dog')
);

COMMIT;

-- 2) Update an existing address (change Emma Larsen postal code)
UPDATE Addresses
SET postal_code = '0160'
WHERE address_id = (SELECT address_id FROM Owners WHERE first_name='Emma' AND last_name='Larsen');

-- 3) Hire a new staff member
INSERT INTO Staff (first_name, last_name, role, hired_date, retired_date, active)
VALUES ('Sindre','Holm','Nurse', CURRENT_DATE, NULL, 1);

-- 4) Retire a staff member (soft retire: set retired_date & active=0)
UPDATE Staff
SET retired_date = CURRENT_DATE, active = 0
WHERE first_name='Per' AND last_name='Andresen' AND active=1;

-- 5) Add a procedure to an existing animal
-- Example: Vaccination for Bella by Lina Berg today
INSERT INTO AnimalProcedures (animal_id, procedure_id, staff_id, procedure_date, notes, price_charged)
VALUES (
  (SELECT animal_id FROM Animals WHERE name='Bella' ORDER BY animal_id DESC LIMIT 1),
  (SELECT procedure_id FROM Procedures WHERE name='Vaccination'),
  (SELECT staff_id FROM Staff WHERE first_name='Lina' AND last_name='Berg'),
  CURRENT_DATE,
  'Puppy booster',
  (SELECT base_price FROM Procedures WHERE name='Vaccination')
);
