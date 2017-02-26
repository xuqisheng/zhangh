
if exists ( select * from sysobjects where name = "p_cyj_pos_touch_accnt_dtl" and type ="P")
   drop proc p_cyj_pos_touch_accnt_dtl;
create proc p_cyj_pos_touch_accnt_dtl
	@type			char(10),					/*类别: FIT - Front Acccount; AR - AR Account; GUEST - guest list; COMPANY - company list*/
	@accnt		char(10),					/*帐号*/
	@no			char(10),					/*签单人号*/
	@pccode		char(3),
	@shift		char(1),
	@langid		int	= 0
as
----------------------------------------------------------------------------------------------
--
--	触摸屏: 结账查询帐号窗口--帐号明细内容
--
----------------------------------------------------------------------------------------------
declare 
	@roomno			char(6),
	@name1			char(50),
	@name2			char(50),
	@haccnt			char(10),
	@cusno			char(10),
	@cus				char(30),
	@paycode			char(10),
	@package			char(30),
	@ref				varchar(100),
	@arr				datetime,
	@dep				datetime,
	@charge			money,
	@credit			money,
	@accredit		money,
	@pcrecamount	money,
	@locksta			char(1),
	@lockref			char(28),
	@pccodes			char(255),
	@chgcod			char(5),
	@posint			char(1),
	@sno				char(20),
	@srqs				char(10),
	@pcrec			char(10),
	@limit			money,
	@sex				char(4),
	@ident			char(30),
	@mode				char(3),         -- 模式
	@modedes			char(30),        -- 模式 des
	@ref2				varchar(150),     -- 餐饮喜好
	
	@birth			datetime

if upper(@type) = 'AR' 
	begin
	if exists(select 1 from sysoption where catalog ='hotel' and item ='lic_buy.1' and charindex('nar',value)>0)	
		or exists(select 1 from sysoption where catalog ='hotel' and item ='lic_buy.2' and charindex('nar',value)>0)	
		select @roomno = '',@haccnt=haccnt,@cusno='',@arr=arr,@dep=dep,@paycode='',@limit=limit,@charge=charge,@credit=credit,@accredit=accredit,@package='',@ref='',@locksta='',@srqs = srqs  from ar_master  where accnt =@accnt
	else
		select @roomno = roomno,@haccnt=haccnt,@cusno=cusno,@arr=arr,@dep=dep,@paycode=paycode,@limit=limit,@charge=charge,@credit=credit,@accredit=accredit,@package=packages,@ref=ref,@locksta=substring(extra, 10, 1),@srqs = srqs  from master where accnt =@accnt
	if @no > '' 
		select @name1=name,@name2=name2,@sno = isnull(sno,'') from guest where no=@no
	else
		select @name1=name,@name2=name2,@sno = isnull(sno,'') from guest where no=@haccnt
	select @cusno=name from guest where no=@cusno
	select @pccodes = ''
	select @pccodes = rtrim(pccodes) from subaccnt where type = '0' and accnt = @accnt
	if @pccodes <>'*' 
		select @pccodes = @pccodes +','
	
	if @pccode <> '' 
		begin
		select  @chgcod = pccode from pos_int_pccode where class ='2' and shift = @shift and pos_pccode = @pccode
		if @langid = 0 
			if exists	(select 1 from pccode where charindex(@chgcod+',', @pccodes)>0
					or @pccodes = '*'
					or charindex((select deptno1 + '*' from pccode where pccode = @chgcod), @pccodes ) >0 )
				select @lockref ='记帐:  ' +'允许记帐'
			else
				select @lockref ='记帐:  ' +'不允许记帐'
		else
			if exists	(select 1 from pccode where charindex(@chgcod+',', @pccodes)>0
					or @pccodes = '*'
					or charindex((select deptno1 + '*' from pccode where pccode = @chgcod), @pccodes ) >0 )
				select @lockref ='Post Lock:  ' +'Can Posting'
			else
				select @lockref ='Post Lock:  ' +'Can not Posting'
		end
	else
		select @lockref = ''         -- 如果没有指定餐厅, 返回是否记帐信息为空

	if @langid <> 0 
		select ref1 = substring('Name:  ' + @name1 + space(28), 1, 28) + space(2)
			+   substring('       '   + @name2 + space(28), 1, 28) + space(2)
			+ 	 substring('Room:  ' + @roomno + space(28), 1, 28) + space(2)
			+ 	 substring('Co.:  ' + @cus + space(28), 1, 28) + space(2)
			+ 	 substring('Pay:  ' + @paycode + space(28), 1, 28) + space(2)
			+ 	 substring('Arr:  ' + convert(char(8), @arr, 11) + space(28), 1, 28) + space(2)
			+ 	 substring('Dep:  ' + convert(char(8), @dep, 11) + space(28), 1, 28) + space(2)
			+ 	 substring('Rest:  ' + convert(char(12), -1*(@credit+@accredit-@charge)) + space(28), 1, 28) + space(2),
				 ref2 = substring('Pack:  ' + @package + space(28), 1, 28) + space(2)
			+ 	 substring( @lockref + space(28), 1, 28) + space(2)
			+ 	 substring('Srqs:  ' + @srqs + space(28), 1, 28) + space(2)
			+ 	 substring('Limit:  ' + convert(char(12), @limit) + space(28), 1, 28) + space(2)
			+ 	 substring('Sno:  ' + @sno + space(28), 1, 28) + space(2)
			+	 @ref
	else
		select ref1 = substring('姓名:  ' + @name1 + space(28), 1, 28) + space(2)
			+   substring('       '   + @name2 + space(28), 1, 28) + space(2)
			+ 	 substring('房号:  ' + @roomno + space(28), 1, 28) + space(2)
			+ 	 substring('单位:  ' + @cus + space(28), 1, 28) + space(2)
			+ 	 substring('付款:  ' + @paycode + space(28), 1, 28) + space(2)
			+ 	 substring('到日:  ' + convert(char(8), @arr, 11) + space(28), 1, 28) + space(2)
			+ 	 substring('离日:  ' + convert(char(8), @dep, 11) + space(28), 1, 28) + space(2)
			+ 	 substring('余额:  ' + convert(char(12), -1*(@credit+@accredit-@charge)) + space(28), 1, 28) + space(2),
				 ref2 = substring('Pack:  ' + @package + space(28), 1, 28) + space(2)
			+ 	 substring( @lockref + space(28), 1, 28) + space(2)
			+ 	 substring('特殊要求:  ' + @srqs + space(28), 1, 28) + space(2)
			+ 	 substring('信用限额:  ' + convert(char(12), @limit) + space(28), 1, 28) + space(2)
			+ 	 substring('卡号:  ' + @sno + space(28), 1, 28) + space(2)
			+	 @ref

	end
