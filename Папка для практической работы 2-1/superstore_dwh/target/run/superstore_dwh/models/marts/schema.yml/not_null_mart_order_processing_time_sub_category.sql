
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select sub_category
from "superstore"."dw_test"."mart_order_processing_time"
where sub_category is null



  
  
      
    ) dbt_internal_test