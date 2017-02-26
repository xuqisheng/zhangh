//truncate table argst
//insert argst select no, accnt, tag1, tag2, tag3, tag4, tag5, cby, changed, logmark from v5..argst;
//
//delete basecode where cat like 'chgcod_deptno%';
//insert basecode select 'chgcod_deptno', deptno, deptname, isnull(descript1, ''), 'F', 'F', convert(integer, deptno) * 10, tag
//	from v5..deptdef where type = '0';
//insert basecode select 'chgcod_deptno1', deptno, deptname, isnull(descript1, ''), 'F', 'F', convert(integer, deptno) * 10, tag
//	from v5..deptdef where type = '1';
//insert basecode select 'chgcod_deptno2', deptno, deptname, isnull(descript1, ''), 'F', 'F', convert(integer, deptno) * 10, tag
//	from v5..deptdef where type = '2';
//insert basecode select 'chgcod_deptno3', deptno, deptname, isnull(descript1, ''), 'F', 'F', convert(integer, deptno) * 10, tag
//	from v5..deptdef where type = '3';
//insert basecode select 'chgcod_deptno4', deptno, deptname, isnull(descript1, ''), 'F', 'F', convert(integer, deptno) * 10, tag
//	from v5..deptdef where type = '4';
//insert basecode select 'chgcod_deptno5', deptno, deptname, isnull(descript1, ''), 'F', 'F', convert(integer, deptno) * 10, tag
//	from v5..deptdef where type = '5';
//insert basecode select 'chgcod_deptno6', deptno, deptname, isnull(descript1, ''), 'F', 'F', convert(integer, deptno) * 10, tag
//	from v5..deptdef where type = '6';
//insert basecode select 'chgcod_deptno7', deptno, deptname, isnull(descript1, ''), 'F', 'F', convert(integer, deptno) * 10, tag
//	from v5..deptdef where type = '7';
//insert basecode select 'chgcod_deptno8', deptno, deptname, isnull(descript1, ''), 'F', 'F', convert(integer, deptno) * 10, tag
//	from v5..deptdef where type = '8';
//insert basecode select 'chgcod_deptno9', deptno, deptname, isnull(descript1, ''), 'F', 'F', convert(integer, deptno) * 10, tag
//	from v5..deptdef where type = '9';
//
truncate table mktsummaryrep;
insert mktsummaryrep select * from v5..mktsummaryrep;
truncate table ymktsummaryrep;
insert ymktsummaryrep select * from v5..ymktsummaryrep where date >= '2003/1/1';

truncate table gststa;
insert gststa select * from v5..gststa;
truncate table ygststa;
insert ygststa select * from v5..ygststa where date >= '2003/1/1';

truncate table gststa1;
insert gststa1 select * from v5..gststa1;
truncate table ygststa1;
insert ygststa1 select * from v5..ygststa1 where date >= '2003/1/1';

truncate table rmsalerep_new;
insert rmsalerep_new select * from v5..rmsalerep_new;
truncate table yrmsalerep_new;
insert yrmsalerep_new select * from v5..yrmsalerep_new where date >= '2003/1/1';

truncate table discount;
insert discount select * from v5..discount;
truncate table ydiscount;
insert ydiscount select * from v5..ydiscount where date >= '2003/1/1';

truncate table bosjie;
insert bosjie select * from v5..bosjie;
truncate table ybosjie;
insert ybosjie select * from v5..ybosjie where date >= '2003/1/1';

truncate table bosdai;
insert bosdai select * from v5..bosdai;
truncate table ybosdai;
insert ybosdai select * from v5..ybosdai where date >= '2003/1/1';

truncate table deptjie;
insert deptjie select * from v5..deptjie;
truncate table ydeptjie;
insert ydeptjie select * from v5..ydeptjie where date >= '2003/1/1';

truncate table deptdai;
insert deptdai select * from v5..deptdai;
truncate table ydeptdai;
insert ydeptdai select * from v5..ydeptdai where date >= '2003/1/1';

//truncate table pos_report;
//insert pos_report select * from v5..pos_report;

truncate table cashrep;
insert cashrep select * from v5..cashrep;
truncate table ycashrep;
insert ycashrep select * from v5..ycashrep where date >= '2003/1/1';

//truncate table dayrepo;
//insert dayrepo select * from v5..dayrepo;
//truncate table ydayrepo;
//insert ydayrepo select * from v5..ydayrepo;

//-------------------------------------------------JJH