else if upper(@type) = 'FIT' 
	begin
	select @pcrec = ''
	select @roomno = roomno,@haccnt=haccnt,@cusno=cusno,@arr=arr,@dep=dep,@paycode=paycode,@limit=limit,@charge=charge,@credit=credit,@accredit=accredit,@package=packages,@ref=ref,@locksta=substring(extra, 10, 1),@srqs = srqs,@pcrec=pcrec  from master where accnt =@accnt
	if @pcrec >'' 
		select @pcrecamount=sum(charge - credit - accredit) from master where pcrec = @pcrec
	select @name1=name,@name2=name2,@sno = isnull(sno,'') from guest where no=@haccnt
	select @cus=name from guest where no=@cusno
	select @pccodes = ''
	select @pccodes = rtrim(pccodes) from subaccnt where type = '0' and accnt = @accnt
	if @pccodes <>'*' 
		select @pccodes = @pccodes +','
	select  @chgcod = pccode from pos_int_pccode where class ='2' and shift = @shift and pos_pccode = @pccode
	if @pccode <> '' 
		begin
		if @langid = 0 
			if exists	(select 1 from pccode where charindex(@chgcod+',', @pccodes)>0
					or @pccodes = '*'
					or charindex((select deptno1 + '*' from pccode where pccode = @chgcod), @pccodes ) >0 )
				select @lockref ='记帐:  ' +'允许记帐'
			else
				select @lockref ='记帐:  ' +'不允许记帐'
		else
			if exists	(select 1 from pccode where charindex(@chgcod+',', @pccodes)>0
					or @pccodes = '*'
					or charindex((select deptno1 + '*' from pccode where pccode = @chgcod), @pccodes ) >0 )
				select @lockref ='Post Lock:  ' +'Can Posting'
			else
				select @lockref ='Post Lock:  ' +'Can not Posting'
		end
	else
		select @lockref =' '

	if @langid <> 0 
		select ref1 = substring('Name:  ' + @name1 + space(28), 1, 28) + space(2)
			+   substring('       '   + @name2 + space(28), 1, 28) + space(2)
			+ 	 substring('Room:  ' + @roomno + space(28), 1, 28) + space(2)
			+ 	 substring('Co.:  ' + @cus + space(28), 1, 28) + space(2)
			+ 	 substring('Pay:  ' + @paycode + space(28), 1, 28) + space(2)
			+ 	 substring('Arr:  ' + convert(char(8), @arr, 11) + space(28), 1, 28) + space(2)
			+ 	 substring('Dep:  ' + convert(char(8), @dep, 11) + space(28), 1, 28) + space(2)
			+ 	 substring('Rest:  ' + convert(char(10), -1*(@credit-@charge)) + space(28), 1, 28) + space(2)
			+ 	 substring('Link:' + convert(char(10), @pcrecamount) + space(10), 1, 28) + space(2),
				 ref2 = substring('Pack:  ' + @package + space(28), 1, 28) + space(2)
			+ 	 substring(@lockref + space(28), 1, 28) + space(2)
			+ 	 substring('Srqs:  ' + @srqs + space(28), 1, 28) + space(2)
			+ 	 substring('Limit:  ' + convert(char(10), @accredit) + space(28), 1, 28) + space(2)
			+ 	 substring('Sno:  ' + @sno + space(28), 1, 28) + space(2)
			+	 @ref
	else
		select ref1 = substring('姓名:  ' + @name1 + space(28), 1, 28) + space(2)
			+   substring('       '   + @name2 + space(28), 1, 28) + space(2)
			+ 	 substring('房号:  ' + @roomno + space(28), 1, 28) + space(2)
			+ 	 substring('单位:  ' + @cus + space(28), 1, 28) + space(2)
			+ 	 substring('到日:  ' + convert(char(8), @arr, 11) + space(28), 1, 28) + space(2)
			+ 	 substring('离日:  ' + convert(char(8), @dep, 11) + space(28), 1, 28) + space(2)
			+ 	 substring('付款:  ' + @paycode + space(28), 1, 28) + space(2)
			+ 	 substring('余额:  ' + convert(char(10), -1 * (@credit - @charge)) + space(28), 1, 28) + space(2)
			+ 	 substring('联房:' + convert(char(10), @pcrecamount) + space(10), 1, 28) + space(2),
				 ref2 = substring('Pack:  ' + @package + space(28), 1, 28) + space(2)
			+ 	 substring(@lockref + space(28), 1, 28) + space(2)
			+ 	 substring('特殊要求:  ' + @srqs + space(28), 1, 28) + space(2)
			+ 	 substring('信用限额:  ' + convert(char(10), @accredit) + space(28), 1, 28) + space(2)
			+ 	 substring('卡号:  ' + @sno + space(28), 1, 28) + space(2)
			+	 @ref
	end
