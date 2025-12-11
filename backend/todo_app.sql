-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 11, 2025 at 03:33 AM
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
-- Database: `todo_app`
--

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL,
  `task_id` int(11) NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime DEFAULT NULL,
  `duration_minutes` int(11) DEFAULT 25,
  `type` int(11) DEFAULT 0,
  `status` int(11) DEFAULT 0,
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `task_id`, `start_time`, `end_time`, `duration_minutes`, `type`, `status`, `notes`) VALUES
(3, 7, '2025-12-11 03:04:44', '2025-12-11 03:05:44', 1, 0, 2, ''),
(4, 7, '2025-12-11 03:15:18', '2025-12-11 03:16:18', 1, 0, 2, ''),
(5, 8, '2025-12-11 03:17:58', '2025-12-11 03:18:58', 1, 0, 2, ''),
(6, 8, '2025-12-11 03:19:06', '2025-12-11 03:19:13', 1, 0, 2, ''),
(7, 8, '2025-12-11 03:27:35', '2025-12-11 03:28:35', 1, 0, 2, ''),
(8, 9, '2025-12-11 03:30:51', '2025-12-11 03:31:52', 1, 0, 2, '');

-- --------------------------------------------------------

--
-- Table structure for table `tasks`
--

CREATE TABLE `tasks` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `completed` tinyint(1) DEFAULT 0,
  `description` text DEFAULT '',
  `priority` int(11) DEFAULT 1,
  `status` int(11) DEFAULT 0,
  `tags` varchar(255) DEFAULT '',
  `due_date` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tasks`
--

INSERT INTO `tasks` (`id`, `title`, `completed`, `description`, `priority`, `status`, `tags`, `due_date`, `completed_at`, `created_at`) VALUES
(7, 'Tache', 0, 'tache', 3, 2, '', '2025-12-15 00:00:00', '2025-12-11 03:16:27', '2025-12-10 07:06:01'),
(8, 'Finaliser le rapport', 0, 'Finaliser le rapport', 3, 2, '', '2025-12-31 00:00:00', '2025-12-11 03:28:40', '2025-12-11 02:17:34'),
(9, 'Ajouter les sessions', 0, 'Ajouter les sessions', 0, 2, '', '2025-12-16 00:00:00', '2025-12-11 03:31:54', '2025-12-11 02:30:35');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `task_id` (`task_id`);

--
-- Indexes for table `tasks`
--
ALTER TABLE `tasks`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `sessions`
--
ALTER TABLE `sessions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `tasks`
--
ALTER TABLE `tasks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `sessions`
--
ALTER TABLE `sessions`
  ADD CONSTRAINT `sessions_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
