CREATE DATABASE tiendaX;
USE tiendaX;
CREATE TABLE Client(
id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(255) NOT NULL,
email VARCHAR(100) UNIQUE NOT NULL,
address VARCHAR(255) NOT NULL,
publicity BOOLEAN DEFAULT FALSE
);
CREATE TABLE Category(
id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(100)
);
CREATE TABLE Product(
id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(255),
stock INT,
price INT,
category INT,
disponibility VARCHAR(20) DEFAULT "available",
FOREIGN KEY (category) REFERENCES Category(id)
);
CREATE TABLE Sell(
id INT AUTO_INCREMENT PRIMARY KEY,
client INT,
dateOfSell DATETIME DEFAULT NOW(),
payMethod VARCHAR(20),
total INT DEFAULT 0,
destination VARCHAR(255),
FOREIGN KEY (client) REFERENCES Client(id)
);
CREATE TABLE SellDetail(
sell INT,
product INT,
quantity INT,
partialPrice INT DEFAULT 0, 
FOREIGN KEY (sell) REFERENCES Sell(id),
FOREIGN KEY (product) REFERENCES Product(id)
);

CREATE VIEW Send_Ads AS 
SELECT email 
FROM Client 
WHERE publicity = TRUE;

CREATE VIEW Best_Sellers AS
SELECT name, price
FROM Product
WHERE price < 50 AND stock > 0;

DELIMITER &&
CREATE TRIGGER Update_Product_Availability
BEFORE UPDATE ON Product
FOR EACH ROW
BEGIN
    IF NEW.stock >= 1 THEN
        SET NEW.disponibility = 'available';
    ELSE
        SET NEW.disponibility = 'spent';
    END IF;
END; &&
DELMITER;

DELIMITER && 
CREATE PROCEDURE Today_Total (OUT total INT)
BEGIN
    SELECT SUM(total) INTO total FROM Sell WHERE DATE(dateOfSell) = CURDATE();
END; &&
DELIMITER;

DELIMITER &&
CREATE PROCEDURE Total_Pay_Methods()
BEGIN
    SELECT payMethod, SUM(total) AS totalPayMethod, (SELECT SUM(total) FROM Sell) AS netTotal
    FROM Sell
    GROUP BY payMethod;
END; &&
DELMITER;

DELIMITER &&
CREATE TRIGGER Update_Total_Sell
AFTER INSERT ON SellDetail
FOR EACH ROW
BEGIN
	UPDATE Sell SET total  = total + NEW.partialPrice WHERE id = NEW.sell;
END; &&
DELIMITER;

DELIMITER &&
CREATE TRIGGER Update_Partial_Price BEFORE INSERT ON `SellDetail`
FOR EACH ROW
BEGIN
    DECLARE stock INT;
    SELECT Product.stock INTO stock FROM Product WHERE Product.id = NEW.product;
    IF NEW.quantity > stock THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad es mayor que el stock';
    ELSE
        SET NEW.partialPrice = NEW.quantity * (SELECT price FROM Product WHERE id = NEW.product);
        UPDATE Product SET stock = stock - NEW.quantity WHERE id = NEW.product;
    END IF;
END; &&
DELIMITER ;

DELIMITER && 
CREATE PROCEDURE Emails_Sent(IN search BOOLEAN, OUT emailSent INT)
BEGIN
	SELECT COUNT(*) INTO emailSent FROM Client WHERE publicity = search;
END; && 
DELIMITER;

DELIMITER &&
CREATE PROCEDURE Products_Availability(IN state VARCHAR(20))
BEGIN 
	SELECT * FROM Product WHERE disponibility = state;
END; &&
DELIMITER;

DELIMITER &&
CREATE EVENT Daily_Report
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    SELECT SUM(total) AS DailyTotal FROM Sell WHERE DATE(dateOfSell) = CURDATE();
END; &&
DELIMITER;

DELIMITER &&
CREATE EVENT Monthly_Report
ON SCHEDULE EVERY 1 MONTH
DO
BEGIN
    SELECT SUM(total) AS MonthlyTotal FROM Sell WHERE MONTH(dateOfSell) = MONTH(CURDATE()) AND YEAR(dateOfSell) = YEAR(CURDATE());