else if upper(@type) = 'GUEST'
	begin 
	select @roomno = '',@name1=name,@name2=name2,@cus=unit,@sex=sex,@birth=birth,@ident=ident,@mode = code2, @ref2 = rtrim(refer2) +'  ' + rtrim(refer1) from guest  where no =@no
--	select @cus = name from guest where no = @cusno
	if @langid <> 0 
		select @sex = rtrim(descript1) from basecode where cat ='sex' and code = @sex
	else
		select @sex = rtrim(descript) from basecode where cat ='sex' and code = @sex
	if @langid <> 0 
		select ref1 = 'Name:  ' + rtrim(@name1) + space(2) + rtrim(@name2),
				 ref2 =  substring('Sex:  ' + @sex + space(28), 1, 28) + space(2)
			+ 	 substring('Birth:  ' + convert(char(8), @birth, 11) + space(28), 1, 28) + space(2)
			+ 	 substring('IDent:  ' + @ident + space(28), 1, 28) + space(2)
			+ 	 substring('Co.:  ' + @cus + space(28), 1, 28) + space(2)
			+	 @ref2
	else
		select ref1 = '姓名:  ' + rtrim(@name1) + space(2) + rtrim(@name2) ,
				 ref2 =  substring('性别:  ' + @sex + space(28), 1, 28) + space(2)
			+ 	 substring('生日:  ' + convert(char(8), @birth, 11) + space(28), 1, 28) + space(2)
			+ 	 substring('证件:  ' + @ident + space(28), 1, 28) + space(2)
			+ 	 substring('单位:  ' + @cus + space(28), 1, 28) + space(2)
			+	 @ref2
	end
else if upper(@type) = 'COMPANY' 
	begin
	select @roomno = '',@name1=name,@name2=name2,@cusno=cusno,@sex=sex,@birth=birth,@ident=ident,@mode = code2, @ref2 = rtrim(refer2) +'  ' + rtrim(refer1) from guest  where no =@no
	select @modedes = ''
	if @mode <>'' and @langid <> 0  
		select @modedes = name2 from pos_mode_name where code = @mode
	if @mode <>'' and @langid = 0  
		select @modedes = name1 from pos_mode_name where code = @mode
	
	if @langid <> 0 
		select ref1 = 'Name:  ' + rtrim(@name1) + ' ' +  rtrim(@name2) + space(2),
				 ref2 = substring('Mode   '   + substring(@modedes, 1, 20) + space(28), 1, 28) + space(2)
			+	 @ref2
	else
		select ref1 = '名称:  ' + rtrim(@name1) + ' ' +  rtrim(@name2) + space(2),
				 ref2 = substring('模式   '   + substring(@modedes, 1, 20) + space(28), 1, 28) + space(2)
			+	 @ref2
	end
;



