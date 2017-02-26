---------------------------------------------------------------------
--	�з�һ�� ��� �з����� crs ��Ŀ - simon 2006.4.5
---------------------------------------------------------------------


---------------------------------------------------------------------
--	ͬ����Ǳ� - �⽡��
---------------------------------------------------------------------
if exists(select * from sysobjects where name = 'synmaster')
	drop table synmaster;
create table synmaster
(
	masteraccnt     varchar(10)  								not null,
	belongtable     varchar(50)  	default 'master' 		not null,
	operateflag     char(1)   		default 'Y' 			not null   --Y��ʾ��Ҫ����,N��ʾ�������
);
exec   sp_primarykey synmaster, belongtable, masteraccnt
create unique index index1 on synmaster(belongtable, masteraccnt)
;



//---------------------------------------------------------------------
//--	PMS ϵͳ����- �� master update ���������������������
//--	ע��:
//--		���ж��Ƿ���Ҫ�Ǽ� synmaster, ���Բ�ȡ�ж�ĳЩ�вŴ���ķ�ʽ��
//--		�������ͨ�� update(??) ������ 
//---------------------------------------------------------------------
//declare	@masteraccnt 	char(10)
//select @masteraccnt = accnt from inserted where exp_s3 like 'CRS:%'
//if @@rowcount>0 and update(logmark) // and (update(type) or update(room) or update(ratecode) or update(market) or update(???)) 
//begin
//	if not exists(select 1 from synmaster where belongtable='master' and masteraccnt=@masteraccnt)
//		insert synmaster(masteraccnt, belongtable, operateflag) values(@masteraccnt, 'master', 'Y')
//	else
//		update synmaster set operateflag='Y' where belongtable='master' and masteraccnt=@masteraccnt 
//end
//
//