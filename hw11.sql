use shop;
-- 1.Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, catalogs и 
-- products в таблицу logs помещается время и дата создания записи, название таблицы, 
-- идентификатор первичного ключа и содержимое поля name.

DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
  created_at DATETIME,
  table_name VARCHAR(100) NOT NULL,
  record_id INT UNSIGNED NOT NULL,
  name_value VARCHAR(150)
  ) ENGINE = ARCHIVE;

DROP TRIGGER IF EXISTS log_users_insert;

DELIMITER //
CREATE TRIGGER log_users_insert AFTER INSERT ON users
FOR EACH ROW 
BEGIN
  INSERT INTO logs(created_at, table_name, record_id, name_value)
  VALUE (NOW(), 'users', NEW.id, NEW.name);
END//

DELIMITER ;

SELECT * FROM logs;

SELECT * FROM users;
INSERT INTO users VALUES(11, 'Alevtina', '1998-10-25', NOW(), NOW());

DROP TRIGGER IF EXISTS log_products_insert;
DELIMITER //
CREATE TRIGGER log_products_insert AFTER INSERT ON products
FOR EACH ROW 
BEGIN
  INSERT INTO logs(created_at, table_name, record_id, name_value)
  VALUE (NOW(), 'products', NEW.id, NEW.name);
END//

DELIMITER ;

SELECT * FROM products;
INSERT INTO products VALUES(16, 'ASRock B450 Pro4', 'AM4, AMD B450, 4xDDR4-3200 МГц', 6850, 2, NOW(), NOW());


DROP TRIGGER IF EXISTS log_catalogs_insert;
DELIMITER //
CREATE TRIGGER log_catalogs_insert AFTER INSERT ON catalogs
FOR EACH ROW 
BEGIN
  INSERT INTO logs(created_at, table_name, record_id, name_value)
  VALUE (NOW(), 'catalogs', NEW.id, NEW.name);
END//

DELIMITER ;

SELECT * FROM catalogs;
INSERT INTO catalogs VALUES(7, 'SSD накопители');

-- 2. Создайте SQL-запрос, который помещает в таблицу users миллион записей.

DROP TABLE IF EXISTS test_users; 
CREATE TABLE test_users (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255),
	birthday_at DATE,
	`created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
 	`updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

DROP PROCEDURE IF EXISTS insert_into_users ;
delimiter //
CREATE PROCEDURE insert_into_users ()
BEGIN
	DECLARE i INT DEFAULT 10000;
	DECLARE j INT DEFAULT 1;
	WHILE i > 0 DO
		INSERT INTO test_users(name, birthday_at) VALUES (CONCAT('user_', j), NOW());
		SET j = j + 1;
		SET i = i - 1;
	END WHILE;
END //
delimiter ;

UPDATE test_users SET birthday_at = FROM_UNIXTIME( 
  RAND( ) * ( UNIX_TIMESTAMP( '2005-12-31' ) - UNIX_TIMESTAMP( '1960-01-01')));

SELECT * FROM test_users;

TRUNCATE test_users;

CALL insert_into_users();

SELECT * FROM test_users ORDER BY id DESC LIMIT 10;

-- Практическое задание по теме “NoSQL”
-- В базе данных Redis подберите коллекцию для подсчета посещений с определенных IP-адресов.

ann@ann-VirtualBox:~$ redis-cli
127.0.0.1:6379> set key value
OK
127.0.0.1:6379> get key
"value"
127.0.0.1:6379> SADD ip '127.0.0.1' '127.0.0.2' '127.0.0.3' '127.0.0.4'
(integer) 4
127.0.0.1:6379> SADD ip '127.0.0.1'
(integer) 0
127.0.0.1:6379> SMEMBERS ip
1) "127.0.0.4"
2) "127.0.0.2"
3) "127.0.0.3"
4) "127.0.0.1"
127.0.0.1:6379> SCARD id
(integer) 0
127.0.0.1:6379> SCARD ip
(integer) 4

-- При помощи базы данных Redis решите задачу поиска имени пользователя по электронному адресу и наоборот, 
-- поиск электронного адреса пользователя по его имени.
127.0.0.1:6379> MSET email1@mail.ru Ivan email2@mail.ru Alexandra
OK
127.0.0.1:6379> MSET Ivan email1@mail.ru Alexandra email2@mail.ru
OK
127.0.0.1:6379> GET Ivan
"email1@mail.ru"
127.0.0.1:6379> GET email2@mail.ru
"Alexandra"

-- Организуйте хранение категорий и товарных позиций учебной базы данных shop в СУБД MongoDB.

USE shop;

SELECT * FROM catalogs;

SELECT * FROM products;

