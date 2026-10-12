CREATE DATABASE GymMembershipDB;
GO

USE GymMembershipDB;
GO
use GymMembershipDB;
go

create table Members (
    MemberID int primary key,
    Name varchar(100) not null,
    Email varchar(100),
    Phone varchar(20),
    Gender varchar(20),
    JoinDate date not null,
    MembershipType varchar(20),
    MembershipStartDate date not null,
    MembershipEndDate date not null
);

create table Trainers (
    TrainerID int primary key,
    Name varchar(100) not null,
    Specialization varchar(100),
    Phone varchar(20),
    HireDate date not null
);

create table Classes (
    ClassID int primary key,
    ClassName varchar(100) not null,
    TrainerID int not null,
    Schedule varchar(20),
    Capacity int not null,

    constraint fk_classes_trainer
        foreign key (TrainerID)
        references Trainers(TrainerID),

    constraint chk_class_capacity
        check (Capacity > 0)
);

create table ClassBookings (
    BookingID int primary key,
    MemberID int not null,
    ClassID int not null,
    BookingDate date not null,
    BookingStatus varchar(20) not null,

    constraint fk_booking_member
        foreign key (MemberID)
        references Members(MemberID),

    constraint fk_booking_class
        foreign key (ClassID)
        references Classes(ClassID)
);

create table Attendance (
    AttendanceID int primary key,
    MemberID int not null,
    ClassID int not null,
    AttendanceDate date not null,
    Status varchar(20) not null,

    constraint fk_attendance_member
        foreign key (MemberID)
        references Members(MemberID),

    constraint fk_attendance_class
        foreign key (ClassID)
        references Classes(ClassID)
);

create table Payments (
    PaymentID int primary key,
    MemberID int not null,
    PaymentDate date not null,
    Amount decimal(10,2),
    PaymentMethod varchar(30),
    PaymentStatus varchar(20) not null,

    constraint fk_payment_member
        foreign key (MemberID)
        references Members(MemberID),

    constraint chk_payment_amount
        check (Amount >= 0)
);
go

select * from Members;
select * from Trainers;
select * from Classes;
select * from ClassBookings;
select * from Attendance;
select * from Payments;

alter table Members
add Age int;
select *
from Members;

update Members
set Age = floor(rand(checksum(newid())) * 43) + 18;
-------------------------------------------------------------------------------------
--total members--
select count(MemberID) as Total_Members from Members;
 

--total revenue by month--
select month(PaymentDate) as Month,year(PaymentDate) as Year,sum(Amount) as Total_Rev from Payments
where PaymentStatus = 'Paid'
group by month(PaymentDate),year(PaymentDate)
order by year(PaymentDate),month(PaymentDate);


--top 10 customers by total_paid--
 select
    top(10) m.Name,m.MemberID,m.Email,m.Phone,sum(p.Amount) as TotalPaid,
    rank() over(order by sum(p.Amount) desc) as RevenueRank
from Members m
join Payments p on m.MemberID = p.MemberID
where p.PaymentStatus = 'Paid'
group by m.Name,m.MemberID,m.Email,m.Phone;

-- count&rev by Membership type--
select
    m.MembershipType,
    sum(p.Amount) as TotalRevenue,count(*) as total_count
from Members m
join Payments p
    on m.MemberID = p.MemberID
where p.PaymentStatus = 'Paid'
group by m.MembershipType
order by TotalRevenue desc;


-- top 3 classes by booking --
select top (3)
    c.ClassName,
    count(cb.BookingID) as Total_Bookings
from Classes c
join ClassBookings cb
    on c.ClassID = cb.ClassID
where cb.BookingStatus in ('Booked', 'Completed')
group by c.ClassName
order by Total_Bookings  desc;

--  year by rev --
select 
    year(PaymentDate) as Year,
    sum(Amount) as TotalRevenue
from Payments
where PaymentStatus = 'Paid'
group by year(PaymentDate)
order by TotalRevenue desc;


-- Count By age_group
select 
CASE
    WHEN Age BETWEEN 18 AND 24 THEN '18-24'
    WHEN Age BETWEEN 25 AND 34 THEN '25-34'
    WHEN Age BETWEEN 35 AND 44 THEN '35-44'
    WHEN Age BETWEEN 45 AND 60 THEN '45-60'
    
 
END AS AgeGroup,
 count(*) as Total_members from Members
group by CASE
    WHEN Age BETWEEN 18 AND 24 THEN '18-24'
    WHEN Age BETWEEN 25 AND 34 THEN '25-34'
    WHEN Age BETWEEN 35 AND 44 THEN '35-44'
    WHEN Age BETWEEN 45 AND 60 THEN '45-60'
 
END
order by Total_members desc ;

-- expiring soon membership--
SELECT MemberID,Name,Phone,MembershipEndDate
FROM Members
WHERE MembershipEndDate BETWEEN GETDATE()
    AND DATEADD(DAY, 7, GETDATE());



-- top(3) trainers by longest serving e--
select top(3) TrainerID, Name, Specialization, DATEDIFF(DAY,HireDate,GETDATE()) as DaysWorked 
from Trainers  

group by
 TrainerID, Name, Specialization, DATEDIFF(DAY,HireDate,GETDATE())
order by DaysWorked desc;

-- count of membership by Gender--
select Gender ,count(*) as total_members from Members 
group by Gender;


--count of trainers by specialization--
select Specialization ,count(*) as total_trainers from Trainers 
group by Specialization;
 
--members by join_year--
SELECT YEAR(JoinDate) AS JoinYear,
       COUNT(*) AS NewMembers
FROM Members
GROUP BY YEAR(JoinDate)
ORDER BY JoinYear; 

-- count of active members--
SELECT COUNT(*) AS ActiveMembers
FROM Members
WHERE MembershipEndDate >= GETDATE();








