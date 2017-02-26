/*

	�ͷ�����ϵͳ�ʺŻ�ȡ

	( ����ֵ�� Output ��ʽ����,ר�� Server �˵��� !!! )

	�洢���� p_hs_GetAccnt1 ����ȡ��һ���µ��ʺ�,�ʺ�����ȡ����@type��ȡֵ.
		@type = 'MB'   ��ʾȡ�õ������¿��� MINI ?����,
		@type = 'XH'   ��ʾȡ�õ������¿��� ����   ����,
		@type = 'SB'   ��ʾȡ�õ������¿��� �豸   �ʺ�,
		@type = 'XY'   ��ʾȡ�õ������¿��� ϴ��   �ʺ�,
		@type = 'OO'   ��ʾȡ�õ������¿��� ά��   �ʺ�,
		@type = 'SW'   ��ʾȡ�õ������¿��� ʧ��   �ʺ�,
		@type = 'PC'   ��ʾȡ�õ������¿��� �⳥   �ʺ�,
		@type = 'HA'   ��ʾȡ�õ������¿��� HA     �ʺ�,
		@type = 'HB'   ��ʾȡ�õ������¿��� HB     �ʺ�,
		@type = 'HC'   ��ʾȡ�õ������¿��� HC     �ʺ�,
*/
if exists(select * from sysobjects where name = "p_hs_GetAccnt1" and type = 'P')
	drop proc p_hs_GetAccnt1                                               
;                                                
create  proc  p_hs_GetAccnt1                                                   
	@type		char(3),
	@accnt	char(10) out
as

if	@type not in ('MB','XH','SB','XY','OO','SW','PC','HA','HB','HC')
begin
	select @accnt = ""      //return ""
	return	1
end

begin	tran	
save	tran	p_hs_GetAccnt1_tran_1_1

if	@type = 'MB'
begin
	update	hs_sysdata set mbbase = mbbase + 1
	select 	@accnt = str(mbbase - 1 ) from hs_sysdata
	goto LAB1
end
if	@type = 'XH'
begin
	update	hs_sysdata set xhbase = xhbase + 1
	select 	@accnt = str(xhbase - 1 ) from hs_sysdata
	goto LAB1
end
if	@type = 'SB'
begin
	update	hs_sysdata set sbbase = sbbase + 1
	select 	@accnt = str(sbbase - 1 ) from hs_sysdata
	goto LAB1
end
if	@type = 'XY'
begin
	update	hs_sysdata set xybase = xybase + 1
	select 	@accnt = str(xybase - 1 ) from hs_sysdata
	goto LAB1
end
if	@type = 'SW'
begin
	update	hs_sysdata set swbase = swbase + 1
	select 	@accnt = str(swbase - 1 ) from hs_sysdata
	goto LAB1
end
if	@type = 'OO'
begin
	update	hs_sysdata set oobase = oobase + 1
	select 	@accnt = str(oobase - 1 ) from hs_sysdata
	goto LAB1
end
if	@type = 'PC'
begin
	update	hs_sysdata set pcbase = pcbase + 1
	select 	@accnt = str(pcbase - 1 ) from hs_sysdata
	goto LAB1
end
if	@type = 'HA'
begin
	update	hs_sysdata set habase = habase + 1
	select 	@accnt = str(habase - 1 ) from hs_sysdata
	goto LAB1
end
if	@type = 'HB'
begin
	update	hs_sysdata set hbbase = hbbase + 1
	select 	@accnt = str(hbbase - 1 ) from hs_sysdata
	goto LAB1
end
if	@type = 'HC'
begin
	update	hs_sysdata set hcbase = hcbase + 1
	select 	@accnt = str(hcbase - 1 ) from hs_sysdata
	goto LAB1
end

LAB1:
select @accnt = right('0000'+ltrim(@accnt), 10)                     

commit	tran 
return	0
;

/*
( ����ֵ�� select ��ʽ����, ר�� PowerBuilder �˵��� !!! )
*/
if exists(select * from sysobjects where name = "p_hs_GetAccnt" and type = 'P')
   drop proc p_hs_GetAccnt
;
create  proc  p_hs_GetAccnt                                                   
	@type	char(3)
as
declare @accnt    char(10),
        @ret     	int    
exec @ret = p_hs_GetAccnt1 @type,@accnt output
if @ret <> 0
   select @accnt = ""
select @accnt
return @ret
;
