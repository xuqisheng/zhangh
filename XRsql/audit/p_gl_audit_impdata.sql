/*ͳ�ƿͷ���ҪӪҵָ��ΪӪҵ�ձ���׼�����ݣ�����yaudit_impdataΪ���º����������׼��*/
/*
  1.�ͷ���
				ttl			�ܷ���
				ooo			ά�޷�
				os				������
            mnt         ά��������
				avl			���÷���
				sold			�۷���
				sold%			������
				vac			�շ���
				htl			���÷���
				free			��ѷ�
				longstay		������  --???
  2.����
				-----------------------
				income		�ܷ�������
				incomef		ɢ������
				incomeg		�Ŷ�����
				incomec		��������
				incomel		��������
				svc			���������
				incm_n		��������-�������
				incm_nn		������
            intotal		�ڵ����������
            total       �Ƶ�������
				back_income_rm	��ͷ�ͷ�������
				back_income_ot	��ͷ����������
				back_rmnum		��ͷ�ͷ���
  3.�۷���
				------------------------
				soldf			ɢ���۷���
				soldg			�Ŷ��۷���
				soldc			�����۷���
				soldl			�����۷���
				sold_ou		�������
				sold_in		�ڱ�����
				
   4.����
				------------------------
				gst			�ܹ�ҹ����
				gstf			ɢ�͹�ҹ����
				gstg			�Ŷӹ�ҹ����
				gstc			�����ҹ����
				gstl			������ҹ����
				ch_gstf		���ڹ�ҹɢ������  
				ch_gstg		���ڹ�ҹ�Ŷ�����  
				fo_gstf		�����ҹɢ������  
				fo_gstg		�����ҹ�Ŷ�����  
				in_gstno		���ڹ�ҹ����
				ou_gstno		�����ҹ����
				mffrs			���÷�����
				zyfrs			��ѷ�����
    5.����
				-------------------------
				exp_arr		Ԥ�Ƶִ�        
				act_arr		����ʵ�ʵ���
				sdp			����Ԥ������
				noshow		Ԥ��δ��
				cancel		Ԥ��ȡ��        
				walkin		����ɢ��
            stay_ove    ���յ����ҹ
            rtngst      ��ͷ��
				-------------------------
				exp_dep		Ԥ�����        
				act_dep		����ʵ�����
				extnd_rm		��ס������
				e-co			��ǰ���       
				-------------------------
				d_chkin		˫�˷�������
				addbed		�Ӵ���         
				crib			Ӥ������        
				bf_gst		���������
				bf_amt		����ͽ��
				all_days    ���ڵ�����
				adv_day%		ƽ��ס������
				group			��ҹ�Ŷ���		 
				dayuse		���յ���       
				pre_booking	���쵽(��ǰԤ��)
				cur_booking	���쵽(����Ԥ��)
				
*/

IF OBJECT_ID('dbo.p_gl_audit_impdata') IS NOT NULL
    DROP PROCEDURE dbo.p_gl_audit_impdata
;
create proc p_gl_audit_impdata
as
declare
	@duringaudit	char(1),
	@isfstday		char(1),
	@isyfstday		char(1),
	@bdate			datetime,
	@bfdate			datetime,
	@badate			datetime,
	@reslt			money,
	@reslt1			money,
	@reslt2			money,
  	@cdate			char(6),     -- 040501
    @date_           datetime

select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
select @bfdate = dateadd(day, -1, @bdate)
select @badate = dateadd(day, 1, @bdate)
if exists ( select 1 from audit_impdata where date = @bdate )
	update audit_impdata set amount_m = amount_m - amount,amount_y = amount_y - amount
update audit_impdata set amount = 0, date = @bfdate
update audit_impdata set date = rmsalerep_new.date from rmsalerep_new where gkey='f' and hall='{' and code='{{{'
select @cdate = convert(char(6), @bdate, 12)

