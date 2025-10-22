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
