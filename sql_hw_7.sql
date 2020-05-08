USE shop;

DESC users;

SELECT*FROM users;

ALTER TABLE users MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;

DESC orders;
ALTER TABLE orders MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE orders
  ADD CONSTRAINT orders_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE;

DESC products;
ALTER TABLE products MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;

DESC catalogs;
ALTER TABLE catalogs MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE products
  ADD CONSTRAINT products_catalog_id_fk 
    FOREIGN KEY (catalog_id) REFERENCES catalogs(id)
      ON DELETE CASCADE;
     
SELECT*FROM catalogs;

INSERT INTO products VALUES
   (1, 'AMD Athlon X4 840 OEM', 'FM2+, 4 x 3100 МГц, L2 - 4 МБ, 2хDDR3-2133 МГц, TDP 65 Вт', 1850, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
   (2, 'Aerocool VX PLUS 500W [VX-500 PLUS]', '500 Вт, EPS12V, 20+4 pin, 1x 4+4 pin CPU, 3 шт SATA, 1x 6+2 pin PCI-E]', 2199, 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
   (3, 'Intel Celeron G4900 OEM', 'LGA 1151-v2, 2 x 3100 МГц, L2 - 512 КБ, L3 - 2 МБ, 2хDDR4-2400 МГц, Intel UHD Graphics 610, TDP 54 Вт', 2999, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
   (4, 'Kingston HyperX FURY Black [HX426C16FB3K2/16] 16 ГБ', '[DDR4, 8 ГБx2 шт, 2666 МГц, PC21300, 16-18-18-29.25', 6999, 6, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
   (5, 'GIGABYTE GeForce GTX 1660 SUPER OC [GV-N166SOC-6GD 1.0]', 'PCI-E 3.0, 6 ГБ GDDR6, 192 бит, 1530 МГц - 1830 МГц, DisplayPort (3 шт), HDMI', 19799, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
   (6, 'MD Ryzen 3 1200 OEM', 'AM4, 4 x 3100 МГц, L2 - 2 МБ, L3 - 8 МБ, 2хDDR4-2667 МГц, TDP 65 Вт', 3799, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
   (7, 'be quiet SYSTEM POWER 9 700W [BN248]', '700 Вт, 80+ Bronze, EPS12V, APFC, 20+4 pin, 1x 4+4 pin CPU, 6 шт SATA, 4x 6+2 pin PCI-E', 6350, 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
   (8, 'MSI X570-A PRO', 'AM4, AMD X570, 4xDDR4-4400 МГц, 2xPCI-Ex16, аудио 7.1, Standard-ATX', 12999, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
   (9, 'ASRock B450 Pro4', 'AM4, AMD B450, 4xDDR4-3200 МГц, 2xPCI-Ex16, аудио 7.1, Standard-ATX', 6950, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
   (10, '1 ТБ Жесткий диск WD Blue [WD10EZEX]', 'SATA III, 6 Гбит/с, 7200 об/мин, кэш память - 64 МБ', 3199, 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
   (11, 'MSI AMD Radeon RX 570 ARMOR OC [RX 570 ARMOR 4G OC]', 'PCI-E 3.0, 4 ГБ GDDR5, 256 бит, 1168 МГц - 1268 МГц, HDMI, DisplayPort (3 шт), DVI-D', 11199, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
   (12, 'GIGABYTE GA-AB350M-DS3H V2', 'AM4, AMD B350, 4xDDR4-3200 МГц, 1xPCI-Ex16, аудио 7.1, Micro-ATX', 4899, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
   
SELECT*FROM products; 

DESC orders_products;
ALTER TABLE orders_products MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE orders_products
  ADD CONSTRAINT orders_products_order_id_fk 
    FOREIGN KEY (order_id) REFERENCES orders(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT orders_products_product_id_fk 
    FOREIGN KEY (product_id) REFERENCES products(id)
      ON DELETE CASCADE;

     INSERT INTO orders
  SELECT 
    id, 
    FLOOR(1 + (RAND() * 10)),
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP 
  FROM products;
 
-- 1. Составьте список пользователей users, которые осуществили хотя бы оди заказ orders в интернет магазине.
     
SELECT*FROM orders;
SELECT*FROM users;

-- В таблице orders есть все пользователи, которые делали заказы (то есть 1 заказ и более), пользователей, которые не делали заказы нет, 
-- Группируем сделавших заказы по количеству заказов, считаем их.
 
SELECT user_id as id, COUNT(*) AS quantity FROM orders GROUP BY user_id;

-- Выводим имена пользователей из таблицы users по полученным id.

SELECT id, name FROM users WHERE id IN (SELECT user_id as id FROM orders GROUP BY user_id);

-- С помощью JOIN

SELECT u.id, u.name, COUNT(*) AS quantity FROM users AS u JOIN orders AS o WHERE u.id = o.user_id GROUP BY id;

-- 2. Выведите список товаров products и разделов catalogs, который соответствует товару.

SELECT*FROM products;
SELECT*FROM catalogs;

SELECT id, name, catalog_id FROM products;

SELECT p.id, p.name, c.name FROM products AS p JOIN catalogs AS c ON catalog_id = c.id ORDER BY p.id;

-- 3. Пусть имеется таблица flights (id, from, to) и таблица городов cities (label, name). 
-- Поля from, to и label содержат английские названия городов, поле name - русское. 
-- Выведите список рейсов flights с русскими названиями городов.

DROP TABLE IF EXISTS flights;
CREATE TABLE flights (
   id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
   departure VARCHAR(100),
   arrival VARCHAR(100)
);

DROP TABLE IF EXISTS cities;
CREATE TABLE cities (
   label VARCHAR(100),
   name VARCHAR(100)
);

INSERT INTO flights VALUES
   (1, 'moscow', 'omsk'),
   (2, 'novgorod', 'kazan'),
   (3, 'irkutsk', 'moscow'),
   (4, 'omsk', 'irkutsk'),
   (5, 'moscow', 'kazan');

INSERT INTO cities VALUES
   ('moscow', 'Москва'),
   ('novgorod', 'Новгород'),
   ('irkutsk', 'Иркутск'),
   ('omsk', 'Омск'),
   ('kazan', 'Казань');

SELECT * FROM flights;

SELECT * FROM cities;

DESC flights;


SELECT dep.id AS id, dep.departure, ar.arrival FROM
   (SELECT f.id, c.name AS departure
      FROM flights AS f JOIN cities AS c 
      ON f.departure = c.label) AS dep
   JOIN 
   (SELECT f.id, c.name AS arrival
     FROM flights AS f JOIN cities AS c 
     ON f.arrival = c.label) AS ar
   WHERE dep.id = ar.id ORDER BY id;

