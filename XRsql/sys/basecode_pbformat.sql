-- Char Foramt
insert basecode_cat(cat,descript,descript1,len) select 'pbformat_char', 'Char Foramt', 'Char Foramt', 10;
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'pbformat_char', '1','[general]', '[general]', 'T','T',0,'1';
-- Number Foramt
insert basecode_cat(cat,descript,descript1,len) select 'pbformat_numb', 'Number Foramt', 'Number Foramt', 10;
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'pbformat_numb', '1','0', '0', 'T','T',0,'1';
-- Money Foramt
insert basecode_cat(cat,descript,descript1,len) select 'pbformat_mone', 'Money Foramt', 'Money Foramt', 10;
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'pbformat_mone', '1','0.00', '0.00', 'T','T',0,'1';
-- DateTime Foramt
insert basecode_cat(cat,descript,descript1,len) select 'pbformat_date', 'DateTime Foramt', 'DateTime Foramt', 10;
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'pbformat_date', '1', 'yyyy/mm/dd', 'yyyy/mm/dd', 'T','T',0,'1';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'pbformat_date', '2', 'yyyy-mm-dd', 'yyyy-mm-dd', 'T','T',0,'1';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'pbformat_date', '3','mm/dd', 'mm/dd', 'T','T',0,'1';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'pbformat_date', '4','yyyy/mm/dd hh|mm', 'yyyy/mm/dd hh|mm', 'T','T',0,'1';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'pbformat_date', '5','yyyy-mm-dd hh|mm', 'yyyy-mm-dd hh|mm', 'T','T',0,'1';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'pbformat_date', '6','mm/dd hh|mm', 'mm/dd hh|mm', 'T','T',0,'1';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'pbformat_date', '7','hh|mm', 'hh|mm', 'T','T',0,'1';

