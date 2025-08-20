-- Schema
CREATE DATABASE IF NOT EXISTS airlines_db;

-- =========================
-- 1) AIRLINE
-- =========================
CREATE TABLE airline (
  airline_id     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name           VARCHAR(150) NOT NULL,
  address        VARCHAR(200),
  contact_person VARCHAR(120),
  telephone      VARCHAR(30),
  CONSTRAINT pk_airline PRIMARY KEY (airline_id),
  CONSTRAINT uq_airline_name UNIQUE (name)
) ENGINE=InnoDB;

-- =========================
-- 2) EMPLOYEE
-- =========================
CREATE TABLE employee (
  emp_id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  emp_name        VARCHAR(150) NOT NULL,
  emp_address     VARCHAR(200),
  day             TINYINT UNSIGNED,     -- 1..31
  month           TINYINT UNSIGNED,     -- 1..12
  year            SMALLINT UNSIGNED,    -- e.g., 1950..2100
  gender          ENUM('M','F','Other') DEFAULT 'Other',
  position        VARCHAR(80),
  qualifications  VARCHAR(200),
  airline_id      INT UNSIGNED NOT NULL,      -- FK
  CONSTRAINT pk_employee PRIMARY KEY (emp_id),
  CONSTRAINT fk_employee_airline
    FOREIGN KEY (airline_id) REFERENCES airline(airline_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_day  CHECK (day  IS NULL OR (day  BETWEEN 1 AND 31)),
  CONSTRAINT chk_mon  CHECK (month IS NULL OR (month BETWEEN 1 AND 12)),
  CONSTRAINT chk_year CHECK (year IS NULL OR (year BETWEEN 1900 AND 2100))
) ENGINE=InnoDB;

CREATE INDEX ix_emp_airline ON employee(airline_id);

-- =========================
-- 3) AIRCRAFT
-- =========================
CREATE TABLE aircraft (
  aircraft_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  capacity    INT UNSIGNED NOT NULL,
  model       VARCHAR(120) NOT NULL,
  airline_id  INT UNSIGNED NOT NULL,
  CONSTRAINT pk_aircraft PRIMARY KEY (aircraft_id),
  CONSTRAINT fk_aircraft_airline
    FOREIGN KEY (airline_id) REFERENCES airline(airline_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_capacity CHECK (capacity > 0)
) ENGINE=InnoDB;

CREATE INDEX ix_aircraft_airline ON aircraft(airline_id);

-- =========================
-- 4) ROUTE
-- =========================
CREATE TABLE route (
  route_id       INT UNSIGNED NOT NULL AUTO_INCREMENT,
  origin         VARCHAR(100) NOT NULL,
  destination    VARCHAR(100) NOT NULL,
  distance_km    DECIMAL(8,1),                     
  classification VARCHAR(50),                      
  CONSTRAINT pk_route PRIMARY KEY (route_id),
  CONSTRAINT chk_distance CHECK (distance_km IS NULL OR distance_km >= 0)
) ENGINE=InnoDB;

-- =========================
-- 5) FLIGHT_ASSIGNMENT
-- A specific flight of an aircraft on a route at a datetime.
-- Adds a surrogate flight_id; you could also use a composite PK if desired.
-- travel_duration is generated in MINUTES for accuracy.
-- =========================
CREATE TABLE flight_assignment (
  flight_id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  aircraft_id          INT UNSIGNED NOT NULL,
  route_id             INT UNSIGNED NOT NULL,
  num_passengers       INT UNSIGNED DEFAULT 0,
  price_per_passenger  DECIMAL(10,2) DEFAULT 0.00,
  departure_datetime   DATETIME NOT NULL,
  arrival_datetime     DATETIME NOT NULL,
  CONSTRAINT pk_flight PRIMARY KEY (flight_id),
  CONSTRAINT fk_fa_aircraft
    FOREIGN KEY (aircraft_id) REFERENCES aircraft(aircraft_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_fa_route
    FOREIGN KEY (route_id) REFERENCES route(route_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_times CHECK (arrival_datetime > departure_datetime)
) ENGINE=InnoDB;

CREATE INDEX ix_fa_aircraft ON flight_assignment(aircraft_id);
CREATE INDEX ix_fa_route    ON flight_assignment(route_id);
CREATE INDEX ix_fa_depart   ON flight_assignment(departure_datetime);

-- =========================
-- 6) CREW

-- =========================
CREATE TABLE crew (
  crew_id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  major_pilot     INT UNSIGNED NOT NULL,  -- FK -> employee
  assistant_pilot INT UNSIGNED,           -- FK -> employee
  aircraft_id     INT UNSIGNED NOT NULL,  -- FK -> aircraft
  CONSTRAINT pk_crew PRIMARY KEY (crew_id),
  CONSTRAINT fk_crew_major
    FOREIGN KEY (major_pilot) REFERENCES employee(emp_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_crew_assistant
    FOREIGN KEY (assistant_pilot) REFERENCES employee(emp_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_crew_aircraft
    FOREIGN KEY (aircraft_id) REFERENCES aircraft(aircraft_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX ix_crew_aircraft ON crew(aircraft_id);

-- =========================
-- 7) TRANSACTION (financial)
-- =========================
CREATE TABLE txn (
  transaction_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  date_          DATE NOT NULL,
  description    VARCHAR(200),
  amount         DECIMAL(12,2) NOT NULL,
  type           ENUM('Credit','Debit') NOT NULL,
  airline_id     INT UNSIGNED NOT NULL,
  CONSTRAINT pk_txn PRIMARY KEY (transaction_id),
  CONSTRAINT fk_txn_airline
    FOREIGN KEY (airline_id) REFERENCES airline(airline_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_amount CHECK (amount >= 0)
) ENGINE=InnoDB;

CREATE INDEX ix_txn_airline ON txn(airline_id);
CREATE INDEX ix_txn_date    ON txn(date_);

-- =========================
-- 8) CREW_HOSTESS
-- A crew can have multiple hostesses (who are employees).
-- =========================
CREATE TABLE crew_hostess (
  crew_id INT UNSIGNED NOT NULL,
  emp_id  INT UNSIGNED NOT NULL,  -- hostess (employee)
  CONSTRAINT pk_crew_hostess PRIMARY KEY (crew_id, emp_id),
  CONSTRAINT fk_ch_crew
    FOREIGN KEY (crew_id) REFERENCES crew(crew_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_ch_emp
    FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX ix_ch_emp ON crew_hostess(emp_id);