END; &&
DELIMITER;

DELIMITER &&
INSERT INTO Client(name, email, address, publicity) VALUES ('Cristhian Tapiero', 'cristapi56@gmail.com', 'Calle Falsa 123',true);
INSERT INTO Client(name, email, address, publicity) VALUES ('David Padilla', 'davidpadi@gmail.com', 'Calle Falsa 456',true);
INSERT INTO Client(name, email, address, publicity) VALUES ('Luis Tapiero', 'cartoli61@gmail.com', 'Calle Falsa 789',false);
INSERT INTO Client(name, email, address, publicity) VALUES ('Martha Padilla', 'mluciapr13@gmail.com', 'Avenida Falsa 123',true);
INSERT INTO Client(name, email, address, publicity) VALUES ('Adrian Tapiero', 'adritapi32@gmail.com', 'Avenida Falsa 456',false);
INSERT INTO Category(name) VALUES ('Food');
INSERT INTO Category(name) VALUES ('Toys');
INSERT INTO Category(name) VALUES ('Tech');
INSERT INTO Category(name) VALUES ('Furniture');
INSERT INTO Category(name) VALUES ('Decoration');
INSERT INTO Product(name, stock, price, category) VALUES ('Patatas', 22, 1, 1);
INSERT INTO Product(name, stock, price, category) VALUES ('Ball', 5, 5, 2);
INSERT INTO Product(name, stock, price, category) VALUES ('Phone', 10, 255, 3);
INSERT INTO Product(name, stock, price, category) VALUES ('Sofa', 2, 1000, 4);
INSERT INTO Product(name, stock, price, category) VALUES ('Picture', 100, 3, 5);
INSERT INTO Sell(client, payMethod, destination) VALUES (1,'Transfer', 'Calle Falsa 123');
INSERT INTO Sell(client, payMethod, destination) VALUES (2, 'Card', 'Calle Falsa 456');
INSERT INTO Sell(client, payMethod, destination) VALUES (3, 'Cash', 'Calle Falsa 123');
INSERT INTO Sell(client, payMethod, destination) VALUES (4, 'Cash', 'Avenida Falsa 123');
INSERT INTO Sell(client, payMethod, destination) VALUES (5, 'Transfer', 'Calle Falsa 456');
INSERT INTO SellDetail(sell, product, quantity) VALUES (1, 1, 10);
INSERT INTO SellDetail(sell, product, quantity) VALUES (2, 2, 3);
INSERT INTO SellDetail(sell, product, quantity) VALUES (3, 3, 1);
INSERT INTO SellDetail(sell, product, quantity) VALUES (4, 4, 1);
INSERT INTO SellDetail(sell, product, quantity) VALUES (5, 5, 4);

/* 
UPDATE Client SET name = 'Angie Tapiero' WHERE id = 5;
UPDATE Client SET address = 'Avenida Siempre Viva 123' WHERE id = 1;
UPDATE Product SET name = 'Chips' WHERE id = 1;
UPDATE Product SET price = 2 WHERE id = 5;
UPDATE Sell SET payMethod = 'Transfer' WHERE id = 2;
UPDATE Sell SET payMethod = 'Cash' WHERE id = 1;
DELETE FROM Client WHERE id = 5;
DELETE FROM Product WHERE id = 5;
DELETE FROM Sell WHERE id = 5;
*/
CREATE USER 'employee'@'localhost' IDENTIFIED BY 'employeePassword123';
GRANT INSERT, DELETE, SELECT, UPDATE ON *.* TO 'employee'@'localhost';

CREATE USER 'developer'@'localhost' IDENTIFIED BY 'developerPassword123';
GRANT CREATE, INSERT, DELETE, UPDATE, SELECT, TRUNCATE ON *.* TO 'developer'@'localhost';

CREATE USER 'admin'@'localhost' IDENTIFIED BY 'adminPassword123';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;

FLUSH PRIVILEGES;
&&

Select * from Product;
