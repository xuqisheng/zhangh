

// ĳ�ͻ��ױ�һ����Ŀ 020020.day02 ���� 19.82 ���Ѿ���ȥ�����ˣ���ε�����
// ��ñ�дһ�����̴��� 


020020	day02, day99 
020
999	

update yjierep set day02=day02+19.82,day99=day99+19.82
	where date='2007.12.6' and class in ('020020', '020', '999') ; 
update yjierep set mon02=mon02+19.82,mon99=mon99+19.82
	where date>='2007.12.6' and class in ('020020', '020', '999') ; 
delete jierep ;
insert jierep select * from yjierep where date='2007.12.14'; 


020020
020199
000020
000100
990000

update yjourrep set day=day+19.82
	where date='2007.12.6' and class in ('020020', '020199', '000020', '000100', '990000') ; 
update yjierep set month=month+19.82,year=year+19.82
	where date>='2007.12.6' and class in ('020020', '020199', '000020', '000100', '990000') ; 
delete jourrep;
insert yjourrep select * from yjourrep where date='2007.12.14'; 
            

