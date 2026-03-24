
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select avg_processing_days
from "superstore"."dw_test"."mart_order_processing_time"
where avg_processing_days is null



  
  
      
    ) dbt_internal_test