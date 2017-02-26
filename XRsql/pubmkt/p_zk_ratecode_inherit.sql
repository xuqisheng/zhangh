if  exists(select * from sysobjects where name = "p_zk_ratecode_inherit")
	drop proc p_zk_ratecode_inherit;
create proc p_zk_ratecode_inherit
	@no0				varchar(15),
	@no1				varchar(15)
as
declare		@ret		int,
				@msg		varchar(60),
				@des		varchar(150),
				@num		int,
				@rows		int,
				@code		char(10)

select @ret = 0, @msg = ''

select @des = descript from rmratecode where code=@no0
if @@rowcount = 0
begin
	select @ret=1, @msg='房价码 - '	+ @no0 + ' - 已经不存在'
	goto p_out
end
if exists(select 1 from rmratecode where code=@no1 )
begin
	select @ret=1, @msg='房价码 - '	+ @no1 + ' - 已经存在'
	goto p_out
end

//select @des = rtrim(substring(@des+'-copy', 1, 30))
//if exists(select 1 from rmratecode where descript=@des )
//begin
//	select @ret=1, @msg='房价码描述 - '	+ @des + ' - 已经存在'
//	goto p_out
//end


delete rmratecode where (code=rtrim(@no1))
select * into #temp from rmratecode where (code=rtrim(@no0))
update #temp set code=rtrim(@no1), descript=@des,inher_fo=@no0
insert rmratecode select * from #temp


delete rmratecode_link where (code=rtrim(@no1))
select * into #temp1 from rmratecode_link where (code=rtrim(@no0))
update #temp1 set code=rtrim(@no1)
insert rmratecode_link select * from #temp1
//select rmratedef.* into #temp2 from rmratedef,rmratecode_link where rmratedef.code=rmratecode_link.rmcode  and (rmratecode_link.code=rtrim(@no0))
//select rmratedef_sslink.* into #temp3 from rmratedef_sslink,rmratecode_link where rmratedef_sslink.code=rmratecode_link.rmcode  and (rmratecode_link.code=rtrim(@no0))
//select @num = convert(int,substring(max(rmcode),datalength(max(rmcode)) -2,3)) from rmratecode_link where rmcode like '@%'
//if @num=0 or @num=null
//	select @num=1

//declare c_1 cursor for select rmcode from rmratecode_link where code=@no0
//open c_1
//fetch c_1 into @code
//while @@sqlstatus=0
//	begin
//	update #temp1 set code=rtrim(@no1),rmcode='@'+rtrim(convert(char,getdate(),12))+substring('000'+rtrim(convert(char,@num)),datalength('000'+rtrim(convert(char,@num))) -2,3) where rmcode=@code
//	update #temp2 set code='@'+rtrim(convert(char,getdate(),12))+substring('000'+rtrim(convert(char,@num)),datalength('000'+rtrim(convert(char,@num))) -2,3)
//							,descript=descript+'-copy' where code=@code
//	update #temp3 set code='@'+rtrim(convert(char,getdate(),12))+substring('000'+rtrim(convert(char,@num)),datalength('000'+rtrim(convert(char,@num))) -2,3)
//							 where code=@code
//	select @num=@num+1
//	fetch c_1 into @code
//	end
//close c_1
//

//insert rmratecode_link select * from #temp1
//insert rmratedef select * from #temp2
//insert rmratedef_sslink select * from #temp3






select @ret = 0, @msg = ''


p_out:
select @ret, @msg
return @ret

;