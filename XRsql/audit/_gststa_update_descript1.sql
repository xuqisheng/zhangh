update gststa set descript1='Total' where descript='��     ��';
update gststa set descript1='Province Inside' where descript='ʡ  ��';
update gststa set descript1='Province Outside' where descript='ʡ  ��';
update gststa set descript1='---Over Seas---' where descript='---����---';
update gststa set descript1='--Foreign Guest--' where descript='---���---';
update gststa set descript1=a.descript1 from countrycode a where gststa.nation=a.code; 

update ygststa set descript1='Total' where descript='��     ��';
update ygststa set descript1='Province Inside' where descript='ʡ  ��';
update ygststa set descript1='Province Outside' where descript='ʡ  ��';
update ygststa set descript1='---Over Seas---' where descript='---����---';
update ygststa set descript1='--Foreign Guest--' where descript='---���---';
update ygststa set descript1=a.descript1 from countrycode a where ygststa.nation=a.code; 

