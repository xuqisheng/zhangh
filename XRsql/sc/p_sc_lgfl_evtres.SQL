IF OBJECT_ID('dbo.p_sc_lgfl_evtres') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_sc_lgfl_evtres
    IF OBJECT_ID('dbo.p_sc_lgfl_evtres') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_sc_lgfl_evtres >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_sc_lgfl_evtres >>>'
END
;
SETUSER 'dbo'
;
create proc p_sc_lgfl_evtres
	@no					char(10)
as
-- sc_eventreservationÈÕÖ¾
declare
	@cno					char(10),
	@row					integer,
	@cby					char(10),
	@changed				datetime,
	@logmark				integer,
	@old_evtresno  	char(10),				@new_evtresno		char(10),
   @old_descript1    varchar(50),         @new_descript1    varchar(50),
	@old_descript2		varchar(50),			@new_descript2		varchar(50),--
	@old_eventtype		char(3),    			@new_eventtype		char(3),--
   @old_restype      char(3),             @new_restype      char(3),
   @old_status       char(3),             @new_status       char(3),
   @old_cancelreason char(3),             @new_cancelreason char(3),
   @old_mastersub    char(3),             @new_mastersub    char(3),
   @old_begindate    datetime,            @new_begindate    datetime,
   @old_enddate      datetime,            @new_enddate      datetime,
   @old_space        varchar(100),        @new_space        varchar(100),
   @old_price        money,               @new_price        money,
   @old_fprice       money,               @new_fprice       money,
   @old_discount     money,               @new_discount     money,
   @old_dreason      char(3),             @new_dreason      char(3),
   @old_paymode      char(10),            @new_paymode      char(3),
   @old_fattendees   money,               @new_fattendees   money,                       
   @old_gattendees   money,               @new_gattendees   money,          
   @old_aattendees   money,               @new_aattendees   money,           
   @old_specialrequire varchar(100),      @new_specialrequire varchar(100),            
   @old_noise        char(3),             @new_noise        char(3),          
   @old_noiselimit   char(3),             @new_noiselimit   char(3),           
   @old_share        char(1),             @new_share        char(1),          
   @old_lock         char(1),             @new_lock         char(1),           
   @old_layout       varchar(10),         @new_layout       varchar(10),          
   @old_setuptime    money,               @new_setuptime    money,           
   @old_setdowntime  money,               @new_setdowntime  money,           
   @old_act          char(1),             @new_act          char(1),          
   @old_vip          varchar(100),        @new_vip          varchar(100),          
   @old_emcee        varchar(50),         @new_emcee        varchar(50),           
   @old_note         varchar(255),        @new_note         varchar(255)

--
if @no is null
	declare c_event cursor for select distinct evtresno from sc_eventreservation_log
else
	declare c_event cursor for select distinct evtresno from sc_eventreservation_log where evtresno = @no
--
declare c_log_event cursor for
	select evtresno,descript1,descript2,eventtype,restype,status,cancelreason,mastersub,
          begindate,enddate,space,price,fprice,discount,dreason,paymode,fattendees,gattendees,
          aattendees,specialrequire,noise,noiselimit,sshare,slock,layout,setuptime,setdowntime,act,
          vip,emcee,note,logmark,updatedby,updatedat from sc_eventreservation_log where evtresno = @cno
	union select evtresno,descript1,descript2,eventtype,restype,status,cancelreason,mastersub,
			 begindate,enddate,space,price,fprice,discount,dreason,paymode,fattendees,gattendees,
          aattendees,specialrequire,noise,noiselimit,sshare,slock,layout,setuptime,setdowntime,act,
          vip,emcee,note,logmark,updatedby,updatedat from sc_eventreservation where evtresno = @cno
	order by logmark
