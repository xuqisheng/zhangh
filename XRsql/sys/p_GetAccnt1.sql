/*
	( ����ֵ�� Output ��ʽ����,ר�� Server �˵��� !!! )

	�洢���� p_GetAccnt1 ����ȡ��һ���µ��ʺ�,�ʺ�����ȡ����@type��ȡֵ.

		@type = 'FIT'   	�����ʺ�,	--- ebase2
		@type = 'MET'   	�����ʺ�,
		@type = 'GRP'   	�����ʺ�,
		@type = 'HTL'   	�����ʺ�,

		@type = 'RES'    	Ԥ����   ---> sys_extraid
		@type = 'HIS'   	���͵����ʺ�,
		@type = 'AR'    	AR�ʺ�

		@type = 'BUS'   	BOS ���õ���,
		@type = 'BST'   	BOS ���ʵ���,
		@type = 'BKC'   	BOS ������ҵ���

		@type = 'POS'   	POS ��ˮ�ʺ�,

		@type = 'MSG'   	���Ժ�,
		@type = 'BIL'   	���ý��ʵ���,

		@type = 'CRD'		����� K...
		@type = 'FEC'   	��Ҷһ���

--- no use

		@type = 'A1'    	A1�ʺ�,
		@type = 'A2'    	A2�ʺ�,
		@type = 'A3'    	A3�ʺ�,
		@type = 'A4'    	A4�ʺ�,

		@type = 'HOS'  	HOS				

		@type = 'BLK'   	�������ʺ�
		@type = 'GST'   	���˱�ʶ			
		@type = 'CUS'  	��λ�� C...		
*/
if exists(select * from sysobjects where name = "p_GetAccnt1" and type = 'P')
	drop proc p_GetAccnt1                                               
;                                                
create  proc  p_GetAccnt1                                                   
	@type		char(3),
	@accnt	char(10) out
as

if	@type not in ('FIT','MET','GRP','HTL','HIS','BLK','BUS','BST','POS','MSG', 'MEM',
			'AR','ARR','A1','A2','A3','A4','GST','BIL','HOS','CUS','CRD','FEC','BKC','RES','ERS','BOK','ALM','ALV','ALG')
begin
	if not exists(select 1 from sys_extraid where cat = @type)
	begin
		select @accnt = ""
		return	1
	end
	else
	begin
		update sys_extraid set id = id + 1 where cat = @type

--		if @type = 'FRN'		-- �µ�Ԥ���Ų�����ʽ,��ó�����⴦�� 4-6λ hbb 2006.01.10
--		begin
--			declare @id int 
--			select @id = id from sys_extraid where cat = @type
--			if @id > 99999
--				select @accnt = right('000000' + convert(char(10), id),6) from sys_extraid where cat = @type
--			else if @id > 9999
--				select @accnt = right('00000' +convert(char(10), id),5) from sys_extraid where cat = @type
--			else
--				select @accnt = right('0000' + convert(char(10), id),4) from sys_extraid where cat = @type
--			if @id >= 999999
--				update sys_extraid set id = 0 where cat = @type
--		end
--		else
--			select @accnt = convert(char(10), id) from sys_extraid where cat = @type

		select	@accnt = convert(char(10), id) from sys_extraid where cat = @type
		-- SRM: �����ţ����ܳ��� 4 λ
		if @type='SRM' and convert(int, @accnt)=9999
			update sys_extraid set id = 0 where cat = @type
		return 0
	end
end

begin	tran	
save	tran	p_getaccnt1_tran_1_1

-- -- -- -- -- -- -- -- 
-- use new 
-- -- -- -- -- -- -- -- 
if	@type='FIT' or @type='HTL' or @type='MET' or @type='GRP' or @type='MEM'  -- ����/������/����/����
begin
	update	sysdata set ebase2 = ebase2 + 1
	select 	@accnt = right('0000000000'+ltrim(str(ebase2 - 1 )),10) from sysdata

	if	@type='FIT' or @type='MEM' 
		select @accnt = stuff(@accnt,1,1,'F')
	else if @type='HTL' 
		select @accnt = stuff(@accnt,1,1,'H')
	else if @type='MET' 
		select @accnt = stuff(@accnt,1,1,'M')
	else if @type='GRP'
		select @accnt = stuff(@accnt,1,1,'G')
	
	goto LAB1
