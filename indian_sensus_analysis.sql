use indian_census;
-- number of rows into our dataset

select count(*) from dataset1;
select count(*) from dataset2;

-- find dataset for jharkhand and bihar

select * from dataset1
where state in ('Bihar' , 'Jharkhand');

-- population of India

select * from dataset2;
select sum(Population) as population from dataset2;

-- avg growth in state

 select state, round(avg(Growth),1) as Avg_growth from dataset1
 group by state;


-- avg sex ratio

select state, round(avg(sex_ratio),1) as Avg_sexratio from dataset1
 group by state;
 

-- avg literacy rate and find state with avg literacy more than 90
 
 select state, round(avg(Literacy),0) as Avg_literacy_rate from dataset1
 group by state
 having Avg_literacy_rate>90
 order by Avg_literacy_rate desc;
 

-- top 3 state showing highest growth ratio

select state, max(growth) as max_growth from dataset1
group by state
order by max_growth desc
limit 3;

select state, growth from dataset1
order by growth desc;


-- bottom 3 state showing lowest avg sex ratio

select state, avg(sex_ratio) as min_sex_ratio from dataset1
group by state
order by min_sex_ratio desc
limit 3;


-- find top and bottom 3 states in literacy state

drop table if exists top_bottom_states;
create table  top_bottom_states
( state nvarchar(255),
   avg_literacy_ratio float
  );
  
insert into top_bottom_states 
((select state,round(avg(literacy),0) avg_literacy_rate from dataset1 
group by state order by avg_literacy_rate desc limit 3) 
union 
(select state,round(avg(literacy),0) avg_literacy_ratio from dataset1 
group by state order by avg_literacy_ratio asc limit 3));

select * from top_bottom_states



-- find states starting with letter a or b

select distinct state from dataset1 where state like 'a%' or state like 'b%';


-- find states starting with letter a and ends with m

select distinct state from dataset1 where state like 'a%' and state like '%m';



-- find total no of males and females in each state (sex_ratio is f/m)

--- Equation used
males+females= population ....1
females/males= sex_ratio ....2
    females= sex_ratio*males  .....equating this in 1
    
    males(1+sex_ratio)=population
    males=population/(1+sex_ratio) ...
    
select d.state, sum(d.males),sum(d.females) from    
(select c.district, c.state, round((c.population/(c.sex_ratio+1)),0) males, c.population - round((c.population/(c.sex_ratio+1)),0) females from
(select a.district, a.state, a.sex_ratio/1000 sex_ratio, b.population from dataset1 a inner join dataset2 b on a.district=b.district) c) d
group by state
    


-- find total literacy rate for each state (literacy is percentage of literate people in population)

--- Equation used
total_literate_people/population= Literacy 
 total_0literate_people=Literacy*population ....1
    total_illiterate= (1-Literacy)*population  .....2
    

select d.state, sum(d.literate_pop) total_literate_pop,sum(d.illiterate_pop) total_illiterate_pop from
(select c.district,c.state, round(c.literacy_rate*c.population,0) literate_pop, c.population - round(c.literacy_rate*c.population,0) illiterate_pop from
(select a.district, a.state, a.literacy/100 literacy_rate,b.population from dataset1 a inner join dataset2 b on a.district=b.district) c) d 
group by state;



-- find records of population in previous census

--- equation used

previous_pop+previous_pop*growth=current_pop
previous_pop= current_pop/(1+growth)  .......1

select d.state, sum(d.previous_pop) total_prev_pop, sum(d.current_pop) total_curr_pop from
(select c.district,c.state, round(c.population/(1+c.growth),0) previous_pop, c.population current_pop from
(select a.district, a.state, round(a.growth/100,4) growth, b.population from dataset1 a inner join dataset2 b on a.district=b.district)  c) d
group by d.state




-- find population by area for each state


select a.state, sum(pop_km2) as total_pop_by_area from
(select *, round(population/area_km2,0) as pop_km2 from dataset2) a
group by a.state



-- find top 3 districts from each state with highest literacy rate 


select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from dataset1) a
where a.rnk in (1,2,3) order by state;