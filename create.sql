--2.完成以下SQL 命令实现数据库的创建、修改与删除
--1）	创建数据库
--创建数据库XSCJ，初始大小为5MB，最大大小为50MB，数据库自动增长，增长方式按10%比例；日志文件初始大小为2MB，最大可增长至5MB（默认为不限制），按1MB增长（默认为10%增长）；日志文件与数据文件存放于合适的磁盘目录上。
--(a)界面方式创建（报告上无需出现）
--(b)使用命令create database创建
use master  
create database XSCJ  
on primary  
(  
    name = 'XSCJ',  
    filename='D:\Demo\Database\XSCJ.mdf',  
    size= 5mb,  
    maxsize=50mb,  
    filegrowth=10%  
)  
log on  
(  
    name='XSCJ_log',  
    filename='D:\Demo\Database\XSCJ_log.ldf',  
    size=2mb,  
    maxsize=5mb,  
    filegrowth=1mb  
);  
--2)修改数据库XSCJ,将数据文件增长方式改为按5MB增长。
alter database xscj modify file  
(  
    name='XSCJ',  
    filegrowth=5mb  
)  
--2）	为XSCJ库增加文件组FGROUP,
alter database xscj add filegroup fgroup  
--3）	为题3）的文件组FGROUP增加数据文件XSCJ1,XSCJ2，最大为10MB，自动增长，每次增10%。
alter database xscj add file  
(  
    name='XSCJ1',  
    filename='D:\Demo\Database\XSCJ1.mdf',  
    filegrowth=10%,  
    maxsize=10mb  
),  
(  
    name='XSCJ2',  
    filename='D:\Demo\Database\XSCJ2.mdf',  
    filegrowth=10%,  
    maxsize=10mb  
)  
to filegroup fgroup 
--4）	查看XSCJ数据库的属性
select * from sysdatabases where name='xscj'  
--5）	删除文件组FGROUP
alter database xscj remove file XSCJ1  
alter database xscj remove file XSCJ2  
alter database xscj remove filegroup fgroup  
--7)删除数据库XSCJ，再重建之
drop database XSCJ  

--3.表创建、修改与删除
--1）阅读实验教程第3章，了解sql server支持的数据类型，各种数据类型的长度及应用。Nchar与char的区别？ Nchar用unicode编码中文不乱码
--2）在XSCJ库中建立表如下所示：
--Major(mno ,mname)  表示专业号，专业名
create table major  
(  
    mno varchar(8) not null primary key,  
    mname nvarchar(32) not null  
)
--Stu(sno,sname,gender,birdate,mno,memo,photo)分别表示学号，姓名，性别,出生年月有，所在的专业号，简介，相片
create table stu  
(  
    sno varchar(8) not null primary key,  
    sname nvarchar(32) not null,  
    gender nvarchar(8) not null check(gender='男'or gender='女'),  
    birdate date,  
    mno varchar(8) not null foreign key references major(mno),  
    memo nvarchar(64) default null,  
    photo varchar(64) not null  
)  
--Cou(cno,cname,credit,ptime)表示课号，课名，学分，学时
create table cou  
(  
    cno varchar(8) not null primary key,  
    cname nvarchar(16) not null,  
    credit numeric(2,1) default 2,  
    ptime int default 32  
) 
--Sc(sno,cno,grade)
create table sc  
(  
    sno varchar(8) not null,  
    cno varchar(8) not null,  
    grade int default 0,  
    foreign key (sno) references stu(sno),  
    foreign key (cno) references cou(cno)  
)  
--stu_credit(no,sno,totalcredit),分别表示记录号，学号及当前已修学分。其中记录号为int类型，且按步长1自动增长（可查看帮助或百度）
create table stu_credit  
(  
    no int identity(1,1) primary key not null,  
    sno varchar(8) not null foreign key references stu(sno),  
    totalcredit int default 0  
)  
--使用CREATE TABLE命令完成下列任务：
--	a）为四个表应根据集美大学的实际情况设置合理的数据类型，数据长度，并写明各个字段应遵守的完整性。比如gender仅有‘男’与‘女’两种值等。（写明的完整性约束应随着学习的深入用alter table逐步完善）。进一步确定是否可为空，默认值(按关键字NULL，default等查帮助)等。可绘制表说明你的设计
--	b）用命令create table创建上述的四个表。并用primary key关键字指明每个表的主码，有外码用foreign key....references定义外码。
--提示：其它约束与默认值关键字分别为check和default(看帮助中的例子学习)
--	c）修改表stu为其添加一个表示学生E-MAIL号的字段.
alter table stu add email varchar(16)  
--  d）为credit字段添加约束，进一步也可以为E-MAIL字段添加约束，比如格式john@sina.com。(提示：check约束可用正则表达式表示)
alter table cou add constraint credit_check check( credit>=0 and credit<10)  
alter table stu add constraint email_check check( email like '^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$')  
--	e)为stu表添加字段 qq。删除添加的qq字段。
alter table stu add qq char(16)  
alter table stu drop column qq  
--	f）在上述四个表中选择Stu_credit表,用drop tabale删除.再重建立之.
drop table stu_credit  

--4．利用SSMS(SQL SERVER MANAGERMENT STUDIO)相应工具完成表间关联的创建任务。截图表示。
 
--5．为xscj库制作快照
create database xscjPhoto  
on  
(  
    name='XSCJ',  
    filename='D:\Demo\Database\xscj_photo.ss'  
)  
as snapshot of XSCJ;  

