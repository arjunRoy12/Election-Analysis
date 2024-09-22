create database election;
use election;
create table results_2014(
state varchar(50),
pc_name varchar(55),
candidate varchar(75),
sex varchar(10),
age varchar(20) null,
category varchar(30) null,
	party varchar(30) null,
	party_symbol varchar(50) null,
	general_votes bigint null,
	postal_votes bigint null,
	total_votes bigint null,
    total_electors bigint null
);
create table results_2019(
state varchar(50),
pc_name varchar(55) ,
candidate varchar(75),
sex varchar(10),
age varchar(20) null,
category varchar(30) null,
	party varchar(30) null,
	party_symbol varchar(50) null,
	general_votes bigint null,
	postal_votes bigint null,
	total_votes bigint null,
    total_electors bigint null
);
alter table results_2014 add constraint primary key(state,pc_name,candidate);
alter table results_2014 add constraint primary key(state,pc_name,candidate);

update results_2014 set state="Telangana" where pc_name in (
"Adilabad","Bhongir","CHEVELLA","Hyderabad","Karimnagar","Khammam","Mahabubabad",
"Mahbubnagar","Malkajgiri","Medak","Nagarkurnool","Nalgonda","Nizamabad","Peddapalle",
"Secundrabad","Warangal","Zahirabad");
update results_2014 set pc_name="Bikaner (SC)" where pc_name="Bikaner";
update results_2014 set candidate="NOTA" where candidate ="NONE OF THE ABOVE";
update results_2014 set pc_name="Bardhaman Durgapur" where pc_name="Burdwan - durgapur";
update results_2014 set pc_name="CHEVELLA" where pc_name="CHELVELLA";
update results_2014 set pc_name="Dadra And Nagar Haveli" where pc_name="Dadar & Nagar Haveli";
update results_2014 set pc_name="Jaynagar" where pc_name="Joynagar";
select * from results_2014;

#state wise votes in 2014
create temporary table state_votes_2014 as
select state,sum(total_votes) as total_state_votes2014, 
sum(distinct total_electors) as total_state_electors2014
from results_2014 group by state;

#constituency wise votes in 2014
create temporary table constituency_votes_2014 as 
select state,pc_name,sum(total_votes) as total_constituency_votes2014,
total_electors as total_constituency_electors2014
from results_2014
group by state,pc_name,total_electors;

#party win by constituency in 2014
create temporary table constituency_winning_party2014 as
select state,pc_name,party,
round((leading_votes/total_constituency_electors2014)*100,2) as vote_percentage,
leading_votes,total_constituency_electors2014 from
(select state,pc_name,party,total_votes as leading_votes,
total_electors as total_constituency_electors2014,
row_number() over(partition by state,pc_name order by total_votes desc) as rn
from results_2014) as x where x.rn=1;

#party win by state in 2014
create temporary table state_winning_party2014 as
select state,party,
round((leading_votes/state_electors2014)*100,2) as vote_percentage,
leading_votes,state_electors2014 from
(select state,party,sum(total_votes) as leading_votes,
sum(distinct total_electors) as state_electors2014,
row_number() over(partition by state order by sum(total_votes) desc) as rn
from results_2014 group by state,party) as x where x.rn=1;

#state wise votes in 2019
create temporary table state_votes_2019 as
select state,sum(total_votes) as total_state_votes2019, 
sum(distinct total_electors) as total_state_electors2019
from results_2019 group by state;

#constituency wise votes in 2019
create temporary table constituency_votes_2019 as 
select state,pc_name,sum(total_votes) as total_constituency_votes2019,
total_electors as total_constituency_electors2019
from results_2019
group by state,pc_name,total_electors;

#party win by constituency in 2019
create temporary table constituency_winning_party2019 as
select state,pc_name,party,
round((leading_votes/total_constituency_electors2019)*100,2) as vote_percentage,
leading_votes,total_constituency_electors2019 from
(select state,pc_name,party,total_votes as leading_votes,
total_electors as total_constituency_electors2019,
row_number() over(partition by state,pc_name order by total_votes desc) as rn
from results_2019) as x where x.rn=1;

#party win by state in 2019
create temporary table state_winning_party2019 as
select state,party,
round((leading_votes/state_electors2019)*100,2) as vote_percentage,
leading_votes,state_electors2019 from
(select state,party,sum(total_votes) as leading_votes,
sum(distinct total_electors) as state_electors2019,
row_number() over(partition by state order by sum(total_votes) desc) as rn
from results_2019 group by state,party) as x where x.rn=1;

#top 5 constituency w.r.t voter turnout ratio in 2014
select pc_name from constituency_votes_2014
order by (total_constituency_votes2014/total_constituency_electors2014) desc limit 5;

#bottom 5 constituency w.r.t voter turnout ratio in 2014
select pc_name from constituency_votes_2014
order by (total_constituency_votes2014/total_constituency_electors2014) limit 5;

#top 5 constituency w.r.t voter turnout ratio in 2019
select pc_name from constituency_votes_2019
order by (total_constituency_votes2019/total_constituency_electors2019) desc limit 5;

