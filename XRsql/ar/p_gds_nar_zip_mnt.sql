
--  �ù�����ʱ���󣬲���ʹ��    simon 2008.3.15   

if exists (select * from sysobjects where name ='p_gds_nar_zip_mnt' and type ='P')
	drop proc p_gds_nar_zip_mnt
;
//create proc p_gds_nar_zip_mnt
//	@accnt			varchar(10) = '',
//	@mode				varchar(10) = 'chk'  -- chk / mnt  
//as
//------------------------------------------------------
//-- ���� ��AR ����ѹ������  
//-- 
//------------------------------------------------------
//declare
//	@maccnt			char(10),
//	@pnumber			int  
//
//if rtrim(@accnt) is null 
//	select @accnt = '%'
//
//declare c_arlist cursor for select distinct accnt, pnumber from har_detail where accnt like @accnt and pnumber<>0 
//open c_arlist 
//fetch c_arlist into @maccnt, @pnumber  
//while @@sqlstatus = 0 
//begin 
////	if @mode = 'chk' -- �������д�����Ϊ����ʿ�����ѹ���ʣ�ǰ���Ѿ��к������� 
////	begin
////		if exists(select 1 from ar_detail where accnt=@maccnt and number=@pnumber) 
////			select @maccnt, @pnumber, charge9 - isnull((select sum(a.charge9) from har_detail a where a.accnt=ar_detail.accnt and a.pnumber=ar_detail.number),0), 
////					credit9 - isnull((select sum(b.credit9) from har_detail b where b.accnt=ar_detail.accnt and b.pnumber=ar_detail.number),0)
////				from ar_detail where accnt=@maccnt and number=@pnumber 
////		else -- �ֱ�ѹ���� 
////			select @maccnt, @pnumber, charge9 - isnull((select sum(a.charge9) from har_detail a where a.accnt=har_detail.accnt and a.pnumber=har_detail.number),0), 
////					credit9 - isnull((select sum(b.credit9) from har_detail b where b.accnt=har_detail.accnt and b.pnumber=har_detail.number),0)
////				from har_detail where accnt=@maccnt and number=@pnumber 
////	end
////	else
////	begin
////		if exists(select 1 from ar_detail where accnt=@maccnt and number=@pnumber) 
////			update ar_detail set charge9=isnull((select sum(a.charge9) from har_detail a where a.accnt=ar_detail.accnt and a.pnumber=ar_detail.number),0), 
////					credit9=isnull((select sum(b.credit9) from har_detail b where b.accnt=ar_detail.accnt and b.pnumber=ar_detail.number),0)
////				where accnt=@maccnt and number=@pnumber 
////--		else -- �ֱ�ѹ���ˡ����ʱ���ܴ�����Ϊ�����ֱ�������  
////--			update har_detail set charge9=isnull((select sum(a.charge9) from har_detail a where a.accnt=har_detail.accnt and a.pnumber=har_detail.number),0), 
////--					credit9=isnull((select sum(b.credit9) from har_detail b where b.accnt=har_detail.accnt and b.pnumber=har_detail.number),0)
////--				where accnt=@maccnt and number=@pnumber 
////	end 
//
//	fetch c_arlist into @maccnt, @pnumber   
//end 
//close c_arlist
//deallocate cursor c_arlist 
//
//return 0;

