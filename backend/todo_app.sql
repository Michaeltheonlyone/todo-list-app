-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 09, 2025 at 09:24 PM
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
-- Database: todo_app
--

-- --------------------------------------------------------

--
-- Table structure for table sessions
--

CREATE TABLE sessions (
  id int(11) NOT NULL,
  task_id int(11) NOT NULL,
  start_time datetime NOT NULL,
  end_time datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table tasks
--

CREATE TABLE tasks (
  id int(11) NOT NULL,
  title varchar(255) NOT NULL,
  completed tinyint(1) DEFAULT 0,
  description text DEFAULT '',
  priority int(11) DEFAULT 1,
  status int(11) DEFAULT 0,
  tags varchar(255) DEFAULT '',
  due_date datetime DEFAULT NULL,
  completed_at datetime DEFAULT NULL,
  created_at timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table tasks
--

INSERT INTO tasks (id, title, completed, description, priority, status, tags, due_date, completed_at, created_at) VALUES
(4, 'Finaliser le rapport', 0, 'Finaliser les rapport', 3, 0, '', '2025-12-09 00:00:00', NULL, '2025-12-09 20:13:27');

--
-- Indexes for dumped tables
--

--
-- Indexes for table sessions
--
ALTER TABLE sessions
  ADD PRIMARY KEY (id),
  ADD KEY task_id (task_id);

--
-- Indexes for table tasks
--
ALTER TABLE tasks
  ADD PRIMARY KEY (id);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table sessions
--
ALTER TABLE sessions
  MODIFY id int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table tasks
--
ALTER TABLE tasks
  MODIFY id int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Constraints for dumped tables
--

--
-- Constraints for table sessions
--
ALTER TABLE sessions
  ADD CONSTRAINT sessions_ibfk_1 FOREIGN KEY (task_id) REFERENCES tasks (id);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
