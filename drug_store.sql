-- Создание базы данных
CREATE DATABASE drug_store;

-- Удаление всех таблиц, если они существуют
DROP TABLE IF EXISTS "Reservation";
DROP TABLE IF EXISTS "Sales";
DROP TABLE IF EXISTS "Stock";
DROP TABLE IF EXISTS "DiseaseMedicines";
DROP TABLE IF EXISTS "Disease";
DROP TABLE IF EXISTS "Pharmacy";
DROP TABLE IF EXISTS "Medicines";
DROP TABLE IF EXISTS "Manufacturer";

-- Удаление всех функций, если они существуют
DROP FUNCTION IF EXISTS "getMedicines"();
DROP FUNCTION IF EXISTS "reserveMedicines"(INT, INT, INT);
DROP FUNCTION IF EXISTS "getStock"(INT, INT);
DROP FUNCTION IF EXISTS "getSales"(INT, DATE, DATE);
DROP FUNCTION IF EXISTS "searchMedicine"(VARCHAR(255));
DROP FUNCTION IF EXISTS "getMedicinesForDisease"(INT);

-- Создание таблицы "Manufacturer"
CREATE TABLE "Manufacturer" (
  id serial PRIMARY KEY,
  name VARCHAR(255),
  country VARCHAR(255)
);

-- Создание таблицы "Medicines"
CREATE TABLE "Medicines" (
  id serial PRIMARY KEY,
  name VARCHAR(255),
  form VARCHAR(255),
  expiration_date DATE,
  annotation TEXT,
  price DECIMAL(10, 2),
  manufacturer_id INT,
  FOREIGN KEY (manufacturer_id) REFERENCES "Manufacturer"(id)
);

-- Создание таблицы "Pharmacy"
CREATE TABLE "Pharmacy" (
  id serial PRIMARY KEY,
  name VARCHAR(255),
  location VARCHAR(255)
);

-- Создание таблицы "Stock"
CREATE TABLE "Stock" (
  id serial PRIMARY KEY,
  pharmacy_id INT,
  medicine_id INT,
  quantity INT,
  FOREIGN KEY (pharmacy_id) REFERENCES "Pharmacy"(id),
  FOREIGN KEY (medicine_id) REFERENCES "Medicines"(id)
);

-- Создание таблицы "Sales"
CREATE TABLE "Sales" (
  id serial PRIMARY KEY,
  pharmacy_id INT,
  medicine_id INT,
  quantity INT,
  sale_date DATE,
  FOREIGN KEY (pharmacy_id) REFERENCES "Pharmacy"(id),
  FOREIGN KEY (medicine_id) REFERENCES "Medicines"(id)
);

-- Создание таблицы "Reservation"
CREATE TABLE "Reservation" (
  id serial PRIMARY KEY,
  pharmacy_id INT,
  medicine_id INT,
  quantity INT,
  reservation_date DATE,
  FOREIGN KEY (pharmacy_id) REFERENCES "Pharmacy"(id),
  FOREIGN KEY (medicine_id) REFERENCES "Medicines"(id)
);

-- Создание таблицы "Disease"
CREATE TABLE "Disease" (
  id serial PRIMARY KEY,
  name VARCHAR(255)
);

-- Создание таблицы "DiseaseMedicines"
CREATE TABLE "DiseaseMedicines" (
  id serial PRIMARY KEY,
  disease_id INT,
  medicine_id INT,
  FOREIGN KEY (disease_id) REFERENCES "Disease"(id),
  FOREIGN KEY (medicine_id) REFERENCES "Medicines"(id)
);

-- Функция для получения данных о лекарствах
CREATE FUNCTION "getMedicines"()
RETURNS TABLE (
  id INT,
  name VARCHAR(255),
  form VARCHAR(255),
  expiration_date DATE,
  annotation TEXT,
  price DECIMAL(10, 2),
  manufacturer_id INT
)
AS $$
BEGIN
  RETURN QUERY SELECT * FROM "Medicines";
END;
$$ LANGUAGE plpgsql;

-- Функция для бронирования лекарств
CREATE FUNCTION "reserveMedicines"(pharmacy_id INT, medicine_id INT, quantity INT)
RETURNS VOID
AS $$
BEGIN
  INSERT INTO "Reservation" (pharmacy_id, medicine_id, quantity, reservation_date)
  VALUES (pharmacy_id, medicine_id, quantity, CURRENT_DATE + INTERVAL '3 days');
END;
$$ LANGUAGE plpgsql;

-- Функция для получения информации о поступлении лекарства в аптеку
CREATE FUNCTION "getStock"(p_id INT, m_id INT)
RETURNS TABLE (
  id INT,
  pharmacy_id INT,
  medicine_id INT,
  quantity INT
)
AS $$
BEGIN
  RETURN QUERY SELECT * FROM "Stock"
  WHERE "Stock".pharmacy_id = p_id AND "Stock".medicine_id = m_id;
END;
$$ LANGUAGE plpgsql;

