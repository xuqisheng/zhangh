drop  proc p_hry_phone_calculate_fee;
create proc p_hry_phone_calculate_fee
   @pc_id      char(4) = '1.01',
   @modu_id    char(2) = '05',
   @p_extno    char(10),
   @phcode     char(30),
   @begin_     datetime ,
   @sndnum     integer  output,
	@msg		   varchar(60) output,
	@empno		char(10),
	@shift		char(1),
	@trunk		char(3),
   @type			char(3)='',
	@tag			char(3)  =''
                                                                                                          
as
declare
   @ret int,
   @phcodelen  int,
   @loopndx    int,
   @phcodearea char(30),
   @basesnd    int,
	@stepsnd 	int,
	@grpsnd		int,
	@adjusnd 	int,
   @groupno 	char(2),
   @cgunits    int,
	@ratetail  char(1),
   @start_t    char(5),
	@end_t		char(5),
   @p_holifact money,
   @p_class    char(2),
	@p_srvtail  char(2),
   @toc        char(1),
	@srv 			money,
   @real_rate  money,
   @p_basprec  money,
	@p_feeprec  money,
   @tmp_base   money,
	@fee_base 	money,
   @tmp_fee    money,
	@fee_			money,
   @seg_fee    money,
   @xbrate1    money,
   @timeid     char(2),
   @p_id       char(1),
   @factor     money,
   @duration   int,
   @phvalue      char(21),
   @vlen         int,
   @rate1        money,
   @tt   			integer,
   @x         		integer ,
   @tvalue        char(20) ,
   @svalue       	char(20) ,
   @ttt    			integer,
   @value   		char(20),
   @ppvalue    	char(20),
   @srvalue    	char(20),
   @pgid      		char(30),
   @rgid				char(10),
   @roomid    		char(10),
   @nsflag    		char(1),
   @cutfee    		char(1),
   @ext_fee   		money,
   @adj_rate   	float,
   @serve_rate   	float,
   @min_serve   	money,
   @dial_fee     money,
   @other_fee   money,
	@calltype   char(16)   ,
   @address    char(14)  ,
   @fee        money     ,
   @fee_serve  money  ,
   @time     	char(8),

   @s_fee      money,
   @basefee    money ,
   @afterfee   money ,
   @feestring  char(50) ,
   @valuestring 	char(100) ,
	@descript   	char(30)  ,
  	@longcallid   	integer  ,
  	@logdate 		datetime,
   @extno_tmp   	char(10),
   @bdate      	datetime,
   @lsndnum    	char(8),
  	@pccode  		varchar(5),
   @fee_input  	money

select @fee_input = -1  
if @msg is not null and substring(@msg,1,4)='fee=' 
begin 
	declare	@fpos	int 
	select @fpos = charindex(';', @msg) 
	if @fpos > 0 
	begin 
		select @fee_input = convert(money, substring(@msg, 5, @fpos-5)) 
		if @fee_input is null 
			select @fee_input = -1 
		else if @fee_input<>0 
			begin
			select @fee_input = round(@fee_input / 100,1)	
			end
	end
end
                                                      
select @fee=0,@basefee=0
select @tvalue="",@svalue=""
select @x=0
select @ret=0,@msg=""
select @seg_fee = 0
select @p_extno=rtrim(ltrim(@p_extno))
select @p_basprec=convert(money,value) from sysoption where catalog='phone' and item='basprec'
select @p_feeprec=convert(money,value) from sysoption where catalog='phone' and item='feeprec'

set rowcount 1
select @phcodelen = datalength(rtrim(@phcode)),@loopndx = 1
while @loopndx <= @phcodelen
   begin
   select @phcodearea = code from phcoden where code = substring(@phcode,1,@loopndx)
   if @@rowcount > 0
      begin
	   select @loopndx = @loopndx + 1
	   continue
	   end
   else
      begin
	   if exists (select code from phcoden where code like substring(@phcode,1,@loopndx)+'%')
			begin
		   select @loopndx =@loopndx+1
		   continue
		   end
	   else
         break
      end
   end
