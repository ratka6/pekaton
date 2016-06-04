-- phpMyAdmin SQL Dump
-- version 4.5.1
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Czas generowania: 04 Cze 2016, 21:35
-- Wersja serwera: 10.1.13-MariaDB
-- Wersja PHP: 5.6.20

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Baza danych: `hotel`
--

DELIMITER $$
--
-- Procedury
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `addklient` (IN `name` VARCHAR(30), IN `address` VARCHAR(60))  begin
	set @newcid = (select if((select max(x.nr) from (select cid as nr from customer)x) is null, '0', (select max(x.nr) from (select cid as nr from customer)x) + 1));
	insert into customer values(@newcid, name, address);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addroom` (IN `branch` VARCHAR(30), IN `capacity` INT(2), IN `beds` INT(2), IN `balcony` BINARY(1), IN `typename` TEXT, IN `price` DOUBLE(6,2))  begin
	set @newrid = (select if((select max(x.nr) from (select rid as nr from room)x) is null, '0', (select max(x.nr) from (select rid as nr from room)x) + 1));
	set @newbid := 0;
	insert into room values(@newrid, @newbid, capacity, beds, balcony, typename, price);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cancelreservation` (`resid` INT(6))  begin
	delete from reservation where reservation.resid = resid;
	delete from room_reservation where room_reservation.resid =resid;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deletecustomer` (`cid` INT(6))  begin
	delete from customer where customer.cid = cid;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteroom` (`rid` INT(6))  begin
	delete from room where room.rid = rid;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `fire` (`sid` INT(6))  begin
	delete from staff where staff.sid = sid;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `hire` (IN `branch` INT(6), IN `e_name` VARCHAR(30), IN `e_address` VARCHAR(60), IN `position` TEXT)  begin
