--1．	查询全学院所有学生的信息
select *from stu;
--2．	查询所有学生的学号与姓名以及性别。要求：性别用“男”或“女”来显示
select sno,sname,(case when sex = 1 then '男' when sex=0 then '女' end) as sex from stu;
--3．	查询女生的学号与姓名
select sno,sname from stu
where sex=0;
--4．	查询女生且年龄19以上学生信息
 select * from stu
where sex=0 and year(getdate())-year(birdate)>19;
--5．	查询年龄18-20的学生信息
select * from stu
where sex=0 and year(getdate())-year(birdate) between 18 and 20; --（18,20]
select * from stu
where sex=0 and year(getdate())-year(birdate)>=18 and year(getdate())-year(birdate)<=20;
--6．	查询所有姓陈的学生信息
select *from stu
where sname like '陈%';
--7．	查询计算机、软件专业的学生信息
select * from stu,major
where stu.mno=major.mno and mname in ('计算机工程','软件工程');
-- 查询所有学生的平均成绩，如果某学生尚未选修课程或成绩为空时，平均分计为0。
select stu.sno as 学号,avg(case when sc.grade is null then 0 else sc.grade end)as 平均成绩
from stu left join sc on stu.sno=sc.sno
group by stu.sno;
--8．	查询全学院的学生成绩平均分（注：有的学生可能没有选修课程,平均分为0）
select avg(grade) as '学院平均分' from sc;
--9．	查询各专业的学生成绩平均分（注：有的学生可能没有选修课程）
select mname,avg(grade)
from major left outer join stu on major.mno=stu.mno left join sc on stu.sno=sc.sno
group by stu.mno,mname;
--10．查询平均分多于75分的学生学号
select sno
from sc
group by sno
having avg(grade)>75;
--11.查询‘C001’课程未登记成绩的学生学号
select sno 
from sc
where cno='C001' and grade is null;
--12．查询选修‘C语言’课程的学生的学号
--1）采用连接查询
select sname as 姓名,grade as 成绩
from stu join sc on stu.sno=sc.sno join cou on sc.cno=cou.cno
where cou.cname='C语言' 
order by grade desc;
--2）采用嵌套查询
select sname as 姓名,grade as 成绩
from stu join sc on stu.sno=sc.sno 
where cno=(select cno from cou where cname='C语言')
order by grade desc;
--3）采用EXIST查询
select sname as 姓名,grade as 成绩
from stu join sc as y on stu.sno=y.sno
where exists(select * from sc as x,cou where x.cno=cou.cno and x.sno=y.sno and x.cno=y.cno and cname='C语言')
order by grade desc;
--13．查询未选修‘C语言’课程的学生的学号（not exist实现）
select stu.sno as 学号,stu.sname as 姓名
from stu
where not exists(select * from cou,sc where stu.sno=sc.sno and sc.cno=cou.cno and cname = 'C语言')
--15．查询与‘张三’在同一个专业的学生信息
select stu.sno as 学号,stu.sname as 姓名 from stu
where mno=(select mno from stu where sname='张三') and sname!='张三';
--16. 检索出学生‘张三’选修的所有课程及成绩，最后计算他所获得的总学分。输出成绩结果集按课程号升序排序。 
--注意：选课成绩在60分以上才能获得相应的学分。cou表中credit列为某课程的学分值 。
select * from (
select top 100 cou.cno as 课程号,cname as 课程,grade as 成绩
from sc,cou
where sc.cno=cou.cno and sno=(select sno from stu where sname='张三')
order by cou.cno
)a
union all
select '张三' as 课程号,'总学分' as 课程,sum(case when grade>=60 then credit else 0 end) as 成绩 
from sc,cou
where cou.cno=sc.cno and sc.sno=(select sno from stu where sname='张三')
--17．查询至少选修的’C001’与’C002’课程的学生学号
select sno as 学号
from sc
where sno=sc.sno and cno='C001' and sno in (select sno from sc where cno='C002')
--1）使用SC表的自连接完成
select x.sno as 学号 from sc x,sc y
where x.sno=y.sno and x.cno='C001' and y.cno='C002';
--2）使用INTERSECT（交）完成
select sno as 学号 from sc
where cno='C001'
intersect
select sno as 学号 from sc
where cno='C002';
--18．查询S001学号选修而S003学号未选修的课程号（提示：使用EXCEPT）
select cno as 课程号 from sc
where sno='S001'
except
select cno as 课程号 from sc
where sno='S003';
--use not in
select cno as 课程号
from sc
where sno='S001' and cno not in(select cno from sc where sno='S003' );
--19. 查询S001学号、S003学号都选修了哪些课程（试验：UNION）
select cno as 课程号,cname as 课程
from cou where cno in(
select cno from sc where sno='S001'
union 
select cno from sc where sno='S003'
)
order by cno;
--20．查询每个同学超过他选修的平均成绩的课程名。要求有在PTA提交通过的情况截图。
--1）用相关子查询实现
select sno as 学号, cname as 课程名,grade as 成绩
from sc as x,cou
where x.cno=cou.cno and grade > (select avg(grade) from sc as y where x.sno=y.sno);
--2）使用派生表实现。
select sc.sno 学号,cname 课程名,grade 成绩 
from sc,cou,(select sno,avg(grade) as average from sc group by sno) as a
where sc.sno=a.sno  and sc.grade>average and cou.cno=sc.cno;
--21．查询平均分高于80分的学生姓名
select sname from stu,sc
where stu.sno=sc.sno 
group by sc.sno,sname
having avg(grade)>80;
--22．查询平均分高于60分的课程的课程名。
select cname from cou 
where cno in (
	select cno from sc 
	group by cno
	having avg(grade)>60
)

