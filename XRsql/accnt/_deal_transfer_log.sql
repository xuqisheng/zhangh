// **********************************************************************************
//		transfer_log
//
//			�ñ�������¼������ת�� AR �˵��������¼���˵Ľ���״��
//			�����Ա��������Ƿ���ת�ˣ��Լ��Ժ�Ľ��������
//			
//			ע�⣺�������ת������ǰ̨�ˣ����������ת�� !!!
//
//			���ǣ�������ǵ��������һ��**��ԭʼ�˺š���������¼ÿһ���˵�ԭʼ������
//					����ͺܼ򵥣�transfer_log Ҳ�Ͳ���Ҫ�����ˡ�
//
//															Written by GDS 2001/11
//
// **********************************************************************************

// ע�⣺����ؽ��������Ѿ����ʵĲ��� !

// ----------------------------------------------------------------------------------
// 1.	���
// ----------------------------------------------------------------------------------
//truncate table transfer_log;


// ----------------------------------------------------------------------------------
// 2. �����¼
//		ע�⣺�����Դ�˺Ų���������ʱ������ԭʼ���˺ż�¼����Ϊԭʼ�������¼��ɢ��
//				account, haccount, ���ҹ����Ľ�����ܴ���
//				��:ת�����񱻷ֲ�
//					1).ת�˶��𱻲���ת��
//					2).ת�˷��ñ����ֽ���
// ----------------------------------------------------------------------------------
//insert transfer_log 
//	select accntof, inumber, charge, credit, empno, log_date,
//			accnt, number, 0, 0, Null, Null, ''
//		from account
//			where accnt like 'A%' and tofrom='FM' and billno='' ;


// ----------------------------------------------------------------------------------
// 3. ��ԭʼ�˴ν��и���
//			ԭʼ�˴ε�������accnt like 'A%' and tofrom='FM'
//			��ͱ�ʾ��ǰ̨��ת�����˴β��ٸ�����
//			
//			����������Ҫ��������֪�����������ļ��� = 0
// ----------------------------------------------------------------------------------
//	part 1. ���� account
//select count(1) from transfer_log a, account b 
//	where a.accnt=b.accnt and a.number=b.number and a.accnt like 'A%' and b.tofrom='FM' ;
//update transfer_log set  accnt=a.accntof, number=a.inumber, 
//		charge=a.charge, credit=a.credit, empno=a.empno, date=a.log_date
//	from account a where transfer_log.accnt=a.accnt and transfer_log.number=a.number 
//		and a.accnt like 'A%' and a.tofrom='FM';
//select count(1) from transfer_log a, account b 
//	where a.accnt=b.accnt and a.number=b.number and a.accnt like 'A%' and b.tofrom='FM' ;

//	part 2. ���� haccount
//select count(1) from transfer_log a, haccount b 
//	where a.accnt=b.accnt and a.number=b.number and a.accnt like 'A%' and b.tofrom='FM' ;
//update transfer_log set  accnt=a.accntof, number=a.inumber, 
//		charge=a.charge, credit=a.credit, empno=a.empno, date=a.date
//	from haccount a where transfer_log.accnt=a.accnt and transfer_log.number=a.number 
//		and a.accnt like 'A%' and a.tofrom='FM';
//select count(1) from transfer_log a, haccount b 
//	where a.accnt=b.accnt and a.number=b.number and a.accnt like 'A%' and b.tofrom='FM' ;


// ----------------------------------------------------------------------------------
// 4. ɾ�� AR->AR ��ת�� !
// ----------------------------------------------------------------------------------
//delete transfer_log where accnt like 'A%';

// ----------------------------------------------------------------------------------
// 5. ����Դ�˴ε���ϸ���
// ----------------------------------------------------------------------------------
//update transfer_log set charge=a.charge,credit=a.credit,empno=a.empno,date=a.log_date
//	from account a where transfer_log.accnt=a.accnt and transfer_log.number=a.number;
//update transfer_log set charge=a.charge,credit=a.credit,empno=a.empno,date=a.log_date
//	from haccount a where transfer_log.accnt=a.accnt and transfer_log.number=a.number;
//

// ----------------------------------------------------------------------------------
// 6. ���ڷָ�����Ҫ�ҳ�ԭʼ�� number 
// ----------------------------------------------------------------------------------
// a. �۲첻һ�µ�����
//select * from transfer_log a
//	where not exists(select 1 from account b where a.accnt=b.accnt and a.number=b.number)
//	  and not exists(select 1 from haccount c where a.accnt=c.accnt and a.number=c.number)
//;
//
//	b. ����
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
// ��¼ �� ����ò�һ��Ч��
//			����һ����������ϸ
//			��������������ϸ
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