


create database unikleads;
use unikleads;

-- USERS
CREATE TABLE `users` (
  `user_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(150) NOT NULL,
  `role` ENUM('DSA','NBFC','Co-op') NOT NULL,
  `status` ENUM('active','blocked') DEFAULT 'active',
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- WALLETS
CREATE TABLE `wallets` (
  `wallet_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `balance` DECIMAL(12,2) DEFAULT '0.00',
  `valid_until` DATE DEFAULT NULL,
  `status` ENUM('active','expired') DEFAULT 'active',
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`wallet_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `wallets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- APPLICATIONS
CREATE TABLE `applications` (
  `app_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `status` ENUM('pending','approved','rejected') DEFAULT 'pending',
  `submitted_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`app_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `applications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- TRANSACTIONS
CREATE TABLE `transactions` (
  `txn_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `amount` DECIMAL(12,2) NOT NULL,
  `type` ENUM('credit','debit') NOT NULL,
  `payment_mode` ENUM('razorpay') DEFAULT 'razorpay',
  `txn_ref` VARCHAR(100) DEFAULT NULL,
  `date` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`txn_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- NOTIFICATIONS
CREATE TABLE `notifications` (
  `notif_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `channel` ENUM('sms','whatsapp','email') NOT NULL,
  `message_type` ENUM('expiry_alert','low_balance','payment_success') NOT NULL,
  `status` ENUM('sent','failed') DEFAULT 'sent',
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notif_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

show tables;