truncate table cashrep_scjj;
insert cashrep_scjj select * from v5..cashrep_scjj;
truncate table ycashrep_scjj;
insert ycashrep_scjj select * from v5..ycashrep_scjj where date >= '2003/1/1';

truncate table discount_scjj;
insert discount_scjj select * from v5..discount_scjj;
truncate table ydiscount_scjj;
insert ydiscount_scjj select * from v5..ydiscount_scjj where date >= '2003/1/1';

truncate table torrepo;
insert torrepo select date, type ,modu_id, roomno, foliono, name, groupno, grpname, araccnt, arname, 
	amount1, amount2, amount3, amount4, amount5, amount6, amount7, amount8, amount9, amount10, amount, empno, descript
	from v5..torrepo;
truncate table ytorrepo;
insert ytorrepo select date, type ,modu_id, roomno, foliono, name, groupno, grpname, araccnt, arname, 
	amount1, amount2, amount3, amount4, amount5, amount6, amount7, amount8, amount9, amount10, amount, empno, descript
	from v5..ytorrepo where date >= '2003/1/1';

//-------------------------------------------------JJH

truncate table jierep;
insert jierep select * from v5..jierep;
truncate table yjierep;
insert yjierep select * from v5..yjierep where date >= '2003/1/1';

truncate table dairep;
insert dairep select * from v5..dairep;
truncate table ydairep;
insert ydairep select * from v5..ydairep where date >= '2003/1/1';

//truncate table njourrep;
//insert njourrep select * from v5..njourrep;
//truncate table ynjourrep;
//insert ynjourrep select * from v5..ynjourrep;

truncate table jierep_jourrep;
insert jierep_jourrep select * from v5..jierep_jourrep;
truncate table jierep_njourrep;
insert jierep_njourrep select * from v5..jierep_njourrep;

truncate table jourrep;
insert jourrep select *, 0, 0, 0 from v5..jourrep;
truncate table yjourrep;
insert yjourrep select *, 0, 0, 0 from v5..yjourrep where date >= '2003/1/1';

truncate table sjourrep;
insert sjourrep select * from v5..sjourrep;
update sjourrep set pccode = a.pos_item from a_chgcod a where sjourrep.pccode = a.old_pccode;
truncate table ysjourrep;
insert ysjourrep select * from v5..ysjourrep where date >= '2003/1/1';
update ysjourrep set pccode = a.pos_item from a_chgcod a where ysjourrep.pccode = a.old_pccode;

truncate table act_bal;
insert act_bal select date,accnt,name,sta,roomno,ooroomno,groupno,arr,dep,lastbl,
	day01,day02,day03,day04,day05,day06,day07,day08,day09,day10,day11,day12,day99,
	ttd01,ttd02,ttd03,ttd04,ttd05,ttd06,ttd07,ttd08,ttd09,ttd10,ttd11,ttd12,ttd99,
	cred01,cred02,cred03,cred04,cred05,cred99,tcrd01,tcrd02,tcrd03,tcrd04,tcrd05,tcrd99,tillbl
 from v5..act_bal;
truncate table yact_bal;
insert yact_bal select  date,accnt,name,sta,roomno,ooroomno,groupno,arr,dep,lastbl,
	day01,day02,day03,day04,day05,day06,day07,day08,day09,day10,day11,day12,day99,
	ttd01,ttd02,ttd03,ttd04,ttd05,ttd06,ttd07,ttd08,ttd09,ttd10,ttd11,ttd12,ttd99,
	cred01,cred02,cred03,cred04,cred05,cred99,tcrd01,tcrd02,tcrd03,tcrd04,tcrd05,tcrd99,tillbl
 from v5..yact_bal where date >= '2003/1/1';

truncate table bosjie;
insert bosjie select * from v5..bosjie;
update bosjie set code = a.pos_item from a_chgcod a where bosjie.code = a.old_pccode;
truncate table ybosjie;
insert ybosjie select * from v5..ybosjie where date >= '2003/1/1';
update ybosjie set code = a.pos_item from a_chgcod a where ybosjie.code = a.old_pccode;

//truncate table bosdai;
//insert bosdai select * from v5..bosdai;
//update bosjie set code = a.pos_item from a_chgcod a where bosjie.code = a.old_pccode;

//delete sys_empno where empno <> 'FOX';
//insert sys_empno select empno, name, isnull(password, ''), '0', Null, Null, getdate(), isnull(allows, ''), locked, 'T', '', '', '', 'T', 'T', '' from v5..auth_login;
//