ann@ann-VirtualBox:~$ mongo
MongoDB shell version v3.6.3
connecting to: mongodb://127.0.0.1:27017
MongoDB server version: 3.6.3
Server has startup warnings: 
2020-06-10T17:38:50.780+0300 I STORAGE  [initandlisten] 
2020-06-10T17:38:50.780+0300 I STORAGE  [initandlisten] ** WARNING: Using the XFS filesystem is strongly recommended with the WiredTiger storage engine
2020-06-10T17:38:50.780+0300 I STORAGE  [initandlisten] **          See http://dochub.mongodb.org/core/prodnotes-filesystem
2020-06-10T17:38:54.022+0300 I CONTROL  [initandlisten] 
2020-06-10T17:38:54.022+0300 I CONTROL  [initandlisten] ** WARNING: Access control is not enabled for the database.
2020-06-10T17:38:54.022+0300 I CONTROL  [initandlisten] **          Read and write access to data and configuration is unrestricted.
2020-06-10T17:38:54.022+0300 I CONTROL  [initandlisten] 
> use shop
switched to db shop
> db.products.insert([{"name":"Процессоры"}, {"name" : "Мат.платы"}, {"name" : "Видеокарты"},  {"name": "Блок питания"}])
WriteResult({ "nInserted" : 4 })
> db.catalogs.find().pretty()
{ "_id" : ObjectId("5ee0f8cc22db067908747293"), "name" : "Процессоры" }
{ "_id" : ObjectId("5ee0f8cc22db067908747294"), "name" : "Мат.платы" }
{ "_id" : ObjectId("5ee0f8cc22db067908747295"), "name" : "Видеокарты" }
{ "_id" : ObjectId("5ee0f8cc22db067908747296"), "name" : "Блок питания" }
> db.products.insert({"name":"AMD Athlon X4 840 OEM", "description":"FM2+, 4 x 3100 МГц, L2 - 4 МБ, 2хDDR3-2133 МГц, TDP 65 Вт", "price": "1850.00", "catalog_id" : "1",  "created_at": new Date(), "updated_at": new Date()})
WriteResult({ "nInserted" : 1 })
> db.products.find()
{ "_id" : ObjectId("5ee0fc35c6a14d50c0de10aa"), "name" : "AMD Athlon X4 840 OEM", "description" : "FM2+, 4 x 3100 МГц, L2 - 4 МБ, 2хDDR3-2133 МГц, TDP 65 Вт", "price" : "1850.00", "catalog_id" : "1", "created_at" : ISODate("2020-06-10T15:28:53.367Z"), "updated_at" : ISODate("2020-06-10T15:28:53.367Z") }
> > db.products.insertMany([
... {"name":"Aerocool VX PLUS 500W [VX-500 PLUS]", "description":"500 Вт, EPS12V, 20+4 pin, 1x 4+4 pin CPU, 3 шт SATA, 1x 6+2 pin PCI-E]", "price": "2199.00", "catalog_id" : "4",  "created_at": new Date(), "updated_at": new Date()},
... {"name":"Intel Celeron G4900 OEM", "description":"LGA 1151-v2, 2 x 3100 МГц, L2 - 512 КБ, L3 - 2 МБ, 2хDDR4-2400 МГц, Intel UHD Graphics 610, TDP 54 Вт", "price": "2999.00", "catalog_id" : "1",  "created_at": new Date(), "updated_at": new Date()},
... {"name":"Kingston HyperX FURY Black [HX426C16FB3K2/16] 16 ГБ", "description":"[DDR4, 8 ГБx2 шт, 2666 МГц, PC21300, 16-18-18-29.25", "price": "6999.00", "catalog_id" : "6",  "created_at": new Date(), "updated_at": new Date()}])
{
	"acknowledged" : true,
	"insertedIds" : [
		ObjectId("5ee102f5026b3d09fd1c4491"),
		ObjectId("5ee102f5026b3d09fd1c4492"),
		ObjectId("5ee102f5026b3d09fd1c4493")
	]
}
> db.products.find().pretty()
{
	"_id" : ObjectId("5ee0fc35c6a14d50c0de10aa"),
	"name" : "AMD Athlon X4 840 OEM",
	"descri^Cion" : "FM2+, 4 x 3100 МГц, L2 - 4 МБ, 2хDDR3-2133 МГц, TDP 65 Вт",
	"price" : "1850.00",
	"catalog_id" : "1",
	"created_at" : ISODate("2020-06-10T15:28:53.367Z"),
	"updated_at" : ISODate("2020-06-10T15:28:53.367Z")
}
{
	"_id" : ObjectId("5ee102f5026b3d09fd1c4491"),
	"name" : "Aerocool VX PLUS 500W [VX-500 PLUS]",
	"description" : "500 Вт, EPS12V, 20+4 pin, 1x 4+4 pin CPU, 3 шт SATA, 1x 6+2 pin PCI-E]",
	"price" : "2199.00",
	"catalog_id" : "4",
	"created_at" : ISODate("2020-06-10T15:57:41.767Z"),
	"updated_at" : ISODate("2020-06-10T15:57:41.768Z")
}
{
	"_id" : ObjectId("5ee102f5026b3d09fd1c4492"),
	"name" : "Intel Celeron G4900 OEM",
	"description" : "LGA 1151-v2, 2 x 3100 МГц, L2 - 512 КБ, L3 - 2 МБ, 2хDDR4-2400 МГц, Intel UHD Graphics 610, TDP 54 Вт",
	"price" : "2999.00",
	"catalog_id" : "1",
	"created_at" : ISODate("2020-06-10T15:57:41.769Z"),
	"updated_at" : ISODate("2020-06-10T15:57:41.769Z")
}
{
	"_id" : ObjectId("5ee102f5026b3d09fd1c4493"),
	"name" : "Kingston HyperX FURY Black [HX426C16FB3K2/16] 16 ГБ",
	"description" : "[DDR4, 8 ГБx2 шт, 2666 МГц, PC21300, 16-18-18-29.25",
	"price" : "6999.00",
	"catalog_id" : "6",
	"created_at" : ISODate("2020-06-10T15:57:41.769Z"),
	"updated_at" : ISODate("2020-06-10T15:57:41.769Z")
}
