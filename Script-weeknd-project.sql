------------CREATE TABLES--------------------------------------------------------------------------------
CREATE TABLE "inventory"(
    "inventory_id" SERIAL PRIMARY KEY,
    "make" VARCHAR(20) NOT NULL,
    "model" VARCHAR(20) NOT NULL,
    "year" varchar (4) NOT NULL,
    "condition" VARCHAR(20) NOT NULL,
    "VIN" VARCHAR(20) NOT NULL,
    "price" decimal (8,2) NOT NULL,
    "status" varchar (55) NOT NULL
);

CREATE TABLE "sales_team"(
    "staff_id" SERIAL PRIMARY KEY ,
    "first_name" VARCHAR(20) NOT NULL,
    "last_name" VARCHAR(20) NOT NULL,
    "phone" VARCHAR(20) NOT NULL
);

CREATE TABLE "customer"(
    "customer_id" SERIAL PRIMARY KEY ,
    "first_name" VARCHAR(20) NOT NULL,
    "last_name" VARCHAR(20),
    "email" VARCHAR(100),
    "phone" VARCHAR(20),
    "address" VARCHAR(100)
);

CREATE TABLE "invoice"(
    "invoice_id" SERIAL PRIMARY KEY ,
    "inventory_id" INTEGER NOT NULL,
    "VIN" VARCHAR(255) NOT NULL,
    "customer_id" INTEGER NOT NULL,
    "total" decimal(8,2) NOT NULL,
    "date" DATE NOT NULL,
    "staff_id" INTEGER NOT NULL,
    FOREIGN KEY(inventory_id) REFERENCES inventory(inventory_id),
    UNIQUE (inventory_id),
    FOREIGN KEY(staff_id) REFERENCES sales_team(staff_id),
    FOREIGN KEY(customer_id) REFERENCES customer(customer_id)
);

CREATE TABLE "services"(
    "service_id" SERIAL PRIMARY KEY ,
    "name" VARCHAR(100) NOT NULL,
    "total" decimal (8,2) NOT NULL
);

CREATE TABLE "mechanics"(
    "mech_id" SERIAL PRIMARY KEY ,
    "first_name" VARCHAR(20) NOT NULL,
    "last_name" VARCHAR(20) NOT NULL,
    "phone" VARCHAR(20) NOT NULL,
    "title" VARCHAR(50)
);

CREATE TABLE "repair"(
    "ticket_id" SERIAL PRIMARY KEY ,
    "customer_id" INTEGER NOT NULL,
    "car_id" INTEGER NOT NULL,
    "service_id" INTEGER NOT NULL,
    "repair_mechanics_id" integer NOT NULL,
    "total" decimal (8,2) NOT NULL,
    "date" DATE NOT NULL,
    FOREIGN KEY(service_id) REFERENCES services(service_id),
    FOREIGN KEY(customer_id) REFERENCES customer(customer_id)
);

CREATE TABLE "history" (
	history_id SERIAL PRIMARY KEY ,
	ticket_id integer,
	FOREIGN KEY (ticket_id) REFERENCES repair(ticket_id),
	UNIQUE (ticket_id)
);

