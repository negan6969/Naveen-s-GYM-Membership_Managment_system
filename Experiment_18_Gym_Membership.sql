-- EXPERIMENT 18: GYM MEMBERSHIP MANAGEMENT SYSTEM
-- MySQL 8.0+
CREATE DATABASE IF NOT EXISTS gym_membership_db;
USE gym_membership_db;

DROP VIEW IF EXISTS active_membership_details;
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS trainers;
DROP TABLE IF EXISTS membership_plans;

CREATE TABLE membership_plans (
 plan_id INT PRIMARY KEY AUTO_INCREMENT,
 plan_name VARCHAR(100) NOT NULL,
 duration_months INT NOT NULL,
 fee DECIMAL(10,2) NOT NULL,
 description TEXT
);

CREATE TABLE trainers (
 trainer_id INT PRIMARY KEY AUTO_INCREMENT,
 trainer_name VARCHAR(100) NOT NULL,
 phone VARCHAR(15) UNIQUE,
 specialization VARCHAR(100)
);

CREATE TABLE members (
 member_id INT PRIMARY KEY AUTO_INCREMENT,
 name VARCHAR(100) NOT NULL,
 email VARCHAR(100) UNIQUE NOT NULL,
 phone VARCHAR(15),
 join_date DATE NOT NULL,
 status VARCHAR(20) NOT NULL DEFAULT 'Active',
 trainer_id INT,
 FOREIGN KEY (trainer_id) REFERENCES trainers(trainer_id)
);

CREATE TABLE subscriptions (
 subscription_id INT PRIMARY KEY AUTO_INCREMENT,
 member_id INT NOT NULL,
 plan_id INT NOT NULL,
 start_date DATE NOT NULL,
 end_date DATE NOT NULL,
 payment_status VARCHAR(20) DEFAULT 'Pending',
 FOREIGN KEY (member_id) REFERENCES members(member_id),
 FOREIGN KEY (plan_id) REFERENCES membership_plans(plan_id)
);

-- Insert sample plans
INSERT INTO membership_plans (plan_name,duration_months,fee,description) VALUES
('Monthly',1,1200,'One month gym access'),
('Quarterly',3,3200,'Three months gym access'),
('Half-Yearly',6,5800,'Six months gym access'),
('Yearly',12,10000,'One year gym access');

-- Insert trainers
INSERT INTO trainers (trainer_name,phone,specialization) VALUES
('Arjun Kumar','9876500001','Strength Training'),
('Priya Sharma','9876500002','Yoga and Fitness'),
('Rahul Reddy','9876500003','Weight Loss');

-- Insert members
INSERT INTO members (name,email,phone,join_date,status,trainer_id) VALUES
('Naveen Kumar','naveen@gmail.com','9000000001','2026-01-10','Active',1),
('Anjali Rao','anjali@gmail.com','9000000002','2026-02-05','Active',2),
('Kiran Reddy','kiran@gmail.com','9000000003','2025-11-15','Inactive',3),
('Sneha Patel','sneha@gmail.com','9000000004','2026-03-01','Active',1),
('Vikram Singh','vikram@gmail.com','9000000005','2026-04-12','Active',3);

-- Insert subscriptions
INSERT INTO subscriptions (member_id,plan_id,start_date,end_date,payment_status) VALUES
(1,4,'2026-01-10','2027-01-09','Paid'),
(2,2,'2026-02-05','2026-05-04','Paid'),
(3,1,'2025-11-15','2025-12-14','Pending'),
(4,3,'2026-03-01','2026-08-31','Paid'),
(5,1,'2026-04-12','2026-05-11','Pending');

-- 1. Display all members
SELECT * FROM members;

-- 2. Display all membership plans
SELECT * FROM membership_plans;

-- 3. Display active members
SELECT * FROM members WHERE status='Active';

-- 4. Display member names with assigned trainers
SELECT m.member_id,m.name,t.trainer_name
FROM members m LEFT JOIN trainers t ON m.trainer_id=t.trainer_id;

-- 5. Display subscription details with member and plan names
SELECT s.subscription_id,m.name,p.plan_name,s.start_date,s.end_date,s.payment_status
FROM subscriptions s
JOIN members m ON s.member_id=m.member_id
JOIN membership_plans p ON s.plan_id=p.plan_id;

-- 6. Find subscriptions active on the current date
SELECT m.name,p.plan_name,s.start_date,s.end_date
FROM subscriptions s
JOIN members m ON s.member_id=m.member_id
JOIN membership_plans p ON s.plan_id=p.plan_id
WHERE CURDATE() BETWEEN s.start_date AND s.end_date;

-- 7. Count total members
SELECT COUNT(*) AS total_members FROM members;

-- 8. Calculate revenue from paid subscriptions
SELECT SUM(p.fee) AS total_paid_revenue
FROM subscriptions s JOIN membership_plans p ON s.plan_id=p.plan_id
WHERE s.payment_status='Paid';

-- 9. Count members assigned to each trainer
SELECT t.trainer_name,COUNT(m.member_id) AS total_members
FROM trainers t LEFT JOIN members m ON t.trainer_id=m.trainer_id
GROUP BY t.trainer_id,t.trainer_name;

-- 10. Display plans costing more than Rs. 3000
SELECT * FROM membership_plans WHERE fee>3000;

-- 11. Update a member phone number
UPDATE members SET phone='9111122222' WHERE member_id=1;

-- 12. Update subscription payment status
UPDATE subscriptions SET payment_status='Paid' WHERE subscription_id=5;

-- 13. Insert a sample member
INSERT INTO members(name,email,phone,join_date,status,trainer_id)
VALUES('Test Member','testmember@gmail.com','9000000099',CURDATE(),'Active',2);

-- 14. Delete the sample member
DELETE FROM members WHERE email='testmember@gmail.com';

-- 15. Create a view for active member subscriptions
CREATE VIEW active_membership_details AS
SELECT m.member_id,m.name AS member_name,m.phone,p.plan_name,
       s.start_date,s.end_date,s.payment_status
FROM members m
JOIN subscriptions s ON m.member_id=s.member_id
JOIN membership_plans p ON s.plan_id=p.plan_id
WHERE m.status='Active';

SELECT * FROM active_membership_details;

-- 16. Stored procedure to view subscriptions for a member
DELIMITER //
CREATE PROCEDURE GetMemberSubscriptions(IN input_member_id INT)
BEGIN
 SELECT s.subscription_id,p.plan_name,s.start_date,s.end_date,s.payment_status
 FROM subscriptions s
 JOIN membership_plans p ON s.plan_id=p.plan_id
 WHERE s.member_id=input_member_id;
END //
DELIMITER ;

CALL GetMemberSubscriptions(1);