select cou.cno as 课程号,cname as 课程名
from cou,sc
where cou.cno=sc.cno
group by cou.cno,cname
having avg(grade)>60
--23.查询‘C语言’课程成绩最高的前三名同学
select top 3 sname as 姓名, grade as 成绩
from stu,sc
where stu.sno=sc.sno and cno=(select cno from cou where cname='C语言') 
order by grade desc;
--24.查询平均成绩最高的前3名同学的学号，姓名，性别及年龄。
select top 3 stu.sno as 学号,sname as 姓名, sex as 性别,
2020-year(birdate) as 年龄,avg(grade) as 平均成绩
from stu,sc
where stu.sno=sc.sno
group by stu.sno,sname,sex,birdate
order by avg(grade) desc;
--25．检索C003课程成绩最高二人学号，姓名与成绩。并将结果保存于max_C003临时表中
--注：要求在本机测试语句执行情况，并截图。
select top 2 stu.sno,sname,grade
into #max_C003
from stu,sc
where stu.sno=sc.sno and sc.cno='C003'
order by grade desc;
select * from #max_C003;
--26．查询选修了张老师所讲授的所有课程的学生。
select sname
from stu
where not exists(
	select * 
	from cou
	where teacher='张老师' and not exists(
		select * 
		from sc
		where stu.sno=sc.sno and sc.cno=cou.cno
	)
);
--1.对学生表添加一条记录，记录(SO12,周强，女)等
insert stu(sno,sname,sex)values('S012','周强','0');
--2.为上述学生添加二条选课记录。
insert sc values('S012','C001','90');
insert sc values('S012','C002',null);
--3．为软件专业创建一个学生简表，用于点名。
insert into softstu(sno,sname) select sno,sname from stu where mno='02';
--select * from softstu
--create table softstu(
--	sno char(4) primary key,
--	sname varchar(8)
--)
--drop table softstu
--4．检索所授每门课程平均成绩均大于70分的教师姓名，并将检索的值送往另一个已在的表faculty(tname)
insert into faculty(tname) 
select distinct teacher from sc join cou on cou.cno=sc.cno
where teacher not in(
	select teacher from cou,sc
	where cou.cno=sc.cno
	group by sc.cno,teacher
	having avg(grade)<=70
);
--select * from faculty
--create table faculty (
--  tname char(10) default null
--)
--drop table faculty

--5.创建表totalcredit(sno,totalcredit),为该表插入各同学当前获得总学分。
insert into totalcredit(sno,totalcredit)
select stu.sno,sum(case when grade>=60 then credit else 0 end) as a
from stu left outer join sc on stu.sno=sc.sno left outer join cou on sc.cno=cou.cno
group by stu.sno
order by stu.sno;
--select * from totalcredit;
--create table totalcredit(
--	sno char(4) not null,
--	totalcredit smallint default '0'
--)
--drop table totalcredit;

--(1)	在SC中删除尚无成绩的选课元组
delete from sc where grade is null;
--(2)	把选修’C语言’课程的女同学选课元组全部删除
delete from sc where sno in (select sno from stu where sex=0) and cno=(select cno from cou where cname='C语言');
--(3)	删除周强的所有信息
delete from sc where sno=(select sno from stu where sname='周强');
delete from stu where sname='周强';

--1.将高数课不及格的成绩全改为60分
update sc set grade='60'
where grade<60 and cno=(select cno from cou where cname='高等数学');
--3.把低于所有课程总平均成绩的女同学成绩提高5%;
update sc set grade = grade*1.05
where grade<(select avg(grade) from sc) and sno in (select sno from stu where sex=0);
--3.在SC中修改C004课程的成绩，若成绩小于70分则提高5%，若成绩大于70分则提高4%
--(要求用两种方法实现，一种方法是用两个UPDATE语句实现。另一种方法是用CASE 操作的一条UPDATE语句实现)
--一个update
update sc set grade =(case when grade <70 then grade*1.05 else grade*1.04 end) where cno='C001';
--两个update
update sc set grade = grade*1.04 where grade >=70 and cno='C001';
update sc set grade = grade*1.05 where grade <70 and cno='C001';
--4.为SC表添加一个字段RANK。将各同学按60分以下为E,60-69为D,70-79为C,80-89为B,90及以上为A
update sc set rank=(case 
	when grade is null then null 
	when grade<60 then 'E' 
	when grade<70 then 'D' 
	when grade<80 then 'C' 
	when grade<90 then 'B' else 'A'
	end
)
--5. 计算每位学生已获得的总学分并填写在```stu```表中的```totalcredit```字段。
update stu set totalcredit=(
select sum((case when grade>=60 then credit when grade is null then null else 0 end)) as totalcredit
from cou,sc
where cou.cno=sc.cno and sno=stu.sno
)