CREATE TABLE "car" (
	car_id SERIAL PRIMARY KEY ,
	customer_id integer NOT  NULL,
	history_id integer,
	VIN varchar (55) NOT NULL,
	make varchar (20) NOT NULL,
	model varchar (20) NOT NULL,
	"year" varchar(4) NOT NULL,
	mile_age integer,
	FOREIGN KEY (history_id) REFERENCES history(history_id),
	FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

CREATE TABLE "repair_mechanics" (
	"repair_mechanics_id" SERIAL PRIMARY KEY,
	"ticket_id" integer NOT NULL,
	"mech1_id" integer,
	"mech2_id" integer,
	"mech3_id" integer,
	FOREIGN KEY (mech1_id) REFERENCES mechanics(mech_id),
	FOREIGN KEY (mech2_id) REFERENCES mechanics(mech_id),
	FOREIGN KEY (mech3_id) REFERENCES mechanics(mech_id)
);

ALTER TABLE repair  ADD CONSTRAINT repair_mechanics_id FOREIGN KEY(repair_mechanics_id) REFERENCES repair_mechanics(repair_mechanics_id);
   
ALTER TABLE repair  ADD CONSTRAINT car_id FOREIGN KEY(car_id) REFERENCES car(car_id);


   

----------------FUNCTIONS------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE insert_inventory (
    _make VARCHAR(55),
    _model VARCHAR(55),
    _year INTEGER,
    _condition VARCHAR(22),
    _VIN VARCHAR(55),
    _price decimal (8,2),
    _status VARCHAR (20)
)AS 
$$
	BEGIN 
	INSERT INTO  inventory(make, model, "year", "condition", "VIN", price, status)
	VALUES (_make, _model, _year, _condition, _VIN, _price, _status);
	COMMIT;
	END;
$$
LANGUAGE plpgsql;

CALL  insert_inventory ('BWM', 'X5', 2023, 'New', 'BWMD842027400', 55000, 'available')
CALL insert_inventory('MERCEDES','C300',2020, 'Used','HT6736343454', 38000, 'available') 
CALL  insert_inventory ('TOYOTA', 'CIVIC', 2023, 'New', 'YF847492344', 33000, 'available')


CREATE OR REPLACE PROCEDURE insert_sales_team (
	_first_name varchar (55),
	_last_name varchar(55),
	_phone	varchar(55)
) AS 
$$
	BEGIN 
		INSERT INTO sales_team(first_name, last_name, phone)
		VALUES(_first_name, _last_name, _phone);
		COMMIT ;
	END;
$$
LANGUAGE plpgsql;

CALL insert_sales_team('David', 'Nguyen', '837-452-2352') 
CALL insert_sales_team('Chris', 'Tran', '673-324-2532') 
CALL insert_sales_team('Kelly', 'Pham', '453-335-2542') 


CREATE OR REPLACE PROCEDURE insert_customer(
	_first_name varchar (55),
	_last_name varchar(55),
	_email varchar(100),
	_phone	varchar(55),
	_address varchar (100)
) AS 
$$
	BEGIN 
		INSERT INTO customer(first_name, last_name, email, phone, address)
		VALUES(_first_name, _last_name,_email,  _phone, _address);
		COMMIT ;
	END;
$$
LANGUAGE plpgsql;

CALL insert_customer ('Hoa', 'Luu', 'fbeb@gmail.com', '665-422-5622', '534 HollyWearid Blv Phoenix CA USA')
CALL insert_customer ('Phu', 'Ha', 'nhdgi@gmail.com', '663-222-2532', '873 west drive Houston TX USA')
CALL insert_customer ('Khoa', 'Van', 'mymy@gmail.com', '0999-887-334', '2/77 Pham Van Thuan -Bien Hoa- Dong Nai- Viet Nam')


CREATE OR REPLACE PROCEDURE insert_invoice(
	_inventory_id integer,
	_VIN varchar (55),
	_customer_id integer,
	_total decimal (8,2),
	_date date,
	_staff_id integer
) AS 
$$
	BEGIN  
		UPDATE inventory SET  status = 'sold' WHERE inventory_id = _inventory_id  ;
		INSERT INTO invoice(inventory_id, "VIN",customer_id , total , "date" , staff_id  )
		VALUES(_inventory_id, _VIN, _customer_id, _total, _date, _staff_id);
		COMMIT ;
	END;
$$
LANGUAGE plpgsql;

CALL insert_invoice (1,'BWMD842027400' , 1, 55000,current_date, 1)
CALL insert_invoice (1,'BWMD842027400' , 3, 55000,current_date, 3) --- will RETURN error because inventory _id 1 was sold
CALL insert_invoice (2,'HT6736343454' , 1, 38000,current_date, 1)


INSERT INTO services ("name", total)
VALUES ('oil change',95  ),
('ignition', 290),
('water pump',90)

INSERT INTO mechanics (first_name, last_name, phone)
VALUES ('Jay', 'Noel', '536-343-5322'),
('Wow', 'Chiwowow', '556-666-3221'),
('Hi', 'Last', '444-333-2222');

INSERT INTO car (customer_id, vin ,	make ,model,"year" ,mile_age )
VALUES (3, 'TW6344634754', 'TESLA', 'S3', '2020', 45678 ),
		(2, 'TD65434534', 'HONDA', '999', '2023', 1001)


----
INSERT INTO repair_mechanics (repair_mechanics_id ,ticket_id , mech1_id, mech2_id)
VALUES (1, 1,3,2);

INSERT INTO repair (ticket_id , customer_id,car_id , service_id, repair_mechanics_id , total, "date")
VALUES (1, 3, 1, 3, 1,90, current_date);

INSERT INTO history(history_id ,ticket_id) 
VALUES (1,1);

UPDATE car SET history_id = 1 WHERE car_id = 1;
---
INSERT INTO repair_mechanics (repair_mechanics_id ,ticket_id , mech1_id, mech2_id, mech3_id)
VALUES (2,2, 1,3,2);

INSERT INTO repair (ticket_id , customer_id,car_id , service_id, repair_mechanics_id , total, "date")
VALUES (2, 2, 2, 3,2, 90, current_date);

INSERT INTO history(history_id ,ticket_id) 
VALUES (2,2);

UPDATE car SET history_id = 2 WHERE car_id = 2;
---
INSERT INTO repair_mechanics (repair_mechanics_id ,ticket_id , mech1_id, mech2_id, mech3_id)
VALUES (3,3, 1,3,2);
INSERT INTO repair (ticket_id , customer_id,car_id , service_id, repair_mechanics_id , total, "date")
VALUES (3, 2, 2, 2,3, 290, current_date);
INSERT INTO history(history_id ,ticket_id) 
VALUES (3,3);
UPDATE car SET history_id = 3 WHERE car_id = 2;