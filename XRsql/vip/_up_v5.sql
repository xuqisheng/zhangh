// 1. 
//exec sp_rename  vipcard, a_vipcard;

// 2. create new table 

// 3. insert old data
//insert vipcard
//	SELECT no,sno,'',sta,type,'3','1','F',name,code1,code2,code3,code4,code5,araccnt1,araccnt2,
//		cno,cno,hno,arr,dep,'168168','','',crc,extrainf,postctrl,'',limit,0,0,1,
//		'hbjl','',resby,reserved,resby,reserved,cby,changed,ref,'','','','','',
//		'','','','','',0,0,0,null,null,null,logmark  
//FROM a_vipcard  ;
//

// select * from vipcard where kno='';   ???

// select type, count(1) from vipcard group by type;
// select  * from vipcard_type;   -- 把本地的卡类别 设置为 0
//update vipcard set type = '0';
//select * from guest_card where cardno like 'K%';



update vipcard set kno=hno where kno='' and hno<>'';