set rowcount 0
if @phcodearea is null
   begin
   --select @ret=0,@msg= "NO CODE",@calltype='0',@address='NO ADDRESS',@fee=0, @fee_serve = 0
   --if @returnmode = 'S'
   select @msg='此号码不存在！'
   select @msg
   return 0
   end

--现在表phparms中查找拨出的电话和房间号码，如果存在表中，说明是特殊的计费
select @roomid=extno,@rgid=rgid from phextroom where extno = @p_extno
                 
if not exists(select 1 from phextroom where extno = @p_extno)
   begin
   select @msg='NO ROOM FOUND!替换为‘1001’'
   --select @msg
   select @extno_tmp=@p_extno
   select @roomid='1001'
   select @p_extno='1001'
   select @roomid=extno,@rgid=rgid from phextroom where extno = @p_extno
   end
select @pgid=pgid,@descript=descript from phcoden where code = @phcodearea
                                                 
select @calltype=ltrim(rtrim(@pgid))
   if not exists(select 1 from phcoden where code = @phcodearea)
   begin
   select @msg='NO PHONE NUMBER FOUND!'
   select @msg
   return 0
   end

if exists(select 1 from phparms where pgid = @phcodearea and rgid = @roomid)
   begin
   select @phvalue=pvalue,@srvalue=svalue,@cutfee=cutfee from phparms where pgid=@phcodearea and rgid= @roomid
   --return 11
   end
else if exists(select 1 from phparms where pgid=@phcodearea and rgid=@rgid)
   begin
   select @phvalue=pvalue,@srvalue=svalue,@cutfee=cutfee from phparms where pgid=@phcodearea and rgid= @rgid
--return 22
   end
else if exists(select 1 from phparms where  rgid= @roomid and pgid=@pgid)
   begin
   select @phvalue=pvalue,@srvalue=svalue,@cutfee=cutfee from phparms where pgid= @pgid and rgid= @roomid
--return 33
   end
else
   begin
   select @phvalue=pvalue,@srvalue=svalue,@cutfee=cutfee from phparms where pgid=@pgid and rgid= @rgid
--return 44
   end
if (@phvalue='' or @phvalue=null) or (@srvalue='' or @srvalue=null) or (@cutfee='' or @cutfee=null )
begin
if @phvalue='' or @phvalue=null
   begin
   select @msg=@msg+' '+'此号码电话计费代码未填!'
   end
if @srvalue='' or @srvalue=null
   begin
   select @msg=@msg+' '+'此号码服务计费代码未填!'
   end
if @cutfee='' or @cutfee=null
   begin
   select @msg=@msg+' '+'此号码四舍五入代码未填!'
   end
select @msg
return 0
end



--根据拨出电话号码和拨出的分机号码匹配计费需要的pvalue和svalue
select @phvalue=ltrim(rtrim(@phvalue))+'A'
select @vlen=datalength(ltrim(rtrim(@phvalue))),@loopndx=1