-----------------------------------------------------------------------------------------
-- �ͷ�����ָ��
--����Ԥ������ݣ������ܴ�rsv_indexȡ������Ϊ�ڶ��첻���ؽ�
-----------------------------------------------------------------------------------------
--ttl			�ܷ���
update audit_impdata set amount = isnull(ttl,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{'  and audit_impdata.class='ttl'
--ooo			ά�޷�
select @reslt1=isnull(mnt,0) from rmsalerep_new where gkey='f' and hall='{' and code='{{{'
update audit_impdata set amount = @reslt1 where class='ooo'
--oos			������
select @reslt2=isnull(os,0) from rmsalerep_new where gkey='f' and hall='{' and code='{{{'
update audit_impdata set amount = @reslt2 where class='oos'
--mnt         ά��������
update audit_impdata set amount = (select   amount from audit_impdata where class='ooo')+(select   amount from audit_impdata where class='oos') where class='mnt'
--clean	�ɾ���
select @reslt = isnull((select count(roomno) from rmsta_till where charindex(sta,'RI')>0 and tag<>'P'), 0)
update audit_impdata set amount = @reslt where class = 'clean'
--dirty	�෿
select @reslt = isnull((select count(roomno) from rmsta_till where charindex(sta,'DTOS')>0 and tag<>'P'), 0)
update audit_impdata set amount = @reslt where class = 'dirty'
--ttl_o
update audit_impdata set amount= (select isnull(amount,0) from audit_impdata where class='ttl') - (select isnull(amount,0) from audit_impdata where class='ooo') where class='ttl_o'
--avl			���÷���(��os)
update audit_impdata set amount = isnull(avl,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='avl'
--avlo         ���÷�(��oo��os)
update audit_impdata set amount = (select   amount from audit_impdata where class='ooo')+(select   amount from audit_impdata where class='avl') where class='avlo'

--sold			�۷���
update audit_impdata set amount = isnull(soldf + soldg + soldc+ soldl,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='sold'
--sold%			������(�µĳ�����Ӧ�÷��������㡣��Ϊǰ��_m��_y��û���ۼӡ�)
update audit_impdata set amount  = 100*(select   amount from audit_impdata where class='sold')/(select   amount from audit_impdata where class='avl')
						where class = 'sold%' and (select   amount from audit_impdata where class='avl')<>0
--       �Ӵ�
update audit_impdata set amount = isnull(ext,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='ext_no'

--vac			�շ���
update audit_impdata set amount = isnull(vac,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='vac'
--htl			���÷���
select @reslt = isnull((select count(distinct a.roomno) from master_till a, mktcode b
	where a.class='F' and a.sta='I' and a.market=b.code and b.flag='HSE' ), 0)
update audit_impdata set amount = @reslt where class='htl'
--free			��ѷ�
update audit_impdata set amount = isnull(ent,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class = 'free'
--longstay		������

--OCC			=SOLD + HU
update audit_impdata set amount = isnull(soldf + soldg + soldc+ soldl,0)+(select isnull(amount,0) from audit_impdata where class='htl') from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='occ'
--occ_ch			�۷��������������
update audit_impdata set amount  = (select isnull(amount,0) from audit_impdata where class='occ') - (select isnull(amount,0) from audit_impdata where class='free') - (select isnull(amount,0) from audit_impdata where class='htl')
						where class = 'occ_ch'
--occ_h			�۷�����������
update audit_impdata set amount  = (select isnull(amount,0) from audit_impdata where class='occ') - (select isnull(amount,0) from audit_impdata where class='htl')
						where class = 'occ_h'
--occ_c			�۷����������
update audit_impdata set amount  = (select isnull(amount,0) from audit_impdata where class='occ') - (select isnull(amount,0) from audit_impdata where class='free')
						where class = 'occ_c'
--avl+h			���÷�+���÷� --����ϵͳavlָ��Ͳ�����ά�޷������÷�
update audit_impdata set amount  = (select amount from audit_impdata where class='avl') + (select amount from audit_impdata where class='htl')
						where class = 'avl+h'
--rmtosel   ������
update audit_impdata set amount = (select   amount from audit_impdata where class='ttl')-(select   amount from audit_impdata where class='occ') where class='rmtosel'
--rtosl_o  ����������ά��
update audit_impdata set amount = (select   amount from audit_impdata where class='rmtosel')-(select   amount from audit_impdata where class='ooo') where class='rtosl_o'




-----------------------------------------------------------------------------------------
--���г�����ͳ�Ƴ�����
-----------------------------------------------------------------------------------------
--bi

-----------------------------------------------------------------------------------------
--	�ͷ����� : ����ָ��
-----------------------------------------------------------------------------------------
--back_income_rm		��ͷ�ͷ���
select @reslt = isnull(sum(a.xf_rm),0) from cus_xf a,guest b where a.sta = 'I' and accnt like 'F%' and a.haccnt = b.no and b.i_times > 0
update audit_impdata set amount = @reslt where class='back_income_rm'
--back_income_ot		��ͷ��������
select @reslt = isnull(sum(a.xf_dtl - a.xf_rm),0) from cus_xf a,guest b where a.sta = 'I' and  accnt like 'F%' and a.haccnt = b.no and b.i_times > 0
update audit_impdata set amount = @reslt where class='back_income_ot'
--back_rmnum			��ͷ�ͷ���
select @reslt = isnull(sum(a.quantity),0) from rmuserate a,guest b,master c where b.no = c.haccnt and a.master = c.accnt and b.i_times > 0 and date = @bdate //and c.sta = 'I'
update audit_impdata set amount = @reslt where class='back_rmnum'
--back_gstno			��ͷ������
select @reslt = isnull(sum(a.gstno*a.i_days),0) from cus_xf a,guest b where a.sta = 'I' and  b.no = a.haccnt and accnt like 'F%' and b.i_times > 0
update audit_impdata set amount = @reslt where class='back_gstno'
--income		�ܷ�������
--select @reslt =isnull(sum(a.charge),0) from  gltemp a, pccode b
--	where a.pccode = b.pccode and b.deptno='10' and a.pccode < '9' and (a.crradjt in ('AD', '') or (a.crradjt in ('LT', 'LA') and a.tofrom= ''))
update audit_impdata set amount = isnull(incomef+incomeg+incomec+incomel,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='income'
--incomef	ɢ������
update audit_impdata set amount = isnull(incomef,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='incomef'
--incomeg	�Ŷ�����
update audit_impdata set amount = isnull(incomeg,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='incomeg'
--incomec	��������
update audit_impdata set amount = isnull(incomec,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='incomec'
--incomel	��������
update audit_impdata set amount = isnull(incomel,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='incomel'
--svc	���������
update audit_impdata set amount = isnull((select sum(a.day06) from jierep a where a.class='010'),0) where class='svc'
-- �������
update audit_impdata set amount = isnull((select sum(a.quantity) from package_detail a, package b
		where datediff(dd,@bdate,a.bdate)=0 and a.tag < '5' and a.code = b.code and b.type = '1'),0) where class='bf_gstno'
-- bf_amt ��ͽ��
update audit_impdata set amount = isnull((select sum(a.quantity*b.amount) from package_detail a, package b
		where datediff(dd,@bdate,a.bdate)=0 and a.tag < '5' and a.code = b.code and b.type = '1'),0) where class='bf_amt'
--incm_n	  ��������-�������
select @reslt = isnull((select sum(amount) from audit_impdata where class = 'income'), 0)
select @reslt = @reslt - isnull((select sum(amount) from audit_impdata where class = 'svc'), 0)
update audit_impdata set amount = @reslt where class='incm_n'
--incm_nn	������
select @reslt = @reslt - isnull((select sum(amount) from audit_impdata where class = 'bf_amt'), 0)
update audit_impdata set amount = @reslt where class='incm_nn'
--intotal	�ڵ����������
update audit_impdata set amount =isnull((select sum(b.charge) from gltemp b where b.bdate=@bdate),0)
      				where class='intotal'
--fbrev	��������
select @reslt =isnull(day99,0) from  jierep	where class='020'
update audit_impdata set amount =@reslt where class='fbrev'
--otrev	��������
select @reslt =isnull(day99,0) from  jierep	where class='030'
update audit_impdata set amount =@reslt where class='otrev'
--total	�Ƶ�������
update audit_impdata set amount = (select   amount from audit_impdata where class='income')+(select   amount from audit_impdata where class='fbrev')+
                  (select   amount from audit_impdata where class='otrev')  where class='total'
--select @reslt = sum(tincome) from mktsummaryrep where class='M'
--update audit_impdata set amount = @reslt where class='total'
--fbgstno �ò�����
update audit_impdata set amount = isnull((select sum(feed) from deptjie where code = '99A'  AND empno ='{{{' and  shift ='9'  and pccode like '3%' ),0)
 where class = 'fbgstno'
--inrev
--select @reslt = sum(tincome) from mktsummaryrep where class='M' and grp='IND'
select @reslt = isnull(sum(tincome),0) from mktsummaryrep where class='M' and grp='IND'
update audit_impdata set amount = @reslt where class='inrev'
--memrev ?��������������
--select @reslt = sum(tincome) from mktsummaryrep where class='M' and grp<>'IND'
select @reslt = isnull(sum(tincome),0) from mktsummaryrep where class='M' and grp='GRP'
update audit_impdata set amount = @reslt where class='memrev'
select @reslt = isnull(sum(tincome),0) from mktsummaryrep where class='M' and grp='MET'
update audit_impdata set amount = @reslt where class='meetrev'

-----------------------------------------------------------------------------------------
-- �ͷ����� - �ͷ�����ָ��
-----------------------------------------------------------------------------------------
--soldf			ɢ���۷���
update audit_impdata set amount = isnull(soldf,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='soldf'
--soldg			�Ŷ��۷���
update audit_impdata set amount = isnull(soldg,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='soldg'
--soldc			�����۷���
update audit_impdata set amount = isnull(soldc,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='soldc'
--soldl			�����۷���
update audit_impdata set amount = isnull(soldl,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='soldl'
--sold_ou		�������
update audit_impdata set amount = isnull((select count(distinct a.roomno) from master_till a,guest b,countrycode c, mktcode d
       				where a.haccnt=b.no and a.class='F' and a.sta = 'I' and a.market=d.code and d.flag <> 'HSE' and b.nation = c.code and (c.flag1 is null or c.flag1 <> 'CN')), 0)
		 				where class='sold_ou'
--sold_in		�ڱ�����
update audit_impdata set amount = isnull((select count(distinct a.roomno) from master_till a,guest b,countrycode c, mktcode d
       				where a.haccnt=b.no and a.class='F' and a.sta = 'I' and a.market=d.code and d.flag <> 'HSE' and b.nation = c.code and c.flag1 = 'CN'), 0)
		 				where class='sold_in'

--t_soldf
select @reslt = isnull(count(distinct roomno),0) from master_till where class='F' and groupno='' and sta='I'
update audit_impdata set amount = @reslt where class='t_soldf'

--t_soldg
select @reslt = isnull(count(distinct roomno),0) from master_till where class='F' and groupno<>'' and sta='I'
update audit_impdata set amount = @reslt where class='t_soldg'

--sold_fit
update audit_impdata set amount= (select amount from audit_impdata where class='soldf') + (select amount from audit_impdata where class='soldl') where class='sold_fit'

--sold_mem
update audit_impdata set amount= (select amount from audit_impdata where class='soldg') + (select amount from audit_impdata where class='soldc') where class='sold_mem'

--sold_cus
select @reslt = isnull(count(distinct roomno),0) from master_till where class='F' and cusno<>'' and sta='I'
update audit_impdata set amount = @reslt where class='sold_cus'

--sold_agt
select @reslt = isnull(count(distinct roomno),0) from master_till where class='F' and agent<>'' and sta='I'
update audit_impdata set amount = @reslt where class='sold_agt'

--sold_src
select @reslt = isnull(count(distinct roomno),0) from master_till where class='F' and source<>'' and sta='I'
update audit_impdata set amount = @reslt where class='sold_src'

--sold_bf                ����ɢ�ʹ��� 010010
select @reslt = isnull((select sum(rquan) from ymktsummaryrep where date = @bdate and class ='M' and code in ('RAC','RAD','PRO')),0)
update audit_impdata set amount = @reslt where class = 'sold_bf'


--sold_lf                ��˾ɢ�� 010011
select @reslt = isnull((select sum(rquan) from ymktsummaryrep where date = @bdate and class ='M' and code in ('NOC','COC','COR','KEY','MAJ','NON')),0)
update audit_impdata set amount = @reslt where class = 'sold_lf'

--sold_bg                ����ʹ��ɢ�� 010012
select @reslt = isnull((select sum(rquan) from ymktsummaryrep where date = @bdate and class ='M' and code in ('GVC','GVP','GVD','GVT','EMB')),0)
update audit_impdata set amount = @reslt where class = 'sold_bg'

--sold_lg                �������� 010013
select @reslt = isnull((select sum(rquan) from ymktsummaryrep where date = @bdate and class ='M' and code in ('CTI','BTG','BJG')),0)
update audit_impdata set amount = @reslt where class = 'sold_lg'

--sold_gd                 GDS 010014
select @reslt = isnull((select sum(rquan) from ymktsummaryrep where date = @bdate and class ='M' and code in ('GDS')),0)
update audit_impdata set amount = @reslt where class = 'sold_gd'

--sold_sc                 ������ɢ�� 010015
select @reslt = isnull((select sum(rquan) from ymktsummaryrep where date = @bdate and class ='M' and code in ('WHO')),0)
update audit_impdata set amount = @reslt where class = 'sold_sc'

--sold_hw                 ���綩�� 010016
select @reslt = isnull((select sum(rquan) from ymktsummaryrep where date = @bdate and class ='M' and code in ('WEB')),0)
update audit_impdata set amount = @reslt where class = 'sold_hw'

--sold_ls                 ������/�칫 010017
select @reslt = isnull((select sum(rquan) from ymktsummaryrep where date = @bdate and class ='M' and code in ('LTR','LTO')),0)
update audit_impdata set amount = @reslt where class = 'sold_ls'


--sold_io                 ����ɢ�� 010018
select @reslt = isnull((select sum(rquan) from ymktsummaryrep where date = @bdate and class ='M' and code in ('MEM','HTL','MGR','AIR','INI','PER')),0)
update audit_impdata set amount = @reslt where class = 'sold_io'

--sold_be                 ��˾������ 010019
select @reslt = isnull((select sum(rquan) from ymktsummaryrep where date = @bdate and class ='M' and code in ('EXH','GPM','GPC')),0)
update audit_impdata set amount = @reslt where class = 'sold_be'

--sold_se                 ϵ���� 010021
select @reslt = isnull((select sum(rquan) from ymktsummaryrep where date = @bdate and class ='M' and code in ('GPS')),0)
update audit_impdata set amount = @reslt where class = 'sold_se'

--sold_ot                 ��ɢ�� 010022
select @reslt = isnull((select sum(rquan) from ymktsummaryrep where date = @bdate and class ='M' and code in ('GPO','GPD')),0)
update audit_impdata set amount = @reslt where class = 'sold_ot'

--sold_go                �Ŷ����� 010023
select @reslt = isnull((select sum(rquan) from ymktsummaryrep where date = @bdate and class ='M' and code in ('GPE','GPA','GPL','GPG','GPB','GPJ','GPH')),0)
update audit_impdata set amount = @reslt where class = 'sold_go'


-----------------------------------------------------------------------------------------
-- �ͷ����� - ��������ָ��
-----------------------------------------------------------------------------------------
--gst				�ܹ�ҹ����
update audit_impdata set amount = isnull(gstf + gstg + gstc + gstl,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='gst'
--gstf			ɢ�͹�ҹ����
update audit_impdata set amount = isnull(gstf,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='gstf'
--gstg			�Ŷӹ�ҹ����
update audit_impdata set amount = isnull(gstg,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='gstg'
--gstc			�����ҹ����
update audit_impdata set amount = isnull(gstc,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='gstc'
--gstl			������ҹ����
update audit_impdata set amount = isnull(gstl,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='gstl'

--gst_fit
update audit_impdata set amount= (select amount from audit_impdata where class='gstf') + (select amount from audit_impdata where class='gstl') where class='gst_fit'
--gst_mem
update audit_impdata set amount= (select amount from audit_impdata where class='gstg') + (select amount from audit_impdata where class='gstc') where class='gst_mem'

--ס���������������
select @reslt=isnull(sum(a.gstno),0) from master_till a,mktcode b where a.sta = 'I' and a.class = 'F' and a.market=b.code and b.flag<>'HSE'
update audit_impdata set amount = @reslt where class='adltih'
--ס��С����
select @reslt=isnull(sum(a.children),0) from master_till a,mktcode b where a.sta = 'I' and a.class = 'F' and a.market=b.code and b.flag<>'HSE'
update audit_impdata set amount = @reslt where class='chldih'
--gstih
update audit_impdata set amount= (select amount from audit_impdata where class='adltih') + (select amount from audit_impdata where class='chldih') where class='gstih'
--VIPס������
select @reslt=isnull(sum(a.gstno),0) from master_till a,guest b where a.haccnt=b.no and b.vip<>'0' and a.sta = 'I' and a.class = 'F'
update audit_impdata set amount = @reslt where class='vipih'
--memih
select @reslt=isnull(count(1),0) from master_till where cardno<>'' and sta = 'I' and class = 'F'
update audit_impdata set amount = @reslt where class='memih'
--birth
select @reslt=isnull(count(1),0) from master_till a,guest b where a.sta = 'I' and a.class = 'F' and a.haccnt=b.no and datepart(mm,b.birth)=datepart(mm,@bdate) and datepart(dd,b.birth)=datepart(dd,@bdate)
update audit_impdata set amount = @reslt where class='birth'

--ch_gstf		���ڹ�ҹɢ������
update audit_impdata set amount = isnull((select sum(a.gstno) from master_till a,countrycode b,guest c
						where a.sta = 'I' and a.class = 'F' and a.haccnt= c.no and rtrim(a.groupno) is null and b.code = c.nation and b.flag1 = 'CN'),0 )
						where class='ch_gstf'
--ch_gstg		���ڹ�ҹ�Ŷ�����
update audit_impdata set amount = isnull((select sum(a.gstno) from master_till a,countrycode b,guest c
						where a.sta = 'I' and a.class in ('G','M') and a.haccnt= c.no and rtrim(a.groupno) is not null and b.code = c.nation and b.flag1= 'CN'),0 )
  						where class='ch_gstg'
--fo_gstf		�����ҹɢ������
update audit_impdata set amount = isnull((select sum(a.gstno) from master_till a,countrycode b,guest c
						where a.sta = 'I' and a.class = 'F' and a.haccnt= c.no and rtrim(a.groupno) is null and b.code = c.nation and (b.flag1 is null or b.flag1 <> 'CN')),0 )
						where class='fo_gstf'
--fo_gstg		�����ҹ�Ŷ�����
update audit_impdata set amount = isnull((select sum(a.gstno) from master_till a,countrycode b,guest c
						where a.sta = 'I' and a.class in ('G','M') and a.haccnt= c.no and rtrim(a.groupno) is not null and b.code = c.nation and (b.flag1 is null or b.flag1 <> 'CN')),0 )
						where class='fo_gstg'

--in_gstno		���ڹ�ҹ����
update audit_impdata set amount = isnull((select sum(a.gstno) from master_till a,countrycode b,guest c
			where a.sta = 'I' and a.class = 'F' and a.haccnt= c.no and b.code = c.nation and b.flag1 = 'CN'),0 ) where class = 'in_gstno'
--ou_gstno		�����ҹ����
update audit_impdata set amount = isnull((select sum(a.gstno) from master_till a,countrycode b,guest c
			where a.sta = 'I' and a.class = 'F' and a.haccnt= c.no and b.code = c.nation and (b.flag1 is null or b.flag1 <> 'CN')),0 ) where class = 'ou_gstno'

--mffrs
update audit_impdata set amount = isnull((select sum(gstno) from cus_xf where sta = 'I' and accnt like 'F%' and
			rtrim(market) in (select rtrim(code) from mktcode where rtrim(flag) = 'COM' ) ),0 ) where rtrim(class) = 'mffrs'
--zyfrs
update audit_impdata set amount = isnull((select sum(gstno) from cus_xf where sta = 'I' and accnt like 'F%' and
			rtrim(market) in (select rtrim(code) from mktcode where rtrim(flag) = 'HSE' ) ),0 ) where rtrim(class) = 'zyfrs'

-----------------------------------------------------------------------------------------
--	����ָ��
-----------------------------------------------------------------------------------------
--exp_arr	   Ԥ�Ƶִ�
select @reslt = isnull((select sum(quantity) from rsvsrc_last where begin_=@bdate and begin_<>end_ and roomno=''),0)
select @reslt = @reslt + (select count(distinct a.roomno) from rsvsrc_last a, master_last b
		where a.accnt=b.accnt and b.sta='R' and a.begin_=@bdate and a.begin_<>a.end_ and a.roomno<>'')
update audit_impdata set amount = @reslt	where class='exp_arr'

--	act_arr		����ʵ�ʵ���
select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and sta in ('I') and bdate=@bdate and arr>=@bdate), 0)
select @reslt = @reslt + isnull((select count(distinct a.roomno) from master_till a where a.class='F' and a.sta in ('S','O') and a.bdate=@bdate
											and not exists(select 1 from master_last b where a.accnt=b.accnt and b.sta='I')), 0)
update audit_impdata set amount = @reslt where class = 'act_arr'

--	sdp			����Ԥ������
select @reslt = isnull((select count(distinct a.roomno) from master_till a
	where a.class='F' and a.sta in ('I','S','O') and a.bdate=@bdate and substring(extra,9,1)<>'1'
		and a.resno like @cdate+'%'), 0)
update audit_impdata set amount = @reslt where class = 'sdp'

--noshow		Ԥ��δ��
-- select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and sta='N' and bdate=@bdate), 0)
select @reslt = isnull((select count(distinct roomno) from master where class='F' and sta='N' and bdate=@bdate and roomno<>''), 0)
select @reslt = @reslt + isnull((select sum(rmnum) from master where class='F' and sta='N' and bdate=@bdate and roomno=''), 0)
update audit_impdata set amount= @reslt where class = 'noshow'

--cancel		Ԥ��ȡ��
select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and sta='X' and bdate=@bdate and roomno<>''), 0)
select @reslt = @reslt+isnull((select sum(rmnum) from master_till where class='F' and sta='X' and bdate=@bdate and roomno=''), 0)
update audit_impdata set amount = @reslt where class = 'cancel'

--walkin		����ɢ��  -- ���յ��� !
select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and substring(extra,9,1)='1' and sta in ('I') and bdate=@bdate), 0)
select @reslt = @reslt + isnull((select count(distinct a.roomno) from master_till a where a.class='F' and substring(extra,9,1)='1' and a.sta in ('S','O') and a.bdate=@bdate
											and not exists(select 1 from master_last b where a.accnt=b.accnt)), 0)
update audit_impdata set amount = @reslt where class = 'walkin'

--stay_ove  ���յ����ҹ
update audit_impdata set amount = isnull((select count(distinct a.roomno) from master_till a
						where a.class='F' and a.sta in ('I') and datediff(dd,a.bdate,@bdate) >= 1 ),0 )
						where class='stay_ove'

--rtngst    ��ͷ��
update audit_impdata set amount = isnull((select count(distinct a.roomno) from master_till a,guest b
						where a.class='F' and a.sta in ('I') and a.haccnt=b.no and b.i_times>0),0 )
						where class='rtngst'
--exp_dep	Ԥ�����
update audit_impdata set amount = isnull((select count(distinct a.roomno) from master_last a
						where a.class='F' and a.sta in ('I') and datediff(dd,a.dep,@bdate) = 0),0 )
						where class='exp_dep'

--act_dep	����ʵ�����
select @reslt = isnull((select count(distinct roomno) from master_till
						where class='F' and sta in ('O','S') and bdate=@bdate), 0)
update audit_impdata set amount = @reslt where class = 'act_dep'

--extnd_rm	��ס������
select @reslt=isnull((select count(distinct a.roomno) from master_till a
							where a.sta in ('I') and a.class='F' and exists(select 1 from master_last b where a.accnt=b.accnt and datediff(dd,b.dep,@bdate)=0)),0)
update audit_impdata set amount = @reslt where class = 'extnd_rm'

--e-co		��ǰ���
select @reslt=isnull((select count(distinct a.roomno) from master_till a
							where a.sta in ('S','O') and a.class='F' and exists(select 1 from master_last b where a.accnt=b.accnt and datediff(dd,b.dep,@bdate)<>0)),0)
update audit_impdata set amount = @reslt 	where class='e-co'
-----------------------------------------------------------------------------------------
--d_chkin	������ס
select @reslt = count(distinct roomno) from master_till
	where roomno in (select roomno from master_till where sta='I' and class='F' group by roomno having sum(gstno)>1)
if @reslt is null select @reslt = 0
update audit_impdata set amount = @reslt where class = 'd_chkin'
-----------------------------------------------------------------------------------------
--addbed		�Ӵ���
update audit_impdata set amount = isnull((select sum(a.addbed) from master_till a where a.sta in ('I')),0 )
						where class='addbed'
--crib		Ӥ������
update audit_impdata set amount = isnull((select sum(a.crib) from master_till a	where a.sta in ('I')),0 )
						where class='crib'

-----------------------------------------------------------------------------------------
--all_days  ���ڵ�����  ???
exec p_wz_audit_impt_data 'All days in hotel',@bdate,@reslt out
update audit_impdata set amount = isnull(@reslt,0) where class = 'all_days'
--exec p_wz_audit_impt_data 'Adv days in hotel',@bdate,@reslt out
--update audit_impdata set amount = @reslt where class = 'adv_days'
--adv_day%	ƽ��ס������  ???
update audit_impdata set amount  = (select   amount from audit_impdata where class='all_days')/(select    amount from audit_impdata where class='gst')
						where class = 'adv_day%' and (select   amount from audit_impdata where class='gst')<>0
update audit_impdata set amount_m = (select amount_m from audit_impdata where class='all_days')/(select amount_m from audit_impdata where class='gst')
						where class = 'adv_day%' and (select amount_m from audit_impdata where class='gst')<>0
update audit_impdata set amount_y = (select amount_y from audit_impdata where class='all_days')/(select amount_y from audit_impdata where class='gst')
						where class = 'adv_day%' and (select amount_y from audit_impdata where class='gst')<>0
-----------------------------------------------------------------------------------------

--group		��ҹ�Ŷ���
update audit_impdata set amount = isnull((select count(1) from master_till a where  a.class in ('G','M')
								and exists(select 1 from master_till b where b.groupno=a.accnt and b.sta='I' )),0 )
						where class='group'
--dayuse		���յ���
update audit_impdata set amount = isnull((select count(distinct a.roomno)  from master_till a
						where a.sta in ('O','S') and a.class in ('F') and a.bdate=@bdate and not exists(select 1 from master_last b where a.accnt=b.accnt and b.sta in ('I','S'))),0 )
						where class='dayuse'


--daybook		��������Ԥ������     ����Ԥ�����յ�+����Ԥ��δ��
select @reslt = isnull((select count(distinct a.roomno) from master_till a
	where a.class='F' and a.sta in ('I','S','O') and a.bdate=@bdate and substring(extra,9,1)<>'1'
		and a.resno like @cdate+'%'), 0)
update audit_impdata set amount =@reslt + isnull((select sum(a.quantity)  from rsvsrc_till a,master_till b
						where  a.accnt=b.accnt and b.sta='R' and datediff(dd,b.bdate,@bdate)=0 ),0 )
						where class='daybook'

--pre_booking	���쵽(��ǰԤ��)
select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and sta in ('I','S','O') and bdate=@bdate and
							 accnt in (select accnt from master_last where class='F' and sta in ('R'))), 0)

update audit_impdata set amount = @reslt where class = 'pre_booking'

--cur_booking	���쵽(����Ԥ��)
select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and sta in ('I','S','O') and bdate=@bdate and
							 accnt not in (select accnt from master_last where class='F' and sta in ('R'))), 0)

update audit_impdata set amount = @reslt where class = 'cur_booking'
-----------------------------------------------------------------------------------------
--	manager report - clg
-----------------------------------------------------------------------------------------
--bed
update audit_impdata set amount =isnull((select sum(bedno)  from rmsta	where  tag<>'P' ),0 )
						where class='bed'
--tarr_rms			���յ�����(���ջ���ҹ���ı��գ���)	->act_arr



--tarr_ps			���յ�����
select @reslt = isnull((select sum(gstno) from master_till where class='F' and sta in ('I') and bdate=@bdate and arr>=@bdate), 0)
select @reslt = @reslt + isnull((select sum(gstno) from master_till a where a.class='F' and a.sta in ('S','O') and a.bdate=@bdate
											and not exists(select 1 from master_last b where a.accnt=b.accnt and b.sta='I')), 0)

update audit_impdata set amount  = @reslt where class = 'tarr_ps'

--deducted			ȷ��Ԥ�����������ջ������գ�����
select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and sta in ('I') and bdate=@bdate and arr>=@bdate
    and restype in (select code from restype where definite='T') and substring(extra,9,1)<>'1'), 0)
select @reslt = @reslt + isnull((select count(distinct a.roomno) from master_till a where a.class='F' and a.sta in ('S','O') and a.bdate=@bdate
    and restype in (select code from restype where definite='T') and substring(extra,9,1)<>'1'
											and not exists(select 1 from master_last b where a.accnt=b.accnt and b.sta='I')), 0)
--exec p_gds_reserve_rsv_index @bdate, '%', 'Definite Reservations', 'R', @reslt output
update audit_impdata set amount  = @reslt where class = 'deducted'

--non_ded			��ȷ��Ԥ������
select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and sta in ('I') and bdate=@bdate and arr>=@bdate
    and restype not in (select code from restype where definite='T') and substring(extra,9,1)<>'1'), 0)
select @reslt = @reslt + isnull((select count(distinct a.roomno) from master_till a where a.class='F' and a.sta in ('S','O') and a.bdate=@bdate
    and restype not in (select code from restype where definite='T') and substring(extra,9,1)<>'1'
											and not exists(select 1 from master_last b where a.accnt=b.accnt and b.sta='I')), 0)
--exec p_gds_reserve_rsv_index @bdate, '%', 'Tentative Reservation', 'R', @reslt output
update audit_impdata set amount  = @reslt where class = 'non_ded'

--wlk_rms			Walk-in����->walkin


--wlk_ps			Walk-in����

select @reslt = isnull((select sum(gstno) from master_till where class='F' and substring(extra,9,1)='1' and sta in ('I') and bdate=@bdate), 0)
select @reslt = @reslt + isnull((select sum(gstno) from master_till a where a.class='F' and substring(extra,9,1)='1' and a.sta in ('S','O') and a.bdate=@bdate
											and not exists(select 1 from master_last b where a.accnt=b.accnt)), 0)
update audit_impdata set amount  = @reslt where class = 'wlk_ps'

--ext_rms			��ס����->extnd_rm



--ext_ps			��ס����

select @reslt=isnull((select sum(a.gstno) from master_till a
							where a.sta in ('I') and a.class='F' and exists(select 1 from master_last b where a.accnt=b.accnt and datediff(dd,b.dep,@bdate)=0)),0)
update audit_impdata set amount  = @reslt where class = 'ext_ps'

--o_rms			��귿��->act_dep



--o_ps			�������

select @reslt = isnull((select sum(gstno) from master_till
						where class='F' and sta in ('O','S') and bdate=@bdate), 0)
update audit_impdata set amount  = @reslt where class = 'o_ps'

--ed_rms			��ǰ���˷���->e-co



--ed_ps			��ǰ��������

select @reslt=isnull((select sum(a.gstno) from master_till a
							where a.sta in ('S','O') and a.class='F' and exists(select 1 from master_last b where a.accnt=b.accnt and datediff(dd,b.dep,@bdate)<>0)),0)
update audit_impdata set amount  = @reslt where class = 'ed_ps'

--o_soldf			������ɢ�ͷ���(Ӧ����ʵ��������ɢ��������ͳ��ָ����û�����֣���Ԥ�Ƶķ�ɢ�͵�)
select @reslt = isnull((select count(distinct roomno) from master_till
						where class='F' and sta in ('O','S') and bdate=@bdate and groupno=''), 0)
update audit_impdata set amount = @reslt where class = 'o_soldf'

--ot_gstf			������ɢ������
select @reslt = isnull((select sum(gstno) from master_till
						where class='F' and sta in ('O','S') and bdate=@bdate and groupno=''), 0)
update audit_impdata set amount  = @reslt where class = 'ot_gstf'

--o_soldg			�������Ŷӷ���
select @reslt = isnull((select count(distinct roomno) from master_till
						where class='F' and sta in ('O','S') and bdate=@bdate and groupno<>''), 0)
update audit_impdata set amount = @reslt where class = 'o_soldg'

--ot_gstg			�������Ŷ�����
select @reslt = isnull((select sum(gstno) from master_till
						where class='F' and sta in ('O','S') and bdate=@bdate and groupno<>''), 0)
update audit_impdata set amount  = @reslt where class = 'ot_gstg'

--o_frmem			�������Աɢ�ͷ���(Ӧ����ʵ��������ɢ��������ͳ��ָ����û�����֣���Ԥ�Ƶķ�ɢ�͵�)
select @reslt = isnull((select count(distinct roomno) from master_till
						where class='F' and cardno<>'' and sta in ('O','S') and bdate=@bdate and groupno=''), 0)
update audit_impdata set amount = @reslt where class = 'o_frmem'

--o_fgmem			�������Աɢ������
select @reslt = isnull((select sum(gstno) from master_till
						where class='F' and cardno<>'' and sta in ('O','S') and bdate=@bdate and groupno=''), 0)
update audit_impdata set amount  = @reslt where class = 'o_fgmem'

--o_rmem			�������Աɢ�ͷ���(Ӧ����ʵ��������ɢ��������ͳ��ָ����û�����֣���Ԥ�Ƶķ�ɢ�͵�)
select @reslt = isnull((select count(distinct roomno) from master_till
						where class='F' and cardno<>'' and sta in ('O','S') and bdate=@bdate), 0)
update audit_impdata set amount = @reslt where class = 'o_rmem'

--o_gmem			�������Աɢ������
select @reslt = isnull((select sum(gstno) from master_till
						where class='F' and cardno<>'' and sta in ('O','S') and bdate=@bdate), 0)
update audit_impdata set amount  = @reslt where class = 'o_gmem'

--ns_gst			noshow����
select @reslt = isnull((select sum(gstno) from master where class='F' and sta='N' and bdate=@bdate), 0)
update audit_impdata set amount= @reslt where class = 'ns_gst'

--tcxlt				����ȡ���ı���Ԥ��
select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and sta='X' and bdate=@bdate and datediff(dd,arr,@bdate)=0 and roomno<>''), 0)
select @reslt = @reslt+isnull((select sum(rmnum) from master_till where class='F' and sta='X' and bdate=@bdate and datediff(dd,arr,@bdate)=0 and roomno=''), 0)
update audit_impdata set amount = @reslt where class = 'tcxlt'

--cxl			    �ۼ�ȡ���ı���Ԥ��
select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and sta='X' and datediff(dd,arr,@bdate)=0 and roomno<>''), 0)
select @reslt = @reslt+isnull((select sum(rmnum) from master_till where class='F' and sta='X' and datediff(dd,arr,@bdate)=0 and roomno=''), 0)
update audit_impdata set amount = @reslt where class = 'cxl'

--cxlmade		����ȡ��Ԥ����--����������->cancel



--rsvmade		��������Ԥ��->daybook



--rsv_nights	������������--�����ѵ����Ŷ�Ԥ��������ķ���ͬס�����


select @reslt = isnull((select sum(rmnum*datediff(dd,arr,dep)) from master_till a
	where a.class='F' and a.sta in ('I','S','O') and a.bdate=@bdate and substring(extra,9,1)<>'1' and accnt=master
		and a.resno like @cdate+'%'), 0)
update audit_impdata set amount =@reslt + isnull((select sum(a.quantity*datediff(dd,a.begin_,a.end_))  from rsvsrc_till a,master_till b
						where  a.accnt=b.accnt and b.sta='R' and datediff(dd,b.bdate,@bdate)=0 ),0 )
						where class='rsv_nights'


--payment
update audit_impdata set amount  = isnull((select sumcre from dairep where class='01010'),0)	where class = 'payment'

--Ԥ��ָ��ڶ���Ĭ�ϲ��ؽ�
if @duringaudit='T'
begin
--tm_arr			���ս�������(������)
exec p_gds_reserve_rsv_index @badate, '%', 'Arrival Rooms', 'R', @reslt output
update audit_impdata set amount  = @reslt where class = 'tm_arr'

--tm_arr_ps			���ս�������
exec p_gds_reserve_rsv_index @badate, '%', 'Arrival Persons', 'R', @reslt output
update audit_impdata set amount  = @reslt where class = 'tm_arr_ps'

--tm_dep			���ս�������
exec p_gds_reserve_rsv_index @badate, '%', 'Departure Rooms', 'R', @reslt output
update audit_impdata set amount  = @reslt where class = 'tm_dep'

--tm_dep_ps			���ս�������
exec p_gds_reserve_rsv_index @badate, '%', 'Departure Persons', 'R', @reslt output
update audit_impdata set amount  = @reslt where class = 'tm_dep_ps'
exec p_gds_reserve_rsv_index @badate, '%', 'Room to Rent', 'R', @reslt output
update audit_impdata set amount=@reslt where class='avl_tm'
exec p_gds_reserve_rsv_index @badate, '%', 'Occupied Tonight-HU', 'R', @reslt output
update audit_impdata set amount=@reslt where class='sold_tm'
--����Ԥ�ⲻ������ά��
select @date_ = @badate,@reslt1 = 0,@reslt2=0
while datediff(dd,@date_,@badate)>-7
begin
    exec p_gds_reserve_rsv_index @date_, '%', 'Occupied Tonight-HU', 'R', @reslt output
    select @reslt1 = @reslt1 + @reslt
    exec p_gds_reserve_rsv_index @date_, '%', 'Room to Rent', 'R', @reslt output
    select @reslt2 = @reslt2 + @reslt
    select @date_=dateadd(dd,1,@date_)
end
update audit_impdata set amount=@reslt1 where class='sold_w'
update audit_impdata set amount=@reslt2 where class='avl_w'
select @date_ = @badate,@reslt1 = 0,@reslt2=0
while datediff(dd,@date_,@badate)>-31
begin
    exec p_gds_reserve_rsv_index @date_, '%', 'Occupied Tonight-HU', 'R', @reslt output
    select @reslt1 = @reslt1 + @reslt
    exec p_gds_reserve_rsv_index @date_, '%', 'Room to Rent', 'R', @reslt output
    select @reslt2 = @reslt2 + @reslt
    select @date_=dateadd(dd,1,@date_)
end
update audit_impdata set amount=@reslt1 where class='sold_m'
update audit_impdata set amount=@reslt2 where class='avl_m'
select @date_ = @badate,@reslt1 = 0,@reslt2=0
while datediff(dd,@date_,@badate)>-365
begin
    exec p_gds_reserve_rsv_index @date_, '%', 'Occupied Tonight-HU', 'R', @reslt output
    select @reslt1 = @reslt1 + @reslt
    exec p_gds_reserve_rsv_index @date_, '%', 'Room to Rent', 'R', @reslt output
    select @reslt2 = @reslt2 + @reslt
    select @date_=dateadd(dd,1,@date_)
end
update audit_impdata set amount=@reslt1 where class='sold_y'
update audit_impdata set amount=@reslt2 where class='avl_y'
end
else
begin
    update audit_impdata set amount=a.amount from yaudit_impdata a where a.class=audit_impdata.class
        and a.class in ('tm_arr','tm_arr_ps','tm_dep','tm_dep_ps','sold_tm','avl_tm','sold_w','avl_w','sold_m','avl_m','sold_y','avl_y') and a.date=@bdate
end

--�����Ͳ�����

update audit_impdata set amount = isnull((select sum(guest) from pos_tmenu where pccode in ('210','260') and sta='3' ),0)
 where class = 'pos_z'

update audit_impdata set amount = isnull((select sum(guest) from pos_tmenu where pccode  not in ('210','260') and sta='3'),0)
 where class = 'pos_x'

exec p_hry_audit_fstday @bdate, @isfstday out, @isyfstday out
if @isfstday ='T'
	update audit_impdata set amount_m = 0
if @isyfstday ='T'
	update audit_impdata set amount_m = 0,amount_y=0

update audit_impdata set amount_m = amount_m  +  amount,amount_y = amount_y  +  amount, date = @bdate
	where charindex('%', class) = 0

-----------------------------------------------------------------------------------------
--	%����
-----------------------------------------------------------------------------------------
update audit_impdata set amount_m = 100*(select amount_m from audit_impdata where class='sold')/(select amount_m from audit_impdata where class='avl')
						where class = 'sold%' and (select amount_m from audit_impdata where class='avl')<>0
update audit_impdata set amount_y = 100*(select amount_y from audit_impdata where class='sold')/(select amount_y from audit_impdata where class='avl')
						where class = 'sold%' and (select amount_y from audit_impdata where class='avl')<>0

--income%
update audit_impdata set amount  = (select amount from audit_impdata where class='income') / (select amount from audit_impdata where class='occ')
						where class = 'income%' and (select amount from audit_impdata where class='occ')<>0
update audit_impdata set amount_m  = (select amount_m from audit_impdata where class='income') / (select amount_m from audit_impdata where class='occ')
						where class = 'income%' and (select amount_m from audit_impdata where class='occ')<>0
update audit_impdata set amount_y  = (select amount_y from audit_impdata where class='income') / (select amount_y from audit_impdata where class='occ')
						where class = 'income%' and (select amount_y from audit_impdata where class='occ')<>0

--income_h%
update audit_impdata set amount  = (select amount from audit_impdata where class='income') / (select amount from audit_impdata where class='occ_h')
						where class = 'income_h%' and (select amount from audit_impdata where class='occ_h')<>0
update audit_impdata set amount_m  = (select amount_m from audit_impdata where class='income') / (select amount_m from audit_impdata where class='occ_h')
						where class = 'income_h%' and (select amount_m from audit_impdata where class='occ_h')<>0
update audit_impdata set amount_y  = (select amount_y from audit_impdata where class='income') / (select amount_y from audit_impdata where class='occ_h')
						where class = 'income_h%' and (select amount_y from audit_impdata where class='occ_h')<>0

--income_c%
update audit_impdata set amount  = (select amount from audit_impdata where class='income') / (select amount from audit_impdata where class='occ_c')
						where class = 'income_c%' and (select amount from audit_impdata where class='occ_c')<>0
update audit_impdata set amount_m  = (select amount_m from audit_impdata where class='income') / (select amount_m from audit_impdata where class='occ_c')
						where class = 'income_c%' and (select amount_m from audit_impdata where class='occ_c')<>0
update audit_impdata set amount_y  = (select amount_y from audit_impdata where class='income') / (select amount_y from audit_impdata where class='occ_c')
						where class = 'income_c%' and (select amount_y from audit_impdata where class='occ_c')<>0

--income_ch%
update audit_impdata set amount  = (select amount from audit_impdata where class='income') / (select amount from audit_impdata where class='occ_ch')
						where class = 'income_ch%' and (select amount from audit_impdata where class='occ_ch')<>0
update audit_impdata set amount_m  = (select amount_m from audit_impdata where class='income') / (select amount_m from audit_impdata where class='occ_ch')
						where class = 'income_ch%' and (select amount_m from audit_impdata where class='occ_ch')<>0
update audit_impdata set amount_y  = (select amount_y from audit_impdata where class='income') / (select amount_y from audit_impdata where class='occ_ch')
						where class = 'income_ch%' and (select amount_y from audit_impdata where class='occ_ch')<>0

--total_per
update audit_impdata set amount  = (select amount from audit_impdata where class='total') / (select amount from audit_impdata where class='gst')
						where class = 'total_per' and (select amount from audit_impdata where class='gst')<>0
update audit_impdata set amount_m  = (select amount_m from audit_impdata where class='total') / (select amount_m from audit_impdata where class='gst')
						where class = 'total_per' and (select amount_m from audit_impdata where class='gst')<>0
update audit_impdata set amount_y  = (select amount_y from audit_impdata where class='total') / (select amount_y from audit_impdata where class='gst')
						where class = 'total_per' and (select amount_y from audit_impdata where class='gst')<>0

--income_per
update audit_impdata set amount  = (select amount from audit_impdata where class='income') / (select amount from audit_impdata where class='gst')
						where class = 'income_per' and (select amount from audit_impdata where class='gst')<>0
update audit_impdata set amount_m  = (select amount_m from audit_impdata where class='income') / (select amount_m from audit_impdata where class='gst')
						where class = 'income_per' and (select amount_m from audit_impdata where class='gst')<>0
update audit_impdata set amount_y  = (select amount_y from audit_impdata where class='income') / (select amount_y from audit_impdata where class='gst')
						where class = 'income_per' and (select amount_y from audit_impdata where class='gst')<>0

--beduse%
update audit_impdata set amount  = 100*(select amount from audit_impdata where class='gst') / (select amount from audit_impdata where class='bed')
						where class = 'beduse%' and (select amount from audit_impdata where class='bed')<>0
update audit_impdata set amount_m  = 100*(select amount_m from audit_impdata where class='gst') / (select amount_m from audit_impdata where class='bed')
						where class = 'beduse%' and (select amount_m from audit_impdata where class='bed')<>0
update audit_impdata set amount_y  = 100*(select amount_y from audit_impdata where class='gst') / (select amount_y from audit_impdata where class='bed')
						where class = 'beduse%' and (select amount_y from audit_impdata where class='bed')<>0

--group_per
update audit_impdata set amount  = (select amount from audit_impdata where class='gst_mem') / (select amount from audit_impdata where class='t_soldg')
						where class = 'group_per' and (select amount from audit_impdata where class='t_soldg')<>0
update audit_impdata set amount_m  = (select amount_m from audit_impdata where class='gst_mem') / (select amount_m from audit_impdata where class='t_soldg')
						where class = 'group_per' and (select amount_m from audit_impdata where class='t_soldg')<>0
update audit_impdata set amount_y  = (select amount_y from audit_impdata where class='gst_mem') / (select amount_y from audit_impdata where class='t_soldg')
						where class = 'group_per' and (select amount_y from audit_impdata where class='t_soldg')<>0

--memrev_per
update audit_impdata set amount  = ((select amount from audit_impdata where class='memrev')+(select amount from audit_impdata where class='meetrev')) / (select amount from audit_impdata where class='t_soldg')
						where class = 'memrev_per' and (select amount from audit_impdata where class='t_soldg')<>0
update audit_impdata set amount_m  = ((select amount_m from audit_impdata where class='memrev')+(select amount from audit_impdata where class='meetrev')) / (select amount_m from audit_impdata where class='t_soldg')
						where class = 'memrev_per' and (select amount_m from audit_impdata where class='t_soldg')<>0
update audit_impdata set amount_y  = ((select amount_y from audit_impdata where class='memrev')+(select amount from audit_impdata where class='meetrev')) / (select amount_y from audit_impdata where class='t_soldg')
						where class = 'memrev_per' and (select amount_y from audit_impdata where class='t_soldg')<>0

--incomeg_per
update audit_impdata set amount  = ((select amount from audit_impdata where class='incomeg')+(select amount from audit_impdata where class='incomec')) / (select amount from audit_impdata where class='t_soldg')
						where class = 'incomeg_per' and (select amount from audit_impdata where class='t_soldg')<>0
update audit_impdata set amount_m  = ((select amount_m from audit_impdata where class='incomeg')+(select amount from audit_impdata where class='incomec')) / (select amount_m from audit_impdata where class='t_soldg')
						where class = 'incomeg_per' and (select amount_m from audit_impdata where class='t_soldg')<>0
update audit_impdata set amount_y  = ((select amount_y from audit_impdata where class='incomeg')+(select amount from audit_impdata where class='incomec')) / (select amount_y from audit_impdata where class='t_soldg')
						where class = 'incomeg_per' and (select amount_y from audit_impdata where class='t_soldg')<>0

--occ%			������
update audit_impdata set amount  = 100*(select   amount from audit_impdata where class='occ')/(select   amount from audit_impdata where class='ttl')
						where class = 'occ%' and (select   amount from audit_impdata where class='ttl')<>0
update audit_impdata set amount_m = 100*(select amount_m from audit_impdata where class='occ')/(select amount_m from audit_impdata where class='ttl')
						where class = 'occ%' and (select amount_m from audit_impdata where class='ttl')<>0
update audit_impdata set amount_y = 100*(select amount_y from audit_impdata where class='occ')/(select amount_y from audit_impdata where class='ttl')
						where class = 'occ%' and (select amount_y from audit_impdata where class='ttl')<>0

--occ_ch%			�����ʲ���������÷�
update audit_impdata set amount  = 100*(select   amount from audit_impdata where class='occ_ch')/(select   amount from audit_impdata where class='ttl')
						where class = 'occ_ch%' and (select   amount from audit_impdata where class='ttl')<>0
update audit_impdata set amount_m = 100*(select amount_m from audit_impdata where class='occ_ch')/(select amount_m from audit_impdata where class='ttl')
						where class = 'occ_ch%' and (select amount_m from audit_impdata where class='ttl')<>0
update audit_impdata set amount_y = 100*(select amount_y from audit_impdata where class='occ_ch')/(select amount_y from audit_impdata where class='ttl')
						where class = 'occ_ch%' and (select amount_y from audit_impdata where class='ttl')<>0

--occ_cho%			�����ʲ����������ά�޷�
update audit_impdata set amount  = 100*(select   amount from audit_impdata where class='occ_ch')/(select   amount from audit_impdata where class='ttl_o')
						where class = 'occ_cho%' and (select   amount from audit_impdata where class='ttl_o')<>0
update audit_impdata set amount_m = 100*(select amount_m from audit_impdata where class='occ_ch')/(select amount_m from audit_impdata where class='ttl_o')
						where class = 'occ_cho%' and (select amount_m from audit_impdata where class='ttl_o')<>0
update audit_impdata set amount_y = 100*(select amount_y from audit_impdata where class='occ_ch')/(select amount_y from audit_impdata where class='ttl_o')
						where class = 'occ_cho%' and (select amount_y from audit_impdata where class='ttl_o')<>0

--occ_h%			�����ʲ������÷�
update audit_impdata set amount  = 100*(select   amount from audit_impdata where class='occ_h')/(select   amount from audit_impdata where class='ttl')
						where class = 'occ_h%' and (select   amount from audit_impdata where class='ttl')<>0
update audit_impdata set amount_m = 100*(select amount_m from audit_impdata where class='occ_h')/(select amount_m from audit_impdata where class='ttl')
						where class = 'occ_h%' and (select amount_m from audit_impdata where class='ttl')<>0
update audit_impdata set amount_y = 100*(select amount_y from audit_impdata where class='occ_h')/(select amount_y from audit_impdata where class='ttl')
						where class = 'occ_h%' and (select amount_y from audit_impdata where class='ttl')<>0

--occ_c%			�����ʲ�����ѷ�
update audit_impdata set amount  = 100*(select   amount from audit_impdata where class='occ_c')/(select   amount from audit_impdata where class='ttl')
						where class = 'occ_c%' and (select   amount from audit_impdata where class='ttl')<>0
update audit_impdata set amount_m = 100*(select amount_m from audit_impdata where class='occ_c')/(select amount_m from audit_impdata where class='ttl')
						where class = 'occ_c%' and (select amount_m from audit_impdata where class='ttl')<>0
update audit_impdata set amount_y = 100*(select amount_y from audit_impdata where class='occ_c')/(select amount_y from audit_impdata where class='ttl')
						where class = 'occ_c%' and (select amount_y from audit_impdata where class='ttl')<>0

--occ_co%			�����ʲ������ά�޷�
update audit_impdata set amount  = 100*(select   amount from audit_impdata where class='occ_c')/(select   amount from audit_impdata where class='ttl_o')
						where class = 'occ_co%' and (select   amount from audit_impdata where class='ttl_o')<>0
update audit_impdata set amount_m = 100*(select amount_m from audit_impdata where class='occ_c')/(select amount_m from audit_impdata where class='ttl_o')
						where class = 'occ_co%' and (select amount_m from audit_impdata where class='ttl_o')<>0
update audit_impdata set amount_y = 100*(select amount_y from audit_impdata where class='occ_c')/(select amount_y from audit_impdata where class='ttl_o')
						where class = 'occ_co%' and (select amount_y from audit_impdata where class='ttl_o')<>0

--occ_ho%			�����ʲ�������ά�޷�
update audit_impdata set amount  = 100*(select   amount from audit_impdata where class='occ_h')/(select   amount from audit_impdata where class='ttl_o')
						where class = 'occ_ho%' and (select   amount from audit_impdata where class='ttl_o')<>0
update audit_impdata set amount_m = 100*(select amount_m from audit_impdata where class='occ_h')/(select amount_m from audit_impdata where class='ttl_o')
						where class = 'occ_ho%' and (select amount_m from audit_impdata where class='ttl_o')<>0
update audit_impdata set amount_y = 100*(select amount_y from audit_impdata where class='occ_h')/(select amount_y from audit_impdata where class='ttl_o')
						where class = 'occ_ho%' and (select amount_y from audit_impdata where class='ttl_o')<>0

--occ_o%			�����ʲ���ά�޷�
update audit_impdata set amount  = 100*(select   amount from audit_impdata where class='occ')/(select   amount from audit_impdata where class='ttl_o')
						where class = 'occ_o%' and (select   amount from audit_impdata where class='ttl_o')<>0
update audit_impdata set amount_m = 100*(select amount_m from audit_impdata where class='occ')/(select amount_m from audit_impdata where class='ttl_o')
						where class = 'occ_o%' and (select amount_m from audit_impdata where class='ttl_o')<>0
update audit_impdata set amount_y = 100*(select amount_y from audit_impdata where class='occ')/(select amount_y from audit_impdata where class='ttl_o')
						where class = 'occ_o%' and (select amount_y from audit_impdata where class='ttl_o')<>0

--tm_sold%			���ճ�����
update audit_impdata set amount  = 100*((select amount from audit_impdata where class='sold_tm'))/(select   amount from audit_impdata where class='avl_tm')
						where class = 'tm_sold%' and (select   amount from audit_impdata where class='avl_tm')<>0
update audit_impdata set amount_m  = 100*((select amount_m from audit_impdata where class='sold_tm'))/(select   amount_m from audit_impdata where class='avl_tm')
						where class = 'tm_sold%' and (select   amount_m from audit_impdata where class='avl_tm')<>0
update audit_impdata set amount_y  = 100*((select amount_y from audit_impdata where class='sold_tm'))/(select   amount_y from audit_impdata where class='avl_tm')
						where class = 'tm_sold%' and (select   amount_y from audit_impdata where class='avl_tm')<>0

--nw_sold%			��7�������<>7Ԥ��������-7��귿����=((((sold+tm_arr-tm_dep)*2+n2arr-n2dep)*2+n3arr-n3dep)*2����
update audit_impdata set amount  = 100*(select amount from audit_impdata where class='sold_w') / (select amount from audit_impdata where class='avl_w')
						where class = 'nw_sold%' and (select   amount from audit_impdata where class='avl_w')<>0
update audit_impdata set amount_m  = 100*(select amount_m from audit_impdata where class='sold_w') / (select amount_m from audit_impdata where class='avl_w')
						where class = 'nw_sold%' and (select   amount_m from audit_impdata where class='avl_w')<>0
update audit_impdata set amount_y  = 100*(select amount_y from audit_impdata where class='sold_w') / (select amount_y from audit_impdata where class='avl_w')
						where class = 'nw_sold%' and (select   amount_y from audit_impdata where class='avl_w')<>0

--nm_sold%			��7�������<>7Ԥ��������-7��귿����=((((sold+tm_arr-tm_dep)*2+n2arr-n2dep)*2+n3arr-n3dep)*2����
update audit_impdata set amount  = 100*(select amount from audit_impdata where class='sold_m') / (select amount from audit_impdata where class='avl_m')
						where class = 'nm_sold%' and (select   amount from audit_impdata where class='avl_m')<>0
update audit_impdata set amount_m  = 100*(select amount_m from audit_impdata where class='sold_m') / (select amount_m from audit_impdata where class='avl_m')
						where class = 'nm_sold%' and (select   amount_m from audit_impdata where class='avl_m')<>0
update audit_impdata set amount_y  = 100*(select amount_y from audit_impdata where class='sold_m') / (select amount_y from audit_impdata where class='avl_m')
						where class = 'nm_sold%' and (select   amount_y from audit_impdata where class='avl_m')<>0


--ny_sold%			��7�������<>7Ԥ��������-7��귿����=((((sold+tm_arr-tm_dep)*2+n2arr-n2dep)*2+n3arr-n3dep)*2����
update audit_impdata set amount  = 100*(select amount from audit_impdata where class='sold_y') / (select amount from audit_impdata where class='avl_y')
						where class = 'ny_sold%' and (select   amount from audit_impdata where class='avl_y')<>0
update audit_impdata set amount_m  = 100*(select amount_m from audit_impdata where class='sold_y') / (select amount_m from audit_impdata where class='avl_y')
						where class = 'ny_sold%' and (select   amount_m from audit_impdata where class='avl_y')<>0
update audit_impdata set amount_y  = 100*(select amount_y from audit_impdata where class='sold_y') / (select amount_y from audit_impdata where class='avl_y')
						where class = 'ny_sold%' and (select   amount_y from audit_impdata where class='avl_y')<>0


delete yaudit_impdata where date = @bdate
insert yaudit_impdata select * from audit_impdata
return 0
;