end
--if	@type = 'FIT'
--begin
--	update	sysdata set rng1base = rng1base + 1
--	select @accnt = yer+rang1+substring(convert(char(4),rng1base - 1 + 1000),2,3) from sysdata
--	update	sysdata set rng1base = 0,
--	                    rang1 = substring(convert(char(4),convert(int,rang1) + 1001),2,3)
--        	where rng1base = 1000
--	goto LAB1
--end
--if	@type = 'MET'
--begin
--	update	sysdata set rng2base = rng2base + 1
--	select @accnt = yer+rang2+substring(convert(char(4),rng2base - 1 + 1000),2,3) from sysdata
--	update	sysdata set rng2base = 0,
--	                    rang2 = substring(convert(char(4),convert(int,rang2) + 1001),2,3)
--        	where rng2base = 1000
--	goto LAB1
--end
--if	@type = 'GRP'
--begin
--	update	sysdata set rng3base = rng3base + 1
--	select @accnt = yer+convert(char(6),rng3base - 1) from sysdata
--	goto LAB1
--end
--if	@type = 'HTL'
--begin
--	update	sysdata set rng4base = rng4base + 1
--	select @accnt = yer+convert(char(6),rng4base - 1) from sysdata
--	goto LAB1
--end

//modi by zk 2010.1.4
--if @type='ALG' or @type='ALM' or @type='ALV' 
--	update sys_extraid set id=1 from alerts where (select '0'+substring(max(substring(no,2,6)),1,5)  from  alerts) < convert(varchar(6),getdate(),12) and cat='ALERTS'

if @type='ALM'        --��ʾ��Ϣ��������
begin
	update	sys_extraid set id = id + 1 where cat='ALERTS'
	select 	@accnt = 'M'+right('000000000'+ltrim(str(id - 1 )),9) from sys_extraid where cat='ALERTS'
	goto LAB1
end
if @type='ALV'        --��ʾ��Ϣ�����
begin
	update	sys_extraid set id = id + 1 where cat='ALERTS'
	select 	@accnt = 'V'+right('000000000'+ltrim(str(id - 1 )),9) from sys_extraid where cat='ALERTS'
	goto LAB1
end
if @type='ALG'        --��ʾ��Ϣ�ͻ�����
begin
	update	sys_extraid set id = id + 1 where cat='ALERTS'
	select 	@accnt = 'G'+right('000000000'+ltrim(str(id - 1 )),9) from sys_extraid where cat='ALERTS'
	goto LAB1
end
if @type='ERS'        --���Ԥ��
begin
	update	sysdata set rng1base = rng1base + 1
	select 	@accnt = 'E'+convert(varchar(6),getdate(),12)+right('0000'+ltrim(str(rng1base - 1 )),3) from sysdata
	goto LAB1
end
if	@type = 'HIS'						-- �ͻ�����
begin
	update	sysdata set hisbase = hisbase + 1
--	select @accnt = yer+substring(convert(char(7),hisbase - 1 + 1000000),2,6) from sysdata
-- GaoLiang 2006/10/16 �Ժ��ŵ�guest.no < 6000000, ��Ա�Ƶ��guest.no >= 6000000
	select @accnt = substring(convert(char(8),hisbase - 1 + 10000000),2,7) from sysdata
	goto LAB1
end
if	@type = 'CUS'						-- Э�鵥λ �����á��ϲ��� HIS��
begin
	update	sysdata set cusbase = cusbase + 1
	select @accnt = 'C'+substring(convert(char(7),cusbase - 1 + 1000000),2,6) from sysdata
	goto LAB1
end
if	@type = 'CRD'						-- �����
begin
	update	sysdata set cardbase = cardbase + 1
	select @accnt = 'K'+substring(convert(char(7),cardbase - 1 + 1000000),2,6) from sysdata
	goto LAB1
end
if	@type = 'BLK'						-- �����������á��ϲ��� HIS��
begin
	update	sysdata set bbase = bbase + 1
	select @accnt = yer+substring(convert(char(7),bbase - 1 + 1000000),2,6) from sysdata
	goto LAB1
end
if	@type = 'BUS'						-- BOS ���õ�
begin
	update	sysdata set fbase = fbase + 1
	select 	@accnt = right('0000000000'+ltrim(str(fbase - 1 )),10) from sysdata
	goto LAB1
