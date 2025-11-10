-- MySQL dump 10.13  Distrib 8.0.42, for Win64 (x86_64)
--
-- Host: localhost    Database: restaurantdb
-- ------------------------------------------------------
-- Server version	9.3.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `menu_items`
--

DROP TABLE IF EXISTS `menu_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menu_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu_items`
--

LOCK TABLES `menu_items` WRITE;
/*!40000 ALTER TABLE `menu_items` DISABLE KEYS */;
INSERT INTO `menu_items` VALUES (1,'Margherita Pizza',120.00,'https://via.placeholder.com/200x150'),(2,'Chicken Burger',90.00,'https://via.placeholder.com/200x150'),(3,'Pasta Alfredo',150.00,'https://via.placeholder.com/200x150'),(4,'Margherita Pizza',120.00,'https://via.placeholder.com/200x150'),(5,'Chicken Burger',90.00,'https://via.placeholder.com/200x150'),(6,'Pasta Alfredo',150.00,'https://via.placeholder.com/200x150'),(8,'coconut',70.00,'https://restaurantsolutions.shop/dynamic-images/burger.jpg');
/*!40000 ALTER TABLE `menu_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `customer_name` varchar(100) NOT NULL,
  `customer_phone` varchar(20) DEFAULT NULL,
  `total_price` decimal(10,2) DEFAULT NULL,
  `items` json NOT NULL,
  `order_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,'mohamed','01004476240',210.00,'[{\"id\": 1, \"name\": \"Margherita Pizza\", \"image\": \"https://via.placeholder.com/200x150\", \"price\": \"120.00\"}, {\"id\": 2, \"name\": \"Chicken Burger\", \"image\": \"https://via.placeholder.com/200x150\", \"price\": \"90.00\"}]','2025-10-11 05:49:49'),(2,'maro','01004476241',150.00,'[{\"id\": 6, \"name\": \"Pasta Alfredo\", \"image\": \"https://via.placeholder.com/200x150\", \"price\": \"150.00\"}]','2025-10-11 06:13:53'),(3,'mohamed adnan','01000000000',120.00,'[{\"id\": 1, \"name\": \"Margherita Pizza\", \"image\": \"https://via.placeholder.com/200x150\", \"price\": \"120.00\"}]','2025-10-11 07:38:21'),(4,'mohamed adnan','01000000000',150.00,'[{\"id\": 6, \"name\": \"Pasta Alfredo\", \"image\": \"https://via.placeholder.com/200x150\", \"price\": \"150.00\"}]','2025-10-11 07:51:31'),(5,'mohamed adnan','01004476233',150.00,'[{\"id\": 6, \"name\": \"Pasta Alfredo\", \"image\": \"https://via.placeholder.com/200x150\", \"price\": \"150.00\"}]','2025-10-11 09:06:20'),(6,'mohamed adnan','01004476222',90.00,'[{\"id\": 2, \"name\": \"Chicken Burger\", \"image\": \"https://via.placeholder.com/200x150\", \"price\": \"90.00\"}]','2025-10-11 09:10:40'),(7,'mohamed adnan','01004476299',150.00,'[{\"id\": 6, \"name\": \"Pasta Alfredo\", \"image\": \"https://via.placeholder.com/200x150\", \"price\": \"150.00\"}]','2025-10-11 09:18:02'),(8,'mohamed adnan','01004476240',90.00,'[{\"id\": 2, \"name\": \"Chicken Burger\", \"image\": \"https://via.placeholder.com/200x150\", \"price\": \"90.00\"}]','2025-10-11 09:25:30'),(9,'mohamed adnan','01004475250',150.00,'[{\"id\": 6, \"name\": \"Pasta Alfredo\", \"image\": \"https://via.placeholder.com/200x150\", \"price\": \"150.00\"}]','2025-10-11 09:29:00'),(10,'mohamed adnan','01224476240',120.00,'[{\"id\": 4, \"name\": \"Margherita Pizza\", \"image\": \"https://via.placeholder.com/200x150\", \"price\": \"120.00\"}]','2025-10-11 10:18:04'),(11,'mohamed adnan','01334476240',150.00,'[{\"id\": 6, \"name\": \"Pasta Alfredo\", \"image\": \"https://via.placeholder.com/200x150\", \"price\": \"150.00\"}]','2025-10-11 10:21:27'),(12,'mohamed adnan','01555560305',90.00,'[{\"id\": 5, \"name\": \"Chicken Burger\", \"image\": \"https://via.placeholder.com/200x150\", \"price\": \"90.00\"}]','2025-10-11 10:27:46');
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'captivenano31@gmail.com','1234','mohamed adnan');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'restaurantdb'
--

--
-- Dumping routines for database 'restaurantdb'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-10-16  9:07:38