open c_event
fetch c_event into @cno
while @@sqlstatus = 0
   begin
	select @row = 0
	open c_log_event
	fetch c_log_event into @new_evtresno,@new_descript1,@new_descript2,@new_eventtype,@new_restype,@new_status,
			@new_cancelreason,@new_mastersub,@new_begindate,@new_enddate,@new_space,@new_price,
			@new_fprice,@new_discount,@new_dreason,@new_paymode,@new_fattendees,@new_gattendees,          
			@new_aattendees,@new_specialrequire,@new_noise,@new_noiselimit,@new_share,@new_lock,           
			@new_layout,@new_setuptime,@new_setdowntime,@new_act,@new_vip,@new_emcee,@new_note,@logmark,@cby,@changed
	while @@sqlstatus =0
		begin
		select @row = @row + 1
		if @row > 1
			begin
			if @new_evtresno	!=@old_evtresno
				insert lgfl values ('e_evtresno', @cno, @old_evtresno, @new_evtresno, @cby, @changed)
			if @new_descript1	!=@old_descript1
				insert lgfl values ('e_descript1', @cno, @old_descript1, @new_descript1, @cby, @changed)
			if @new_descript2	!=@old_descript2
				insert lgfl values ('e_descript2', @cno, @old_descript2, @new_descript2, @cby, @changed)
			if @new_eventtype	!=@old_eventtype
				insert lgfl values ('e_eventtype', @cno, @old_eventtype, @new_eventtype, @cby, @changed)
			if @new_restype	!=@old_restype
				insert lgfl values ('e_restype', @cno, @old_restype, @new_restype, @cby, @changed)
			if @new_status	!=@old_status
				insert lgfl values ('e_status', @cno, @old_status, @new_status, @cby, @changed)
			if @new_cancelreason	!=@old_cancelreason
				insert lgfl values ('e_cancelreason', @cno, @old_cancelreason, @new_cancelreason, @cby, @changed)
			if @new_mastersub	!=@old_mastersub
				insert lgfl values ('e_mastersub', @cno, @old_mastersub, @new_mastersub, @cby, @changed)
			if @new_begindate	!=@old_begindate
				insert lgfl values ('e_begindate', @cno, convert(char(10), @old_begindate, 111) + ' ' + convert(char(10), @old_begindate, 108),
				convert(char(10), @new_begindate, 111) + ' ' + convert(char(10), @new_begindate, 108), @cby, @changed)
			if @new_enddate	!=@old_enddate
            insert lgfl values ('e_enddate', @cno, convert(char(10), @old_enddate, 111) + ' ' + convert(char(10), @old_enddate, 108),
				convert(char(10), @new_enddate, 111) + ' ' + convert(char(10), @new_enddate, 108), @cby, @changed)
			if @new_space	!=@old_space
				insert lgfl values ('e_space', @cno, @old_space, @new_space, @cby, @changed)
			if @new_price	!=@old_price
				insert lgfl values ('e_price', @cno, convert(varchar(10),@old_price), convert(varchar(10),@new_price), @cby, @changed)
			if @new_fprice	!=@old_fprice
				insert lgfl values ('e_fprice', @cno, convert(varchar(10),@old_fprice), convert(varchar(10),@new_fprice), @cby, @changed)
			if @new_discount	!=@old_discount
				insert lgfl values ('e_discount', @cno, convert(varchar(10),@old_discount), convert(varchar(10),@new_discount), @cby, @changed)
			if @new_dreason	!=@old_dreason
				insert lgfl values ('e_dreason', @cno, @old_dreason, @new_dreason, @cby, @changed)
			if @new_paymode	!=@old_paymode
				insert lgfl values ('e_paymode', @cno, @old_paymode, @new_paymode, @cby, @changed)
			if @new_fattendees	!=@old_fattendees
				insert lgfl values ('e_fattendees', @cno, convert(varchar(10),@old_fattendees), convert(varchar(10),@new_fattendees), @cby, @changed)
			if @new_gattendees	!=@old_gattendees
				insert lgfl values ('e_gattendees', @cno, convert(varchar(10),@old_gattendees), convert(varchar(10),@new_gattendees), @cby, @changed)
			if @new_aattendees	!=@old_aattendees
				insert lgfl values ('e_aattendees', @cno, convert(varchar(10),@old_aattendees), convert(varchar(10),@new_aattendees), @cby, @changed)
			if @new_specialrequire	!=@old_specialrequire
				insert lgfl values ('e_specialrequire', @cno, @old_specialrequire, @new_specialrequire, @cby, @changed)
			if @new_noise	!=@old_noise
				insert lgfl values ('e_noise', @cno, @old_noise, @new_noise, @cby, @changed)
			if @new_noiselimit	!=@old_noiselimit
				insert lgfl values ('e_noiselimit', @cno, @old_noiselimit, @new_noiselimit, @cby, @changed)
			if @new_share	!=@old_share
				insert lgfl values ('e_share', @cno, @old_share, @new_share, @cby, @changed)
			if @new_lock	!=@old_lock
				insert lgfl values ('e_lock', @cno, @old_lock, @new_lock, @cby, @changed)
			if @new_layout	!=@old_layout
				insert lgfl values ('e_layout', @cno, @old_layout, @new_layout, @cby, @changed)
			if @new_setuptime	!=@old_setuptime
				insert lgfl values ('e_setuptime', @cno, convert(varchar(10),@old_setuptime), convert(varchar(10),@new_setuptime), @cby, @changed)
			if @new_setdowntime	!=@old_setdowntime
				insert lgfl values ('e_setdowntime', @cno, convert(varchar(10),@old_setdowntime), convert(varchar(10),@new_setdowntime), @cby, @changed)
			if @new_act	!=@old_act
				insert lgfl values ('e_act', @cno, @old_act, @new_act, @cby, @changed)
			if @new_vip	!=@old_vip
				insert lgfl values ('e_vip', @cno, @old_vip, @new_vip, @cby, @changed)
			if @new_emcee	!=@old_emcee
				insert lgfl values ('e_emcee', @cno, @old_emcee, @new_emcee, @cby, @changed)
			if @new_note	!=@old_note
				insert lgfl values ('e_note', @cno, @old_note, @new_note, @cby, @changed)
			end
		select @old_evtresno=@new_evtresno,@old_descript1=@new_descript1,@old_descript2=@new_descript2,
				@old_eventtype=@new_eventtype,@old_restype=@new_restype,@old_status=@new_status,
				@old_cancelreason=@new_cancelreason,@old_mastersub=@new_mastersub,@old_begindate=@new_begindate,
				@old_enddate=@new_enddate,@old_space=@new_space,@old_price=@new_price,@old_fprice=@new_fprice,
				@old_discount=@new_discount,@old_dreason=@new_dreason,@old_paymode=@new_paymode,
				@old_fattendees=@new_fattendees,@old_gattendees=@new_gattendees,@old_aattendees=@new_aattendees,
				@old_specialrequire=@new_specialrequire,@old_noise=@new_noise,@old_noiselimit=@new_noiselimit,
				@old_share=@new_share,@old_lock=@new_lock,@old_layout=@new_layout,@old_setuptime=@new_setuptime,
				@old_setdowntime=@new_setdowntime,@old_act=@new_act,@old_vip=@new_vip,@old_emcee=@new_emcee,
				@old_note=@new_note
		fetch c_log_event into @new_evtresno,@new_descript1,@new_descript2,@new_eventtype,@new_restype,@new_status,
			@new_cancelreason,@new_mastersub,@new_begindate,@new_enddate,@new_space,@new_price,
			@new_fprice,@new_discount,@new_dreason,@new_paymode,@new_fattendees,@new_gattendees,          
			@new_aattendees,@new_specialrequire,@new_noise,@new_noiselimit,@new_share,@new_lock,           
			@new_layout,@new_setuptime,@new_setdowntime,@new_act,@new_vip,@new_emcee,@new_note,@logmark,@cby,@changed
		end
	close c_log_event
	if @row > 0
		delete sc_eventreservation_log where evtresno = @cno and logmark < @logmark
	fetch c_event into @cno
	end
deallocate cursor c_log_event
close c_event
deallocate cursor c_event
;
SETUSER
;
IF OBJECT_ID('dbo.p_sc_lgfl_evtres') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_sc_lgfl_evtres >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_sc_lgfl_evtres >>>'
;
