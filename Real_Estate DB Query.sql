
CREATE DATABASE  real_estate_db;
-- 1) SALES OFFICE
CREATE TABLE sales_office (
  office_number INT UNSIGNED NOT NULL,
  location      VARCHAR(150) NOT NULL,
  employee_id   INT UNSIGNED NULL,            
  CONSTRAINT pk_sales_office PRIMARY KEY (office_number)
) ENGINE=InnoDB;

-- 2) EMPLOYEE
CREATE TABLE employee (
  employee_id   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  employee_name VARCHAR(120) NOT NULL,
  office_number INT UNSIGNED NOT NULL,        -- FK to sales_office
  CONSTRAINT pk_employee PRIMARY KEY (employee_id),
  CONSTRAINT fk_employee_office
    FOREIGN KEY (office_number)
    REFERENCES sales_office(office_number)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

ALTER TABLE sales_office
  ADD CONSTRAINT fk_office_manager
    FOREIGN KEY (employee_id)
    REFERENCES employee(employee_id)
    ON UPDATE CASCADE
    ON DELETE SET NULL;

-- 3) PROPERTY
CREATE TABLE property (
  property_id   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  address       VARCHAR(200) NOT NULL,
  city          VARCHAR(100) NOT NULL,
  zip_code      VARCHAR(15),
  state         VARCHAR(50),
  office_number INT UNSIGNED NOT NULL,        -- the office that handles this property
  CONSTRAINT pk_property PRIMARY KEY (property_id),
  CONSTRAINT fk_property_office
    FOREIGN KEY (office_number)
    REFERENCES sales_office(office_number)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 4) OWNER
CREATE TABLE owner (
  owner_id   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  owner_name VARCHAR(150) NOT NULL,
  CONSTRAINT pk_owner PRIMARY KEY (owner_id)
) ENGINE=InnoDB;

-- 5) HAVE / OWNS (junction)
CREATE TABLE owns (
  property_id   INT UNSIGNED NOT NULL,
  owner_id      INT UNSIGNED NOT NULL,
  percent_owned DECIMAL(5,2) NOT NULL,  -- e.g., 33.33; stores 0.00–100.00
  CONSTRAINT pk_owns PRIMARY KEY (property_id, owner_id),
  CONSTRAINT fk_owns_property
    FOREIGN KEY (property_id)
    REFERENCES property(property_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_owns_owner
    FOREIGN KEY (owner_id)
    REFERENCES owner(owner_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT chk_percent_range
    CHECK (percent_owned >= 0.00 AND percent_owned <= 100.00)
) ENGINE=InnoDB;


