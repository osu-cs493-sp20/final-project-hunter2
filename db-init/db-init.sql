--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`( 
  `userId` MEDIUMINT(4) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `role` ENUM('admin', 'instructor', 'student') NOT NULL,
  PRIMARY KEY (`userId`),
  UNIQUE KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
INSERT INTO `users` (`name`, `email`, `password`, `role`) VALUES
  ('Mike Tyson','tigerface@boxing.com','$2a$10$V2ur5B37Gk1gBHBuvUO6Nu.ZWB9B4jNB8E3EBFCo2G7FqGSroOtaW','admin'),
  ('Rob Hess','robhes@goat.com','$2a$10$V2ur5B37Gk1gBHBuvUO6Nu.ZWB9B4jNB8E3EBFCo2G7FqGSroOtaW','instructor'),
  ('Tiger Woods','twoods@pga.com','$2a$10$V2ur5B37Gk1gBHBuvUO6Nu.ZWB9B4jNB8E3EBFCo2G7FqGSroOtaW','instructor'),
  ('Bill Burr','billburr@comedy.com','$2a$10$V2ur5B37Gk1gBHBuvUO6Nu.ZWB9B4jNB8E3EBFCo2G7FqGSroOtaW','student'),
  ('John Wick','jwick@assasins.com','$2a$10$V2ur5B37Gk1gBHBuvUO6Nu.ZWB9B4jNB8E3EBFCo2G7FqGSroOtaW','student'),
  ('Micheal Jordan','mjordan@air.com','$2a$10$V2ur5B37Gk1gBHBuvUO6Nu.ZWB9B4jNB8E3EBFCo2G7FqGSroOtaW','student'),
  ('Lebron James','ljames@theking.com','$2a$10$V2ur5B37Gk1gBHBuvUO6Nu.ZWB9B4jNB8E3EBFCo2G7FqGSroOtaW','student'),
  ('Allen Iverson','iverson@sosa.com','$2a$10$V2ur5B37Gk1gBHBuvUO6Nu.ZWB9B4jNB8E3EBFCo2G7FqGSroOtaW','student'),
  ('Kyrie Irvine','kirvine@handles.com','$2a$10$V2ur5B37Gk1gBHBuvUO6Nu.ZWB9B4jNB8E3EBFCo2G7FqGSroOtaW','student'),
  ('Mohammed Ali','flow@sting.bee','$2a$10$V2ur5B37Gk1gBHBuvUO6Nu.ZWB9B4jNB8E3EBFCo2G7FqGSroOtaW','student'),
  ('George Hotz','bamf@stealyocar.com','$2a$10$V2ur5B37Gk1gBHBuvUO6Nu.ZWB9B4jNB8E3EBFCo2G7FqGSroOtaW','student'),
  ('Kendrick Lamar','best@freestyle.com','$2a$10$V2ur5B37Gk1gBHBuvUO6Nu.ZWB9B4jNB8E3EBFCo2G7FqGSroOtaW','student'),
  ('Bernardo Sanchez','bsanchez@class.com','$2a$10$V2ur5B37Gk1gBHBuvUO6Nu.ZWB9B4jNB8E3EBFCo2G7FqGSroOtaW','student')
  ;
UNLOCK TABLES;

--
-- Table structure for table `courses`
--

DROP TABLE IF EXISTS `courses`;
CREATE TABLE `courses`(
  `courseId` MEDIUMINT(4) AUTO_INCREMENT,
  `number` VARCHAR(5) NOT NULL,
  `subject` VARCHAR(255) NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `term` VARCHAR(255) NOT NULL,
  `instructorId` MEDIUMINT(4) NOT NULL,
  PRIMARY KEY (`courseId`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `courses`
--

LOCK TABLES `courses` WRITE;
INSERT INTO `courses` (`subject`, `number`, `title`, `term`, `instructorId`) VALUES
  ('CS','493','Cloud Application Development','sp20','2'),
  ('CS','492','Mobile Development','w20','2'),
  ('WR','122','Writing for Buisness','w19','3'),
  ('PS','206','Sociology: The New Jim Crow','f18','3'),
  ('MTH','306','Linear Algebra and Power Series','sp19','3'),
  ('MTH','415','Advanced Linear Algebra','w20','3'),
  ('STAT','314','Statistics for Engineers','f19','3'),
  ('PH','212','Physics: electromagnetism','f18','3'),
  ('CS','493','Cloud Application Development','sp20','2'),
  ('CS','492','Mobile Development','w20','2'),
  ('WR','122','Writing for Buisness','w19','3'),
  ('PS','206','Sociology: The New Jim Crow','f18','3'),
  ('MTH','306','Linear Algebra and Power Series','sp19','3'),
  ('MTH','415','Advanced Linear Algebra','w20','3'),
  ('STAT','314','Statistics for Engineers','f19','3'),
  ('PH','212','Physics: electromagnetism','f18','3'),
  ('CS','492','Mobile Development','w20','2'),
  ('WR','122','Writing for Buisness','w19','3'),
  ('PS','206','Sociology: The New Jim Crow','f18','3'),
  ('MTH','306','Linear Algebra and Power Series','sp19','3'),
  ('MTH','415','Advanced Linear Algebra','w20','3'),
  ('STAT','314','Statistics for Engineers','f19','3'),
  ('PH','212','Physics: electromagnetism','f18','3')
  ;
UNLOCK TABLES;

--
-- Table structure for table `assignments`
--

DROP TABLE IF EXISTS `assignments`;
CREATE TABLE `assignments`(
  `assignmentId` MEDIUMINT(4) AUTO_INCREMENT,
  `courseId` MEDIUMINT(4) NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `points` MEDIUMINT(4) NOT NULL,
  `due` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`assignmentId`),
  FOREIGN KEY (`courseId`) REFERENCES `courses` (`courseId`) 
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `assignments`
--

LOCK TABLES `assignments` WRITE;
INSERT INTO `assignments` (`courseId`, `title`, `points`, `due`) VALUES
  (1,'Assignment 5: Final Project', 100,'2020-06-14T17:00:00-023:59'),
  (2,'Assignment 2: Widgets', 110,'2020-06-14T17:00:00-023:59'),
  (3,'Professional Email', 85,'2020-06-14T17:00:00-023:59'),
  (4,'Chapter 5 Essay', 50,'2020-06-14T17:00:00-023:59'),
  (5,'Matrix Multiplicaion', 45,'2020-06-14T17:00:00-023:59'),
  (6,'Proof: Linear Series', 30,'2020-06-14T17:00:00-023:59'),
  (7,'Graphing in R', 25,'2020-06-14T17:00:00-023:59'),
  (8,'Lab 4', 100,'2020-06-14T17:00:00-023:59'),
  (1,'Assignment 3: Auth User', 200,'2020-06-14T17:00:00-023:59'),
  (2,'Assignment 4: Recycler View', 100,'2020-06-14T17:00:00-023:59'),
  (3,'Final Draft Resume', 95,'2020-06-14T17:00:00-023:59'),
  (4,'Final Essay', 90,'2020-06-14T17:00:00-023:59'),
  (5,'Matrix Transformation', 80,'2020-06-14T17:00:00-023:59'),
  (6,'Matrix Proof', 85,'2020-06-14T17:00:00-023:59'),
  (7,'Marcov Chain', 70,'2020-06-14T17:00:00-023:59'),
  (8,'Lab 6', 75,'2020-06-14T17:00:00-023:59'),
  (5,'Matrix Multiplicaion', 45,'2020-06-14T17:00:00-023:59'),
  (6,'Proof: Linear Series', 30,'2020-06-14T17:00:00-023:59'),
  (7,'Graphing in R', 25,'2020-06-14T17:00:00-023:59'),
  (8,'Lab 4', 100,'2020-06-14T17:00:00-023:59'),
  (1,'Assignment 3: Auth User', 200,'2020-06-14T17:00:00-023:59'),
  (2,'Assignment 4: Recycler View', 100,'2020-06-14T17:00:00-023:59'),
  (3,'Final Draft Resume', 95,'2020-06-14T17:00:00-023:59'),
  (4,'Final Essay', 90,'2020-06-14T17:00:00-023:59'),
  (5,'Matrix Transformation', 80,'2020-06-14T17:00:00-023:59'),
  (6,'Matrix Proof', 85,'2020-06-14T17:00:00-023:59'),
  (7,'Marcov Chain', 70,'2020-06-14T17:00:00-023:59'),
  (8,'Lab 6', 75,'2020-06-14T17:00:00-023:59'),
  (5,'Matrix Multiplicaion', 45,'2020-06-14T17:00:00-023:59'),
  (6,'Proof: Linear Series', 30,'2020-06-14T17:00:00-023:59'),
  (7,'Graphing in R', 25,'2020-06-14T17:00:00-023:59'),
  (8,'Lab 4', 100,'2020-06-14T17:00:00-023:59'),
  (1,'Assignment 3: Auth User', 200,'2020-06-14T17:00:00-023:59'),
  (2,'Assignment 4: Recycler View', 100,'2020-06-14T17:00:00-023:59'),
  (3,'Final Draft Resume', 95,'2020-06-14T17:00:00-023:59'),
  (4,'Final Essay', 90,'2020-06-14T17:00:00-023:59'),
  (5,'Matrix Transformation', 80,'2020-06-14T17:00:00-023:59'),
  (6,'Matrix Proof', 85,'2020-06-14T17:00:00-023:59'),
  (7,'Marcov Chain', 70,'2020-06-14T17:00:00-023:59'),
  (8,'Lab 6', 75,'2020-06-14T17:00:00-023:59'),
  (5,'Matrix Multiplicaion', 45,'2020-06-14T17:00:00-023:59'),
  (6,'Proof: Linear Series', 30,'2020-06-14T17:00:00-023:59'),
  (7,'Graphing in R', 25,'2020-06-14T17:00:00-023:59'),
  (8,'Lab 4', 100,'2020-06-14T17:00:00-023:59'),
  (1,'Assignment 3: Auth User', 200,'2020-06-14T17:00:00-023:59'),
  (2,'Assignment 4: Recycler View', 100,'2020-06-14T17:00:00-023:59'),
  (3,'Final Draft Resume', 95,'2020-06-14T17:00:00-023:59'),
  (4,'Final Essay', 90,'2020-06-14T17:00:00-023:59'),
  (5,'Matrix Transformation', 80,'2020-06-14T17:00:00-023:59'),
  (6,'Matrix Proof', 85,'2020-06-14T17:00:00-023:59'),
  (7,'Marcov Chain', 70,'2020-06-14T17:00:00-023:59'),
  (8,'Lab 6', 75,'2020-06-14T17:00:00-023:59'),
  (5,'Matrix Multiplicaion', 45,'2020-06-14T17:00:00-023:59'),
  (6,'Proof: Linear Series', 30,'2020-06-14T17:00:00-023:59'),
  (7,'Graphing in R', 25,'2020-06-14T17:00:00-023:59'),
  (8,'Lab 4', 100,'2020-06-14T17:00:00-023:59'),
  (1,'Assignment 3: Auth User', 200,'2020-06-14T17:00:00-023:59'),
  (2,'Assignment 4: Recycler View', 100,'2020-06-14T17:00:00-023:59'),
  (3,'Final Draft Resume', 95,'2020-06-14T17:00:00-023:59'),
  (4,'Final Essay', 90,'2020-06-14T17:00:00-023:59'),
  (5,'Matrix Transformation', 80,'2020-06-14T17:00:00-023:59'),
  (6,'Matrix Proof', 85,'2020-06-14T17:00:00-023:59'),
  (7,'Marcov Chain', 70,'2020-06-14T17:00:00-023:59'),
  (8,'Lab 6', 75,'2020-06-14T17:00:00-023:59'),
  (5,'Matrix Multiplicaion', 45,'2020-06-14T17:00:00-023:59'),
  (6,'Proof: Linear Series', 30,'2020-06-14T17:00:00-023:59'),
  (7,'Graphing in R', 25,'2020-06-14T17:00:00-023:59'),
  (8,'Lab 4', 100,'2020-06-14T17:00:00-023:59'),
  (1,'Assignment 3: Auth User', 200,'2020-06-14T17:00:00-023:59'),
  (2,'Assignment 4: Recycler View', 100,'2020-06-14T17:00:00-023:59'),
  (3,'Final Draft Resume', 95,'2020-06-14T17:00:00-023:59'),
  (4,'Final Essay', 90,'2020-06-14T17:00:00-023:59'),
  (5,'Matrix Transformation', 80,'2020-06-14T17:00:00-023:59'),
  (6,'Matrix Proof', 85,'2020-06-14T17:00:00-023:59'),
  (7,'Marcov Chain', 70,'2020-06-14T17:00:00-023:59'),
  (8,'Lab 6', 75,'2020-06-14T17:00:00-023:59')
  ;
UNLOCK TABLES;

--
-- Table structure for table `submissions`
--

DROP TABLE IF EXISTS `submissions`;
CREATE TABLE `submissions`(
  `submissionId` MEDIUMINT(4) AUTO_INCREMENT,
  `studentId` MEDIUMINT(4) NOT NULL,
  `assignmentId` MEDIUMINT(4) NOT NULL,
  `timestamp` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `file` blob NOT NULL,
  PRIMARY KEY (`submissionId`),
  FOREIGN KEY (`assignmentId`) REFERENCES `assignments` (`assignmentId`)
    ON DELETE CASCADE,
  FOREIGN KEY (`studentId`) REFERENCES `users` (`userId`)
    ON DELETE CASCADE
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

--
-- Dumping data for table `instructors` that teach courseId
--
LOCK TABLES `submissions` WRITE;
INSERT INTO `submissions` (`studentId`, `assignmentId`, `file`) VALUES
  (4,2,'/files/submit/assignment1.pdf'),
  (4,3,'/files/submit/assignment2.pdf'),
  (5,3,'/files/submit/assignment3.pdf'),
  (5,4,'/files/submit/assignment4.pdf'),
  (6,4,'/files/submit/assignment5.pdf'),
  (7,5,'/files/submit/assignment6.pdf'),
  (8,6,'/files/submit/assignment7.pdf'),
  (9,7,'/files/submit/assignment8.pdf'),
  (4,2,'/files/submit/assignment1.pdf'),
  (4,3,'/files/submit/assignment2.pdf'),
  (5,3,'/files/submit/assignment3.pdf'),
  (5,4,'/files/submit/assignment4.pdf'),
  (6,4,'/files/submit/assignment5.pdf'),
  (7,5,'/files/submit/assignment6.pdf'),
  (8,6,'/files/submit/assignment7.pdf'),
  (9,7,'/files/submit/assignment8.pdf'),
  (4,2,'/files/submit/assignment1.pdf'),
  (4,3,'/files/submit/assignment2.pdf'),
  (5,3,'/files/submit/assignment3.pdf'),
  (5,4,'/files/submit/assignment4.pdf'),
  (6,4,'/files/submit/assignment5.pdf'),
  (7,5,'/files/submit/assignment6.pdf'),
  (8,6,'/files/submit/assignment7.pdf'),
  (9,7,'/files/submit/assignment8.pdf'),
  (4,2,'/files/submit/assignment1.pdf'),
  (4,3,'/files/submit/assignment2.pdf'),
  (5,3,'/files/submit/assignment3.pdf'),
  (5,4,'/files/submit/assignment4.pdf'),
  (6,4,'/files/submit/assignment5.pdf'),
  (7,5,'/files/submit/assignment6.pdf'),
  (8,6,'/files/submit/assignment7.pdf'),
  (9,7,'/files/submit/assignment8.pdf')
  ;
UNLOCK TABLES;


--
-- Table structure for table `errors`
--

DROP TABLE IF EXISTS `errors`;
CREATE TABLE `errors`(
  `errorId` MEDIUMINT(4) PRIMARY KEY AUTO_INCREMENT,
  `errorResponse` VARCHAR(255) NOT NULL,
  `errorCode` VARCHAR(255) NOT NULL,
  `timestamp` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `instructors` that teach courseId
--

DROP TABLE IF EXISTS `instructors`;
CREATE TABLE `instructors`(
  `courseId` MEDIUMINT(4) NOT NULL,
  `instructorId` MEDIUMINT(4) NOT NULL,
  FOREIGN KEY (`courseId`) REFERENCES `courses` (`courseId`)
    ON DELETE CASCADE,
  FOREIGN KEY (`instructorId`) REFERENCES `users` (`userId`)
    ON DELETE CASCADE 
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `instructors` that teach courseId
--

LOCK TABLES `instructors` WRITE;
INSERT INTO `instructors` VALUES
  (1,2),
  (2,2),
  (3,3),
  (4,3),
  (5,3),
  (6,3),
  (7,3),
  (8,3),
  (8,2),
  (10,3),
  (11,3),
  (12,3),
  (13,3),
  (14,3),
  (15,3)
  ;
UNLOCK TABLES;

--
-- Table structure for table `enrolledStudents` enrolled in courseId
--

DROP TABLE IF EXISTS `enrolledStudents`;
CREATE TABLE `enrolledStudents`(
  `courseId` MEDIUMINT(4) NOT NULL,
  `studentId` MEDIUMINT(4) NOT NULL,
  FOREIGN KEY (`courseId`) REFERENCES `courses` (`courseId`)
    ON DELETE CASCADE,
  FOREIGN KEY (`studentId`) REFERENCES `users` (`userId`)
    ON DELETE CASCADE 
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `enrolledStudents` enroll in a course
--

LOCK TABLES `enrolledStudents` WRITE;
INSERT INTO `enrolledStudents` VALUES
  (1,13),
  (1,4),
  (2,5),
  (3,5),
  (4,5),
  (5,6),
  (6,7),
  (7,7),
  (1,8),
  (1,9),
  (2,10),
  (3,10),
  (4,11),
  (5,12),
  (6,12),
  (7,13),
  (7,12),
  (1,11),
  (1,10),
  (2,9),
  (3,9),
  (4,8),
  (5,8),
  (6,5),
  (7,4),
  (1,4),
  (1,4),
  (2,5),
  (3,6),
  (4,8),
  (5,6),
  (6,7)
  ;
UNLOCK TABLES;

--
-- Table structure for table `admin`
--

DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin`(
  `adminId` MEDIUMINT(4) NOT NULL,
  FOREIGN KEY (`adminId`) REFERENCES `users` (`userId`)
    ON DELETE CASCADE 
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `admin` 
--

LOCK TABLES `admin` WRITE;
INSERT INTO `admin` VALUES
  (1)
  ;
UNLOCK TABLES;