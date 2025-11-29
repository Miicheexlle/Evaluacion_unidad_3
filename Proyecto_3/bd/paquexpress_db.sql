-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3307
-- Generation Time: Nov 29, 2025 at 08:54 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `paquexpress_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `p3_packages`
--

CREATE TABLE `p3_packages` (
  `package_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `client_name` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `delivered` tinyint(1) DEFAULT 0,
  `delivery_photo` varchar(255) DEFAULT NULL,
  `delivery_lat` decimal(10,8) DEFAULT NULL,
  `delivery_lng` decimal(11,8) DEFAULT NULL,
  `delivery_address` varchar(255) DEFAULT NULL,
  `delivered_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `p3_packages`
--

INSERT INTO `p3_packages` (`package_id`, `user_id`, `client_name`, `address`, `latitude`, `longitude`, `delivered`, `delivery_photo`, `delivery_lat`, `delivery_lng`, `delivery_address`, `delivered_at`) VALUES
(1, 1, 'Juan Pérez', 'Av. Paseo de la Reforma 1, Ciudad de México', 19.42600000, -99.16700000, 1, 'uploads\\deliver_1_1764452620_pedrito sola.webp', 20.64384000, -100.47324160, 'Calle 2, La Loma, Delegación Félix Osores, Santiago de Querétaro, Municipio de Querétaro, Querétaro, 76116, México', '2025-11-29 21:43:42'),
(2, 1, 'María López', 'Calle Falsa 123, Col. Centro, Ciudad de México', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(3, 2, 'Cafetería La Vieja Estación', 'Calle Corregidora 72, Centro, Querétaro', 20.58832400, -100.38987000, 1, 'uploads\\deliver_3_1764467288_paquete_entregado.webp', 20.64384000, -100.47324160, 'Calle 2, La Loma, Delegación Félix Osores, Santiago de Querétaro, Municipio de Querétaro, Querétaro, 76116, México', '2025-11-30 01:48:10'),
(4, 2, 'Estética Glamour', 'Av. Zaragoza 123, Centro, Querétaro', 20.58798000, -100.38274000, 1, 'uploads\\deliver_4_1764467497_paquete_entregado.webp', 20.64103560, -100.46739190, 'Calle Monte Parnaso, La Loma, Delegación Félix Osores, Santiago de Querétaro, Municipio de Querétaro, Querétaro, 76116, México', '2025-11-30 01:51:39'),
(5, 2, 'QroTech Oficinas', 'Blvd. Bernardo Quintana 4100, Querétaro', 20.64433000, -100.40197000, 0, NULL, NULL, NULL, NULL, NULL),
(6, 3, 'Residencial Jurica', 'P.º Jurica 150, Jurica, Querétaro', 20.66403000, -100.43540000, 1, 'uploads\\deliver_6_1764467345_paquete_entregado.webp', 20.64384000, -100.47324160, 'Calle 2, La Loma, Delegación Félix Osores, Santiago de Querétaro, Municipio de Querétaro, Querétaro, 76116, México', '2025-11-30 01:49:06'),
(7, 3, 'Plaza Antea', 'Av. Antea 102, Juriquilla, Querétaro', 20.68289000, -100.44777000, 0, NULL, NULL, NULL, NULL, NULL),
(8, 3, 'Hospital San José', 'Av. 5 de Febrero 1400, Querétaro', 20.61124000, -100.39590000, 0, NULL, NULL, NULL, NULL, NULL),
(9, 4, 'Consultorio Reforma', 'Paseo de la Reforma 250, CDMX', 19.42882000, -99.16715000, 0, NULL, NULL, NULL, NULL, NULL),
(10, 4, 'Restaurante Polanco', 'Av. Presidente Masaryk 300, CDMX', 19.43053000, -99.19532000, 0, NULL, NULL, NULL, NULL, NULL),
(11, 4, 'Oficinas Diana', 'Glorieta de la Diana Cazadora, CDMX', 19.42460000, -99.17552000, 0, NULL, NULL, NULL, NULL, NULL),
(12, 5, 'Centro Magno', 'Av. Vallarta 2425, Guadalajara', 20.67459000, -103.39107000, 0, NULL, NULL, NULL, NULL, NULL),
(13, 5, 'Hospital Ángeles del Carmen', 'Av. López Mateos 500, Guadalajara', 20.66653000, -103.39249000, 0, NULL, NULL, NULL, NULL, NULL),
(14, 5, 'Restaurante Providencia', 'Av. Providencia 2500, Guadalajara', 20.70486000, -103.39011000, 0, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `p3_users`
--

CREATE TABLE `p3_users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(50) DEFAULT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `full_name` varchar(100) DEFAULT NULL,
  `role` varchar(20) DEFAULT 'agent',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `p3_users`
--

INSERT INTO `p3_users` (`user_id`, `username`, `password_hash`, `full_name`, `role`, `created_at`) VALUES
(1, 'agent1', '5f4dcc3b5aa765d61d8327deb882cf99', 'Agente Prueba', 'agent', '2025-11-29 15:19:32'),
(2, 'agent2', '5f4dcc3b5aa765d61d8327deb882cf99', 'Michelle Escamilla', 'agent', '2025-11-29 16:11:41'),
(3, 'agent3', '5f4dcc3b5aa765d61d8327deb882cf99', 'Owen Galvan', 'agent', '2025-11-29 16:11:41'),
(4, 'agent4', '5f4dcc3b5aa765d61d8327deb882cf99', 'María Hernández', 'agent', '2025-11-29 16:11:41'),
(5, 'agent5', '5f4dcc3b5aa765d61d8327deb882cf99', 'Luis González', 'agent', '2025-11-29 16:11:41'),
(6, 'agent6', '5f4dcc3b5aa765d61d8327deb882cf99', 'Fernanda López', 'agent', '2025-11-29 16:11:41');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `p3_packages`
--
ALTER TABLE `p3_packages`
  ADD PRIMARY KEY (`package_id`);

--
-- Indexes for table `p3_users`
--
ALTER TABLE `p3_users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `p3_packages`
--
ALTER TABLE `p3_packages`
  MODIFY `package_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `p3_users`
--
ALTER TABLE `p3_users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