end
if	@type = 'BST'						-- BOS ���˵�
begin
	update	sysdata set fsetnumb = fsetnumb + 1
	select 	@accnt = right('0000000000'+ltrim(str(fsetnumb - 1 )),10) from sysdata
	goto LAB1
end
if	@type = 'POS'						-- POS
begin
	update	sysdata set pbase = pbase + 1
	select 	@accnt = right('0000000000'+ltrim(str(pbase - 1 )),10) from sysdata
	goto LAB1
end
if	@type = 'HOS'						-- ����
begin
	update	sysdata set hbase = hbase + 1
	select 	@accnt = right('0000000000'+ltrim(str(hbase - 1 )),10) from sysdata
	goto LAB1
end
if	@type = 'RES'   -- MS Ԥ����  
begin
	update	sysdata set msbase = msbase + 1
	select 	@accnt = right('0000000000'+ltrim(str(msbase - 1 )),10) from sysdata
	goto LAB1
end
if	@type = 'MSG'		-- ���� 
begin
	update	sysdata set msgbase = msgbase + 1
	select 	@accnt = right('0000000000'+ltrim(str(msgbase - 1 )),10) from sysdata
	goto LAB1
end
if	@type = 'BIL'
begin
	update	sysdata set billbase = billbase + 1
	select 	@accnt = right('0000000000'+ltrim(str(billbase - 1 )),10) from sysdata
	goto LAB1
end
if	@type = 'AR' or @type = 'ARR'
begin
	update	sysdata set arbaser = arbaser + 1
	select	@accnt = 'AR' + substring(convert(char(6),arbaser - 1 + 100000),2,5) from sysdata
	goto LAB1
end
if	@type = 'A1'
begin
	update	sysdata set arbase1 = arbase1 + 1
	select	@accnt = 'A1' + substring(convert(char(6),arbase1 - 1 + 100000),2,5) from sysdata
	goto LAB1
end
if	@type = 'A2'
begin
	update	sysdata set arbase2 = arbase2 + 1
	select	@accnt = 'A2' + substring(convert(char(6),arbase2 - 1 + 100000),2,5) from sysdata
	goto LAB1
end
if	@type = 'A3'
begin
	update	sysdata set arbase3 = arbase3 + 1
	select	@accnt = 'A3' + substring(convert(char(6),arbase3 - 1 + 100000),2,5) from sysdata
	goto LAB1
end
if	@type = 'A4'
begin
	update	sysdata set arbase4 = arbase4 + 1
	select	@accnt = 'A4' + substring(convert(char(6),arbase4 - 1 + 100000),2,5) from sysdata
	goto LAB1
end
if	@type = 'GST'	-- �ͻ����� 
begin
	update	sysdata set gstid = gstid + 1
--	select	@accnt = yer + substring(convert(char(7),gstid - 1 + 1000000),2,6) from sysdata
	select	@accnt = substring(convert(char(7),gstid - 1 + 10000000),2,7) from sysdata
end
if	@type = 'FEC'	-- ��Ҷһ�
begin
	update	sysdata set ebase1 = ebase1 + 1
	select 	@accnt = right('0000000000'+ltrim(str(ebase1 - 1 )),10) from sysdata
	goto LAB1
end
if	@type = 'BKC'
begin
	update	sysdata set ebase3 = ebase3 + 1
	select 	@accnt = right('0000000000'+ltrim(str(ebase3 - 1 )),10) from sysdata
	goto LAB1
end
if	@type = 'BOK'	-- BUSINESS BLOCK 
begin
	update	sysdata set ebase4 = ebase4 + 1
	select 	@accnt = 'B' + right('0000000000'+ltrim(str(ebase4 - 1 )),9) from sysdata
	goto LAB1
end

LAB1:
commit	tran 
return	0
;

/*
( ����ֵ�� select ��ʽ����, ר�� PowerBuilder �˵��� !!! )
*/

if exists(select * from sysobjects where name = "p_GetAccnt" and type = 'P')
   drop proc p_GetAccnt;

create  proc  p_GetAccnt                                                   
	@type	char(3)
as

declare @accnt    char(10),
        @ret     int    
    
exec @ret = p_GetAccnt1 @type,@accnt output
if @ret <> 0
   select @accnt = ""
select @accnt
return @ret
;