while @loopndx<=@vlen
   begin
   if substring(@phvalue,@loopndx,1)>="A" and substring(@phvalue,@loopndx,1)<="Z"
      begin
      select @rate1=rate1 from phcodeg where id=substring(@phvalue,@loopndx,1)
      if @rate1<>0
         begin
         if (@tvalue ="" or @tvalue=null) and (@svalue ="" or @svalue=null)
 begin
            select @tvalue=ltrim(rtrim(@tvalue))+substring(@phvalue,@loopndx,1)
            select @loopndx=@loopndx+1
            continue
            end
         if (@tvalue <>"" or @tvalue<>null ) and (@svalue =""  or @svalue=null)
      begin
            --调用过程算单次普通计费
            select @nsflag='1'
            select @valuestring=ltrim(rtrim(@valuestring))+"><"+@tvalue
            select @value=@tvalue
            exec p_zk_norfee @pc_id,@modu_id,@value,@begin_,@sndnum
            select @svalue=@value
            exec p_zk_spefee @sndnum,@s_fee output,@svalue,@nsflag,@pc_id,@modu_id
            select @basefee=@basefee+@s_fee
            select @feestring=ltrim(rtrim(@feestring))+'><'+ltrim(rtrim(convert(char,@s_fee)))
            select @x=@x+1
            select @tvalue ="",@svalue =""
            select @tvalue=ltrim(rtrim(@tvalue))+substring(@phvalue,@loopndx,1)
            select @loopndx=@loopndx+1
            continue
            end
         if(@tvalue ="" or @tvalue=null) and @svalue <>""
            begin
             --调用过程算单次特殊计费
            select @nsflag='0'
            exec p_zk_spefee @sndnum,@s_fee output,@svalue,@nsflag,@pc_id,@modu_id
            select @basefee=@basefee+@s_fee
            select @feestring=ltrim(rtrim(@feestring))+'><'+ltrim(rtrim(convert(char,@s_fee)))
            select @valuestring=ltrim(rtrim(@valuestring))+"><"+@svalue
            select @x=@x+1
            select @tvalue="",@svalue=""
        select @tvalue=ltrim(rtrim(@tvalue))+substring(@phvalue,@loopndx,1)
            select @loopndx=@loopndx+1
            continue
           end
        end
      if @rate1=0
         begin
         if (@tvalue ="" or @tvalue=null) and (@svalue ="" or @svalue=null)
            begin
            select @tvalue=ltrim(rtrim(@tvalue))+substring(@phvalue,@loopndx,1)
            select @loopndx=@loopndx+1
            continue
            end
         if @tvalue <>"" and (@svalue ="" or @svalue=null)
            begin
            --调用过程算单次普通计费
            select @nsflag='1'
            select @valuestring=ltrim(rtrim(@valuestring))+"><"+@tvalue
            select @value=@tvalue
            exec p_zk_norfee @pc_id,@modu_id,@value,@begin_,@sndnum
            select @svalue=@value
            exec p_zk_spefee @sndnum,@s_fee output,@svalue,@nsflag,@pc_id,@modu_id
            select @basefee=@basefee+@s_fee
            select @feestring=ltrim(rtrim(@feestring))+'><'+ltrim(rtrim(convert(char,@s_fee)))
            select @x=@x+1
            select @tvalue="",@svalue=""
            select @tvalue=ltrim(rtrim(@tvalue))+substring(@phvalue,@loopndx,1)
            select @loopndx=@loopndx+1
            continue
            end
         if (@tvalue ="" or @tvalue=null) and @svalue <>""
            begin
            select @tt=endtime,@ttt=begintime from phcodeg where id=substring(@phvalue,@loopndx-1,1)
            if @tt=99999 and @ttt<>0
               begin
  --调用过程算单次特殊计费
               select @nsflag='0'
               exec p_zk_spefee @sndnum,@s_fee output,@svalue,@nsflag,@pc_id,@modu_id
               select @basefee=@basefee+@s_fee
               select @feestring=ltrim(rtrim(@feestring))+'><'+ltrim(rtrim(convert(char,@s_fee)))
               select @valuestring=ltrim(rtrim(@valuestring))+"><"+@svalue
               select @x=@x+1
               select @tvalue="",@svalue=""
               select @tvalue=ltrim(rtrim(@tvalue))+substring(@phvalue,@loopndx,1)
               select @loopndx=@loopndx+1
               continue
               end
            select @tvalue=ltrim(rtrim(@tvalue))+substring(@phvalue,@loopndx,1)
            select @loopndx=@loopndx+1
            continue
           end
         end
      end
   if substring(@phvalue,@loopndx,1)>="a" and substring(@phvalue,@loopndx,1)<="z"
      begin
      if @loopndx=1 or (@tvalue ="" or @tvalue=null)
        begin
        select @msg="计费部分代码错误！请重新设置！"
        select @msg
        return 0
      end
      if @tvalue <>"" and (@svalue ="" or @svalue=null)
         begin
         select @tvalue=ltrim(rtrim(@tvalue))+substring(@phvalue,@loopndx,1)
         select @loopndx=@loopndx+1
         continue
         end
      end
     select @loopndx=@loopndx+1
  end

--服务费的收取
select @ext_fee=ext_fee,@adj_rate=adj_rate,@serve_rate=serve_rate,@min_serve=min_serve,@dial_fee=dial_fee,@other_fee=other_fee from phsvcset where fid=@srvalue
select @fee=@ext_fee+@basefee*@adj_rate*(1+@serve_rate)+@dial_fee+@other_fee
select @fee_serve=@fee-@basefee
if @min_serve>@fee_serve
   select @fee_serve=@min_serve
