// **********************************************************************************
//		transfer_log
//
//			该表用来记录宾客账转到 AR 账的情况，记录该账的结账状况
//			它可以表达宾客账是否有转账，以及以后的结账情况。
//			
//			注意：如果该账转到其他前台账，则该账属主转移 !!!
//
//			考虑：如果我们的帐务库有一列**‘原始账号’，用来记录每一笔账的原始发生地
//					情况就很简单，transfer_log 也就不需要存在了。
//
//															Written by GDS 2001/11
//
// **********************************************************************************

// 注意：这个重建不考虑已经结帐的部分 !

// ----------------------------------------------------------------------------------
// 1.	清空
// ----------------------------------------------------------------------------------
//truncate table transfer_log;


// ----------------------------------------------------------------------------------
// 2. 插入记录
//		注意：这里的源账号部分数据暂时不关联原始的账号记录，因为原始的帐务记录分散在
//				account, haccount, 并且关联的结果可能错误，
//				如:转账账务被分拆
//					1).转账定金被部分转销
//					2).转账费用被部分结账
// ----------------------------------------------------------------------------------
//insert transfer_log 
//	select accntof, inumber, charge, credit, empno, log_date,
//			accnt, number, 0, 0, Null, Null, ''
//		from account
//			where accnt like 'A%' and tofrom='FM' and billno='' ;


// ----------------------------------------------------------------------------------
// 3. 对原始账次进行跟踪
//			原始账次的条件：accnt like 'A%' and tofrom='FM'
//			这就表示从前台账转来的账次不再跟踪了
//			
//			下面两部分要反复做，知道符合条件的计数 = 0
// ----------------------------------------------------------------------------------
//	part 1. 关联 account
//select count(1) from transfer_log a, account b 
//	where a.accnt=b.accnt and a.number=b.number and a.accnt like 'A%' and b.tofrom='FM' ;
//update transfer_log set  accnt=a.accntof, number=a.inumber, 
//		charge=a.charge, credit=a.credit, empno=a.empno, date=a.log_date
//	from account a where transfer_log.accnt=a.accnt and transfer_log.number=a.number 
//		and a.accnt like 'A%' and a.tofrom='FM';
//select count(1) from transfer_log a, account b 
//	where a.accnt=b.accnt and a.number=b.number and a.accnt like 'A%' and b.tofrom='FM' ;

//	part 2. 关联 haccount
//select count(1) from transfer_log a, haccount b 
//	where a.accnt=b.accnt and a.number=b.number and a.accnt like 'A%' and b.tofrom='FM' ;
//update transfer_log set  accnt=a.accntof, number=a.inumber, 
//		charge=a.charge, credit=a.credit, empno=a.empno, date=a.date
//	from haccount a where transfer_log.accnt=a.accnt and transfer_log.number=a.number 
//		and a.accnt like 'A%' and a.tofrom='FM';
//select count(1) from transfer_log a, haccount b 
//	where a.accnt=b.accnt and a.number=b.number and a.accnt like 'A%' and b.tofrom='FM' ;


// ----------------------------------------------------------------------------------
// 4. 删除 AR->AR 的转账 !
// ----------------------------------------------------------------------------------
//delete transfer_log where accnt like 'A%';

// ----------------------------------------------------------------------------------
// 5. 更新源账次的详细情况
// ----------------------------------------------------------------------------------
//update transfer_log set charge=a.charge,credit=a.credit,empno=a.empno,date=a.log_date
//	from account a where transfer_log.accnt=a.accnt and transfer_log.number=a.number;
//update transfer_log set charge=a.charge,credit=a.credit,empno=a.empno,date=a.log_date
//	from haccount a where transfer_log.accnt=a.accnt and transfer_log.number=a.number;
//

// ----------------------------------------------------------------------------------
// 6. 对于分割帐务要找出原始的 number 
// ----------------------------------------------------------------------------------
// a. 观察不一致的帐务
//select * from transfer_log a
//	where not exists(select 1 from account b where a.accnt=b.accnt and a.number=b.number)
//	  and not exists(select 1 from haccount c where a.accnt=c.accnt and a.number=c.number)
//;
//
//	b. 处理
//update transfer_log 
//	set number= (select min(a.inumber) from account a, account b
//						where transfer_log.araccnt=b.accnt and transfer_log.arnumber=b.number
//							and a.accnt=b.accnt and a.pccode=b.pccode and a.accntof=b.accntof)
//	where not exists(select 1 from account x  where transfer_log.accnt=x.accnt and transfer_log.number=x.number)
//	  and not exists(select 1 from haccount y where transfer_log.accnt=y.accnt and transfer_log.number=y.number)
//;
//
// --------------->>>>> game over !




// ----------------------------------------------------------------------------------
// 附录 ： 插入得不一致效果
//			方法一：不关联明细
//			方法二：关联明细
// ----------------------------------------------------------------------------------
//select accntof, inumber, accnt, number	from account
//		where accnt like 'A%' and tofrom='FM' and billno='';
//
//select b.accnt, b.number, a.accnt, a.number
//	from account  a, account b 
//		where a.accnt like 'A%' and a.tofrom='FM' and a.billno='' 
//			and a.accntof=b.accnt and a.inumber=b.number
//union
//select b.accnt, b.number, a.accnt, a.number
//	from account  a, haccount b 
//		where a.accnt like 'A%' and a.tofrom='FM' and a.billno='' 
//			and a.accntof=b.accnt and a.inumber=b.number;
//


// ----------------------------------------------------------------------------------
// END --------------------Written by GDS 2001/11
// ----------------------------------------------------------------------------------

//update transfer_log set accnt = 'G0'+rtrim(accnt)+'0' where accnt like '_8%';
//update transfer_log set accnt = 'F0'+rtrim(accnt)+'0' where accnt < 'A';
//