-- Функция для получения информации о продажах лекарства за определенный период
CREATE FUNCTION "getSales"(m_id INT, start_date DATE, end_date DATE)
RETURNS TABLE (
  id INT,
  pharmacy_id INT,
  medicine_id INT,
  quantity INT,
  sale_date DATE
)
AS $$
BEGIN
  RETURN QUERY SELECT * FROM "Sales"
  WHERE "Sales".medicine_id = m_id AND "Sales".sale_date BETWEEN start_date AND end_date;
END;
$$ LANGUAGE plpgsql;

-- Функция для поиска лекарства по названию, форме выпуска или изготовителю
CREATE FUNCTION "searchMedicine"(keyword VARCHAR(255))
RETURNS TABLE (
  id INT,
  name VARCHAR(255),
  form VARCHAR(255),
  expiration_date DATE,
  annotation TEXT,
  price DECIMAL(10, 2),
  manufacturer_id INT
)
AS $$
BEGIN
  RETURN QUERY SELECT * FROM "Medicines"
  WHERE "Medicines".name ILIKE '%' || keyword || '%' OR "Medicines".form ILIKE '%' || keyword || '%' OR CAST("Medicines".manufacturer_id AS TEXT) ILIKE '%' || keyword || '%';
END;
$$ LANGUAGE plpgsql;

-- Функция для получения списка лекарств для выбранной болезни
CREATE FUNCTION "getMedicinesForDisease"(d_id INT)
RETURNS TABLE (
  id INT,
  name VARCHAR(255),
  form VARCHAR(255),
  expiration_date DATE,
  annotation TEXT,
  price DECIMAL(10, 2),
  manufacturer_id INT
)
AS $$
BEGIN
  RETURN QUERY SELECT m.id, m.name, m.form, m.expiration_date, m.annotation, m.price, m.manufacturer_id
  FROM "Medicines" m
  INNER JOIN "DiseaseMedicines" dm ON m.id = dm.medicine_id
  WHERE dm.disease_id = d_id;
END;
$$ LANGUAGE plpgsql;

-- Вставка данных в таблицу "Manufacturer"
INSERT INTO "Manufacturer" (id, name, country)
VALUES (1, 'Bayer', 'Germany'),
       (2, 'Johnson & Johnson', 'USA'),
       (3, 'Pfizer', 'USA');

-- Вставка данных в таблицу "Medicines"
INSERT INTO "Medicines" (id, name, form, expiration_date, annotation, price, manufacturer_id)
VALUES (1, 'Aspirin', 'Tablet', '2023-01-01', 'Aspirin is a medication used to treat pain, fever, or inflammation.', 5.99, 1),
       (2, 'Paracetamol', 'Tablet', '2023-01-01', 'Paracetamol is a medication used to treat pain and fever.', 3.99, 2),
       (3, 'Ibuprofen', 'Tablet', '2023-01-01', 'Ibuprofen is a medication used to treat pain, fever, or inflammation.', 4.99, 3);

-- Вставка данных в таблицу "Pharmacy"
INSERT INTO "Pharmacy" (id, name, location)
VALUES (1, 'Pharmacy 1', '123 Main Street'),
       (2, 'Pharmacy 2', '456 Elm Street');

-- Вставка данных в таблицу "Stock"
INSERT INTO "Stock" (id, pharmacy_id, medicine_id, quantity)
VALUES (1, 1, 1, 100),
       (2, 1, 2, 200),
       (3, 2, 3, 150);

-- Вставка данных в таблицу "Sales"
INSERT INTO "Sales" (id, pharmacy_id, medicine_id, quantity, sale_date)
VALUES (1, 1, 1, 10, '2023-01-01'),
       (2, 1, 2, 20, '2023-01-02'),
       (3, 2, 3, 15, '2023-01-03');

-- Вставка данных в таблицу "Reservation"
INSERT INTO "Reservation" (pharmacy_id, medicine_id, quantity, reservation_date)
VALUES (1, 1, 5, '2023-01-01'),
       (1, 2, 10, '2023-01-02');

-- Вставка данных в таблицу "Disease"
INSERT INTO "Disease" (id, name)
VALUES (1, 'Headache'),
       (2, 'Fever');

-- Вставка данных в таблицу "DiseaseMedicines"
INSERT INTO "DiseaseMedicines" (id, disease_id, medicine_id)
VALUES (1, 1, 1),
       (2, 2, 2);

-- Вызов функции для получения данных о лекарствах
SELECT * FROM "getMedicines"();

-- Вызов функции для бронирования лекарств
SELECT "reserveMedicines"(1, 1, 5);

-- Вызов функции для получения информации о поступлении лекарства в аптеку
SELECT * FROM "getStock"(1, 1);

-- Вызов функции для получения информации о продажах лекарства за определенный период
SELECT * FROM "getSales"(1, '2023-01-01', '2023-01-02');

-- Вызов функции для поиска лекарства по названию, форме выпуска или изготовителю
SELECT * FROM "searchMedicine"('Aspirin');

-- Вызов функции для получения списка лекарств для выбранной болезни
SELECT * FROM "getMedicinesForDisease"(1);

-- Удаление базы данных
DROP DATABASE drug_store;