select @fee=@basefee+@fee_serve


--四舍五入部分,为了不增加多余的变量，就不采用循环来做了
select @cutfee=ltrim(rtrim(@cutfee))

if @cutfee='0'
   select @afterfee=round(@fee,2)
else if @cutfee='1'
   begin
   if @fee=floor(@fee/0.1)*0.1
      begin
      select @afterfee=floor(@fee/0.1)*0.1
      end
   else
      select @afterfee=(floor(@fee/0.1)+1)*0.1
   end
else if @cutfee='2'
   select @afterfee=floor(@fee/0.1)*0.1
else if @cutfee='3'
   select @afterfee=round(@fee,1)
else if @cutfee='4'
   begin
   if @fee=floor(@fee/1)
      begin
      select @afterfee=floor(@fee/1)
      end
   else
      select @afterfee=floor(@fee)+1
   end
else if @cutfee='5'
   select @afterfee=floor(@fee)
else if @cutfee='6'
   select @afterfee=round(@fee,0)
else if @cutfee='7'
   begin
   if @fee=floor(@fee/10)
      begin
      select @afterfee=floor(@fee/10)
      end
   else
      select @afterfee=(floor(@fee/10)+1)*10
   end
else if @cutfee='8'
   select @afterfee=(floor(@fee/10))*10

--if @p_feeprec=0.01
   --select @tt=2
--else if @p_feeprec=0.1
  -- select @tt=1
--else if @p_feeprec=1
 --  select @tt=0
--else if @p_feeprec=10
  -- select @tt=-1
--if @cutfee='0'
   --select @afterfee=round(@fee,@tt)
--else if @cutfee='1'
   --select @afterfee=floor(@fee/@p_feeprec)*@p_feeprec
--else if @cutfee='2'
  -- begin
  -- if floor(@fee/@p_feeprec)<@fee/@p_feeprec
   --   select @afterfee=floor(@fee/@p_feeprec+1)*@p_feeprec
  -- else
     -- select @afterfee=@fee/@p_feeprec
  -- end

--select @valuestring=@msg
select @feestring=ltrim(rtrim(substring(@feestring,2,datalength(ltrim(rtrim(@feestring))))))+'>'
select @valuestring=ltrim(rtrim(substring(@valuestring,2,datalength(ltrim(rtrim(@valuestring))))))+'>'

--插入表以备查询
select @longcallid=max(inumber) from  phfolio
select @longcallid=1+@longcallid
if not exists (select 1 from  phfolio)
   select @longcallid=1
select @logdate=getdate()
--把房间号码改回实际拨打的分机号码
if @extno_tmp<>'' and @extno_tmp<>null
   select @p_extno=@extno_tmp
--sndnum转time格式
--exec p_hry_phone_snd_time @sndnum,@time output
select @bdate=bdate from sysdata

-- 直接采用传入的计费价格 2009.8 rainbow 
if @fee_input >=0 
	select @basefee=@fee_input,@fee_serve=0,@fee=@fee_input,@afterfee=@fee_input

if exists(select 1 from bos_extno where code = @p_extno)   -- and (substring(@msg, 1, 7) <> 'NO CODE' and substring(@msg, 1, 7) <> 'NOCLASS')
	begin
   select @lsndnum=convert(char,@sndnum)
	exec @ret = p_gds_phone_pccode @p_extno, 'BS', @phcode, @calltype, @pccode output
	exec @ret = p_hry_bus_put_iddcall
		'06', @pc_id, @shift, @empno, @p_extno, @pccode, @phcode, @address, @begin_,
		@lsndnum, @basefee, @fee_serve, @phcode, 'R', @msg output   --@fee_base
	end

insert into phfolio values(@logdate,@longcallid,@phcode,@descript,@begin_,@x,@valuestring,@feestring,@basefee,@fee_serve,@fee,@afterfee,@calltype,@p_extno,@sndnum,@srvalue,@empno,'EMPTY',@shift,@trunk,@type,@tag,@afterfee,@bdate)
return 1
/* ### DEFNCOPY: END OF DEFINITION */
;