#bottom 5 constituency w.r.t voter turnout ratio in 2019
select pc_name from constituency_votes_2019
order by (total_constituency_votes2019/total_constituency_electors2019) limit 5;

#top 5 states w.r.t voter turnout ratio in 2014
select state from state_votes_2014
order by (total_state_votes2014/total_state_electors2014) desc limit 5;

#bottom 5 states w.r.t voter turnout ratio in 2014
select state from state_votes_2014
order by (total_state_votes2014/total_state_electors2014) limit 5;

#top 5 states w.r.t voter turnout ratio in 2019
select state from state_votes_2019
order by (total_state_votes2019/total_state_electors2019) desc limit 5;

#bottom 5 states w.r.t voter turnout ratio in 2019
select state from state_votes_2019
order by (total_state_votes2019/total_state_electors2019) limit 5;

#constituencies have elected same party for two consecutive elections
select  c1.pc_name,rank() over(order by c2.vote_percentage desc)as rank_by_vote
from constituency_winning_party2014 c1 join constituency_winning_party2019 c2
on c1.state=c2.state and c1.pc_name=c2.pc_name and c1.party=c2.party;

#top 10 constituencies have voted for different party 
select  c1.pc_name,c1.party,c2.party from constituency_winning_party2014 c1 join constituency_winning_party2019 c2
on c1.state=c2.state and c1.pc_name=c2.pc_name and c1.party!=c2.party
order by (c2.vote_percentage-c1.vote_percentage) desc limit 10;

#top 5 candidates based on margin difference in 2014
with cte as (select candidate,
total_votes-lead(total_votes) over(partition by pc_name order by total_votes desc) as lead_votes,
row_number() over(partition by pc_name order by total_votes desc) as rn
from results_2014)
select candidate from cte where rn=1 order by lead_votes desc limit 5;

#top 5 candidates based on margin difference in 2019
with cte as (select candidate,
total_votes-lead(total_votes) over(partition by pc_name order by total_votes desc) as lead_votes,
row_number() over(partition by pc_name order by total_votes desc) as rn
from results_2019)
select candidate from cte where rn=1 order by lead_votes desc limit 5;

#%split of votes of parties in 2014 at national level
with cte as(select sum(total_votes) as total_country_votes from results_2014)
select party,round(sum(total_votes)/total_country_votes*100,2) votes_by_country
from results_2014,cte
group by party,total_country_votes
order by votes_by_country desc;

#%split of votes of parties in 2019 at national level
with cte as(select sum(total_votes) as total_country_votes from results_2019)
select party,round(sum(total_votes)/total_country_votes*100,2) votes_by_country
from results_2019,cte
group by party,total_country_votes
order by votes_by_country desc;

#%split of votes of parties in 2014 at state level
with cte as(select state,sum(total_votes) as total_state_votes from results_2014
group by state)
select r.state,r.party,round(sum(r.total_votes)/c.total_state_votes*100,2) as votes_by_state 
from results_2014 r join cte c
on r.state=c.state
group by r.state,r.party,c.total_state_votes
order by r.state,votes_by_state desc;

#%split of votes of parties in 2019 at state level
with cte as(select state,sum(total_votes) as total_state_votes from results_2019
group by state)
select r.state,r.party,round(sum(r.total_votes)/c.total_state_votes*100,2) as votes_by_state 
from results_2019 r join cte c
on r.state=c.state
group by r.state,r.party,c.total_state_votes
order by r.state,votes_by_state desc;

#top 5 constituency where parties gained vote share in 2019 as compared to 2014
##national_party='BJP'
select r1.pc_name,(r2.total_votes-r1.total_votes) as vote_gain 
from results_2014 r1 left join results_2019 r2 on r1.pc_name=r2.pc_name and r1.party=r2.party
where r1.party ='BJP'
order by vote_gain desc limit 5;

##national_party='INC'
select r1.pc_name,(r2.total_votes-r1.total_votes) as vote_gain 
from results_2014 r1 left join results_2019 r2 on r1.pc_name=r2.pc_name and r1.party=r2.party
where r1.party='INC' 
order by vote_gain desc limit 5;

#top 5 constituency where parties lost vote share in 2019 as compared to 2014
##national_party='BJP'
select r1.pc_name,(r1.total_votes-r2.total_votes) as vote_gain 
from results_2014 r1 left join results_2019 r2 on r1.pc_name=r2.pc_name and r1.party=r2.party
where r1.party='BJP' 
order by vote_gain desc limit 5;

##national_party='INC'
select r1.pc_name,(r1.total_votes-r2.total_votes) as vote_gain 
from results_2014 r1 left join results_2019 r2 on r1.pc_name=r2.pc_name and r1.party=r2.party
where r1.party='INC' 
order by vote_gain desc limit 5;

#constituency has voted most for NOTA in 2014
select pc_name, total_votes from results_2014 where candidate='NOTA'
order by total_votes desc limit 1;

#constituency has voted most for NOTA in 2019
select pc_name, total_votes from results_2019 where candidate='NOTA'
order by total_votes desc limit 1;



