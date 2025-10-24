
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    geo_id as unique_field,
    count(*) as n_records

from "superstore"."dw_test"."geo_dim"
where geo_id is not null
group by geo_id
having count(*) > 1



  
  
      
    ) dbt_internal_test