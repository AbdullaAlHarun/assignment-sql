#Abdulla Al Harun

-- Question 2.2.1 Solution

-- VetDB Initialisation

DROP DATABASE IF EXISTS VetDB;
CREATE DATABASE VetDB
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_0900_ai_ci;
USE VetDB;

-- 1) Addresses
CREATE TABLE Addresses (
  address_id   INT AUTO_INCREMENT PRIMARY KEY,
  line1        VARCHAR(120) NOT NULL,
  line2        VARCHAR(120),
  city         VARCHAR(80)  NOT NULL,
  postal_code  VARCHAR(20)  NOT NULL,
  country      VARCHAR(80)  NOT NULL DEFAULT 'Norway',
  created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2) Owners (Customers)
CREATE TABLE Owners (
  owner_id   INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(60) NOT NULL,
  last_name  VARCHAR(60) NOT NULL,
  phone      VARCHAR(30),
  email      VARCHAR(120),
  address_id INT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_owners_address
    FOREIGN KEY (address_id) REFERENCES Addresses(address_id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- 3) Species
CREATE TABLE Species (
  species_id  INT AUTO_INCREMENT PRIMARY KEY,
  common_name VARCHAR(60) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- 4) Animals
CREATE TABLE Animals (
  animal_id     INT AUTO_INCREMENT PRIMARY KEY,
  name          VARCHAR(80) NOT NULL,
  date_of_birth DATE,
  sex           ENUM('M','F','U') NOT NULL DEFAULT 'U',
  owner_id      INT NOT NULL,
  species_id    INT NOT NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_animals_owner
    FOREIGN KEY (owner_id)   REFERENCES Owners(owner_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_animals_species
    FOREIGN KEY (species_id) REFERENCES Species(species_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 5) Staff
CREATE TABLE Staff (
  staff_id     INT AUTO_INCREMENT PRIMARY KEY,
  first_name   VARCHAR(60) NOT NULL,
  last_name    VARCHAR(60) NOT NULL,
  role         ENUM('Vet','Nurse','Assistant','Reception') NOT NULL,
  hired_date   DATE NOT NULL,
  retired_date DATE,
  active       TINYINT(1) NOT NULL DEFAULT 1,
  created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_staff_dates CHECK (retired_date IS NULL OR retired_date >= hired_date)
) ENGINE=InnoDB;

-- 6) Procedures (catalog)
CREATE TABLE Procedures (
  procedure_id INT AUTO_INCREMENT PRIMARY KEY,
  name         VARCHAR(80) NOT NULL UNIQUE,
  base_price   DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  description  TEXT
) ENGINE=InnoDB;

-- 7) AnimalProcedures (performed procedures)
CREATE TABLE AnimalProcedures (
  animal_procedure_id INT AUTO_INCREMENT PRIMARY KEY,
  animal_id      INT NOT NULL,
  procedure_id   INT NOT NULL,
  staff_id       INT NOT NULL,
  procedure_date DATE NOT NULL,
  notes          TEXT,
  price_charged  DECIMAL(10,2),
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ap_animal
    FOREIGN KEY (animal_id)    REFERENCES Animals(animal_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_ap_procedure
    FOREIGN KEY (procedure_id) REFERENCES Procedures(procedure_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_ap_staff
    FOREIGN KEY (staff_id)     REFERENCES Staff(staff_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Helpful indexes
CREATE INDEX idx_animals_owner ON Animals(owner_id);
CREATE INDEX idx_ap_date       ON AnimalProcedures(procedure_date);


-- Question 2.2.2 — SAMPLE DATA


USE VetDB;

-- Addresses
INSERT INTO Addresses (line1, line2, city, postal_code, country) VALUES
('Storgata 12', NULL, 'Oslo', '0155', 'Norway'),
('Parkveien 44', 'Apt 3B', 'Oslo', '0258', 'Norway'),
('Fjellveien 9', NULL, 'Bergen', '5019', 'Norway'),
('Kirkegata 2', NULL, 'Trondheim', '7011', 'Norway'),
('Strandgata 77', NULL, 'Tromsø', '9008', 'Norway');

-- Owners (Customers)
INSERT INTO Owners (first_name, last_name, phone, email, address_id) VALUES
('Emma','Larsen','+47 400 000 01','emma.larsen@example.com', 1),
('Jon','Haugen','+47 400 000 02','jon.haugen@example.com', 2),
('Sara','Nilsen','+47 400 000 03','sara.nilsen@example.com', 3),
('Mats','Solberg','+47 400 000 04','mats.solberg@example.com', 4),
('Aisha','Ahmed','+47 400 000 05','aisha.ahmed@example.com', 5);

-- Species
INSERT INTO Species (common_name) VALUES
('Dog'), ('Cat'), ('Rabbit'), ('Parrot');

-- Staff
INSERT INTO Staff (first_name, last_name, role, hired_date, retired_date, active) VALUES
('Lina','Berg','Vet','2020-03-01',NULL,1),
('Oskar','Dahl','Nurse','2021-06-15',NULL,1),
('Hanna','Krog','Assistant','2022-01-10',NULL,1),
('Per','Andresen','Reception','2019-09-01',NULL,1);

-- Procedures (catalog)
INSERT INTO Procedures (name, base_price, description) VALUES
('Checkup',            750.00, 'Routine health check'),
('Vaccination',        890.00, 'Core vaccination'),
('Dental Cleaning',   1800.00, 'Scaling and polishing'),
('Minor Surgery',     3500.00, 'Outpatient minor procedure'),
('Major Surgery',     9500.00, 'Inpatient major procedure');

-- Animals
INSERT INTO Animals (name, date_of_birth, sex, owner_id, species_id) VALUES
('Luna','2021-05-12','F', 1, (SELECT species_id FROM Species WHERE common_name='Dog')),
('Milo','2020-11-03','M', 2, (SELECT species_id FROM Species WHERE common_name='Cat')),
('Nugget','2022-04-20','M', 3, (SELECT species_id FROM Species WHERE common_name='Rabbit')),
('Kiki','2019-08-08','F', 4, (SELECT species_id FROM Species WHERE common_name='Parrot')),
('Thor','2018-02-14','M', 5, (SELECT species_id FROM Species WHERE common_name='Dog'));

-- AnimalProcedures (performed)
INSERT INTO AnimalProcedures (animal_id, procedure_id, staff_id, procedure_date, notes, price_charged) VALUES
-- Luna (Dog) - Checkup & Vaccination
((SELECT animal_id FROM Animals WHERE name='Luna'),
 (SELECT procedure_id FROM Procedures WHERE name='Checkup'),
 (SELECT staff_id FROM Staff WHERE first_name='Lina' AND last_name='Berg'),
 '2024-03-12','Annual checkup', 750.00),

((SELECT animal_id FROM Animals WHERE name='Luna'),
 (SELECT procedure_id FROM Procedures WHERE name='Vaccination'),
 (SELECT staff_id FROM Staff WHERE first_name='Oskar' AND last_name='Dahl'),
 '2024-03-12','DHPPi booster', 890.00),

-- Milo (Cat) - Dental Cleaning
((SELECT animal_id FROM Animals WHERE name='Milo'),
 (SELECT procedure_id FROM Procedures WHERE name='Dental Cleaning'),
 (SELECT staff_id FROM Staff WHERE first_name='Lina' AND last_name='Berg'),
 '2024-06-01','Tartar grade 2', 1800.00),

-- Nugget (Rabbit) - Checkup
((SELECT animal_id FROM Animals WHERE name='Nugget'),
 (SELECT procedure_id FROM Procedures WHERE name='Checkup'),
 (SELECT staff_id FROM Staff WHERE first_name='Hanna' AND last_name='Krog'),
 '2025-02-18','Weight check and diet advice', 750.00),

-- Kiki (Parrot) - Minor Surgery
((SELECT animal_id FROM Animals WHERE name='Kiki'),
 (SELECT procedure_id FROM Procedures WHERE name='Minor Surgery'),
 (SELECT staff_id FROM Staff WHERE first_name='Lina' AND last_name='Berg'),
 '2023-11-20','Wing injury repair', 3600.00),

-- Thor (Dog) - Major Surgery
((SELECT animal_id FROM Animals WHERE name='Thor'),
 (SELECT procedure_id FROM Procedures WHERE name='Major Surgery'),
 (SELECT staff_id FROM Staff WHERE first_name='Lina' AND last_name='Berg'),
 '2022-09-05','Cruciate ligament repair', 9800.00);
