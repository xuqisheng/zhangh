// ------------------------------------------------------------------------
//	������� - ����.... ����ʹ�õ�ʱ��,�����޸���ԵĶ���
// ------------------------------------------------------------------------

//// ������Ҵ��� 
//if exists(select * from sysobjects where name='p_gds_pinyin_apply' and type ='P')
//   drop proc p_gds_pinyin_apply;
//create proc p_gds_pinyin_apply
//as
//declare	@code				char(3),
//			@descript		varchar(30),
//			@helpcode		varchar(20)
//declare c_translate cursor for select code, descript from countrycode
//open c_translate
//fetch c_translate into @code, @descript
//while @@sqlstatus = 0
//begin
//	exec p_gds_pinyin @descript, '0', 'R', @helpcode output 		-- ��λ��ĸ 
//	update countrycode set helpcode = @helpcode where code=@code
//
//	fetch c_translate into @code, @descript
//end
//close c_translate
//deallocate cursor c_translate
//select code, descript, helpcode from countrycode order by helpcode
//;



// �����ձ����� 
if exists(select * from sysobjects where name='p_gds_pinyin_apply' and type ='P')
   drop proc p_gds_pinyin_apply;
create proc p_gds_pinyin_apply
as
declare	@code				char(10),
			@descript		varchar(30),
			@helpcode		varchar(30)
declare c_translate cursor for select code, descript from basecode where cat='lastname' and grp='�ձ�'
open c_translate
fetch c_translate into @code, @descript
while @@sqlstatus = 0
begin
	select @helpcode='' 
	exec p_gds_pinyin @descript, '10', 'R', @helpcode output 	 -- ȫ��ƴ�� 
	update basecode set descript1 = @helpcode where code=@code and cat='lastname' 

	fetch c_translate into @code, @descript
end
close c_translate
deallocate cursor c_translate
select cat, code, descript, descript1 from basecode where cat='lastname' order by sequence, grp, code 
;

exec p_gds_pinyin_apply;


