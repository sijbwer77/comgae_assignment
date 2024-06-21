CREATE DATABASE submissions_db;
USE submissions_db;

CREATE TABLE `submissions` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `username` VARCHAR(255),
    `password` VARCHAR(255),
    `code` TEXT,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    `status` VARCHAR(50),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