set @newsid = (select if((select max(x.nr) from (select sid as nr from staff)x) is null, '0', (select max(x.nr) from (select sid as nr from staff)x) + 1));
set @newbid = (select bid from branch where name = branch);
insert into staff values(@newsid, @newbid, e_name, e_address, position);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `isfree` (`rid` INT(6), `startd` DATE, `endd` DATE)  begin
	select if(
        		(
                    select count(x.y) from 
                    (
                        SELECT r.resID as y FROM room_reservation rr join reservation r on rr.resID = r.resID where rr.rid = rid and 
                        ( 
                            ( 
                                startd >= r.startdate and startd <= r.enddate 
                            ) 
                            or 
                            ( 
                                endd >= r.startdate and endd <= r.enddate 
                            ) 
                            or 
                            ( 
                                startd <= r.startdate and endd >= r.enddate 
                            )
                        )
                    )x 
                    order by x.y
                )
        > 0, 'false', 'true'
    ) as 'if';
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reserve` (IN `cid` INT(6), IN `rid` INT(6), IN `startdate` DATE, IN `enddate` DATE)  begin
	set @newresid = (select if((select max(x.nr) from (select resid as nr from reservation)x) is null, '0', (select max(x.nr) from (select resid as nr from reservation)x) + 1));
	set @duration = (select datediff(enddate, startdate));
	set @bill = (select price from room where room.rid = rid) * @duration;
	insert into reservation values(@newresid, cid, startdate, enddate, @bill);
	insert into room_reservation values (rid, @newresid);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `showbill` (IN `resid` INT(6))  begin
	select bill as bill from reservation r where r.resid = resid;
end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `branch`
--

CREATE TABLE `branch` (
  `bID` int(6) NOT NULL,
  `name` varchar(30) NOT NULL,
  `address` varchar(60) NOT NULL,
  `capacity` int(6) NOT NULL,
  `noofstaff` int(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Zrzut danych tabeli `branch`
--

INSERT INTO `branch` (`bID`, `name`, `address`, `capacity`, `noofstaff`) VALUES
(0, 'Hotel Qtaz', 'Zadupie', 100, 50);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `customer`
--

CREATE TABLE `customer` (
  `cID` int(6) NOT NULL,
  `name` varchar(30) NOT NULL,
  `address` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Zrzut danych tabeli `customer`
--

INSERT INTO `customer` (`cID`, `name`, `address`) VALUES
(0, 'Maciaszek Karol', 'Debowa 890');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `reservation`
--

CREATE TABLE `reservation` (
  `resID` int(6) NOT NULL,
  `cID` int(6) NOT NULL,
  `startDate` date NOT NULL,
  `enddate` date NOT NULL,
  `bill` double(6,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Zrzut danych tabeli `reservation`
--

INSERT INTO `reservation` (`resID`, `cID`, `startDate`, `enddate`, `bill`) VALUES
(0, 0, '2016-06-06', '2016-06-10', 200.00),
(1, 0, '2016-06-08', '2016-07-10', 1600.00),
(2, 0, '2016-07-08', '2016-08-10', 1650.00),
(3, 0, '2016-09-08', '2016-10-10', 1600.00),
(4, 0, '2016-11-08', '2016-12-10', 1600.00);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `room`
--

CREATE TABLE `room` (
  `rID` int(6) NOT NULL,
  `bID` int(6) NOT NULL,
  `capacity` int(2) DEFAULT NULL,
  `beds` int(2) NOT NULL,
  `balcony` tinyint(1) DEFAULT NULL,
  `type` enum('apartment','royal','normal') NOT NULL,
  `price` double(6,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Zrzut danych tabeli `room`
--

INSERT INTO `room` (`rID`, `bID`, `capacity`, `beds`, `balcony`, `type`, `price`) VALUES
(0, 0, 5, 5, 1, 'royal', 50.00);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `room_reservation`
--

CREATE TABLE `room_reservation` (
  `rID` int(6) NOT NULL,
  `resID` int(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Zrzut danych tabeli `room_reservation`
--

INSERT INTO `room_reservation` (`rID`, `resID`) VALUES
(0, 0),
(0, 1),
(0, 2),
(0, 3),
(0, 4);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `staff`
--

CREATE TABLE `staff` (
  `sID` int(6) NOT NULL,
  `bID` int(6) NOT NULL,
  `name` varchar(30) NOT NULL,
  `address` varchar(60) NOT NULL,
  `status` enum('waiter','maid','cook','reception','porter','provider','manager') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Indeksy dla zrzutów tabel
--

--
-- Indexes for table `branch`
--
ALTER TABLE `branch`
  ADD PRIMARY KEY (`bID`);

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`cID`);

--
-- Indexes for table `reservation`
--
ALTER TABLE `reservation`
  ADD PRIMARY KEY (`resID`),
  ADD KEY `cID` (`cID`);

--
-- Indexes for table `room`
--
ALTER TABLE `room`
  ADD PRIMARY KEY (`rID`),
  ADD KEY `bID` (`bID`);

--
-- Indexes for table `room_reservation`
--
ALTER TABLE `room_reservation`
  ADD PRIMARY KEY (`rID`,`resID`),
  ADD KEY `resID` (`resID`);

--
-- Indexes for table `staff`
--
ALTER TABLE `staff`
  ADD PRIMARY KEY (`sID`),
  ADD KEY `bID` (`bID`);

--
-- Ograniczenia dla zrzutów tabel
--

--
-- Ograniczenia dla tabeli `reservation`
--
ALTER TABLE `reservation`
  ADD CONSTRAINT `reservation_ibfk_1` FOREIGN KEY (`cID`) REFERENCES `customer` (`cID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ograniczenia dla tabeli `room`
--
ALTER TABLE `room`
  ADD CONSTRAINT `room_ibfk_1` FOREIGN KEY (`bID`) REFERENCES `branch` (`bID`);

--
-- Ograniczenia dla tabeli `room_reservation`
--
ALTER TABLE `room_reservation`
  ADD CONSTRAINT `room_reservation_ibfk_3` FOREIGN KEY (`rID`) REFERENCES `room` (`rID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `room_reservation_ibfk_4` FOREIGN KEY (`resID`) REFERENCES `reservation` (`resID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ograniczenia dla tabeli `staff`
--
ALTER TABLE `staff`
  ADD CONSTRAINT `staff_ibfk_1` FOREIGN KEY (`bID`) REFERENCES `branch` (`bID`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
