IF OBJECT_ID('p_gds_genzjm') IS NOT NULL
    DROP PROCEDURE p_gds_genzjm
;
create proc p_gds_genzjm
	@instr			varchar(255),
	@outcode			varchar(100) output
as
-----------------------------------------------------
--	产生中文串的助记码 = 每个汉字的第一个大写字母组合
-----------------------------------------------------
declare		@firstchar		char(1),
				@cap				varchar(100),
				@hz				varchar(2)

select @instr=rtrim(ltrim(@instr)), @outcode = ''

if datalength(@instr)=0
   return  1

while datalength(@instr)>0
	begin
   select @firstchar=substring(@instr,1,1)
   select @instr=ltrim(stuff(@instr,1,1,''))
   if ascii(@firstchar)<128
		begin
      if charindex(upper(@firstchar), '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ') > 0
         select @outcode=@outcode+upper(@firstchar)
      continue
		end
   if datalength(@instr)=0 or ascii(substring(@instr,1,1))<128
		begin
      select @outcode=''
      return 0
		end

   select @cap='', @hz = @firstchar+substring(@instr,1,1)
   exec p_gds_chtran @hz, @cap output
   if @cap=''
		begin
      select @outcode=''
      return 0
   	end

   select @outcode=@outcode+@cap
   select @instr =ltrim(stuff(@instr,1,1,''))
	end
select @outcode = ltrim(@outcode)
return 0
;