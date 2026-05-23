/* 
===============================================================================================================================================================
Stored Procedure : Load bronze Layer (Source -> Bronze)
===============================================================================================================================================================
Script Purpose : 
                This Stored procedure loads data into bronze schema from external csv files.
                It performs the following actions:
                  - Truncates  the bronze tables brfore loading data.
                  - Uses the 'Bulk Insert' command to load data csv files to bronze tables

Parameters ;
    None.
    This Stored Procedure does not accept any parameters and doesn't returns any values.

Usage Example:
  EXEC bronze.load_bronze;
===============================================================================================================================================================
*/
Create or Alter procedure bronze.load_bronze as
begin
	declare @start_time datetime , @end_time datetime , @batch_start_time datetime , @batch_end_time datetime ;
	begin try 
	set @batch_start_time = GETDATE()
			Print '=========================================================='
			print ' Loading bronze Layer'
			Print '=========================================================='
	
			Print '---------------------------------------------------------';
			Print '1) Loading Crm Tables'
			print '----------------------------------------------------------';
			
			Set @start_time = GETDATE()
			print '>> Truncating Table: bronze.crm_cust_info'
			Truncate table bronze.crm_cust_info;
			print'Inserting  bronze.crm_cust_info'
			Bulk insert bronze.crm_cust_info 
			from 'D:\CODE\Data_engineering\sql_data_warehouse_project_main\datasets\source_crm\cust_info.csv' 
			with (
				FIRSTROW = 2,   -- To Define the starting row for data loading, especially when the first row contains column headers.
				Fieldterminator = ',',
				Tablock ); -- To optimize the bulk insert operation by acquiring a bulk update lock on the table, 
							--which can improve performance when loading large volumes of data.
			Set @end_time = GETDATE()
			print 'Loading Duration ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds'
			print ''
			Set @start_time = GETDATE()
			print '>> Truncating Table: bronze.crm_prd_info'
			Truncate table bronze.crm_prd_info; 
			print'Inserting  bronze.crm_prd_info'
			Bulk insert bronze.crm_prd_info 
			from 'D:\CODE\Data_engineering\sql_data_warehouse_project_main\datasets\source_crm\prd_info.csv' 
			with (
				FIRSTROW = 2,
				Fieldterminator = ',',
				Tablock );
			Set @end_time = GETDATE()
			print 'Loading Duration ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds'
	
			print ''	
			Set @start_time = GETDATE()
			print '>> Truncating Table: bronze.crm_sales_details'
			print'Inserting  bronze.crm_sales_details'
			Truncate table bronze.crm_sales_details;
			Bulk insert bronze.crm_sales_details 
			from 'D:\CODE\Data_engineering\sql_data_warehouse_project_main\datasets\source_crm\sales_details.csv' 
			with (
				FIRSTROW = 2,
				Fieldterminator = ',',
				Tablock );
			Set @end_time = GETDATE()
			print 'Loading Duration ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds'
		
			print ''
			print '----------------------------------------------------------';
			print '2) Loading Erm Tables'
			print '----------------------------------------------------------';

			Set @start_time = GETDATE()
			print '>> Truncating Table: bronze.erp_CUST_AZ12'
			Truncate table bronze.erp_CUST_AZ12 ;
			print'Inserting  bronze.erp_CUST_AZ12'
			Bulk insert bronze.erp_CUST_AZ12 
			from 'D:\CODE\Data_engineering\sql_data_warehouse_project_main\datasets\source_erp\CUST_AZ12.csv' 
			with (
				FIRSTROW = 2,
				Fieldterminator = ',',
				Tablock );
			Set @end_time = GETDATE()
			print 'Loading Duration ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds'

			print ''

			Set @start_time = GETDATE()
			print '>> Truncating Table: bronze.erp_LOC_A101 '
			Truncate table  bronze.erp_LOC_A101;
			print'Inserting  bronze.erp_LOC_A101'
			Bulk insert bronze.erp_LOC_A101 
			from 'D:\CODE\Data_engineering\sql_data_warehouse_project_main\datasets\source_erp\LOC_A101.csv' 
			with (
				FIRSTROW = 2,
				Fieldterminator = ',',
				Tablock );
			Set @end_time = GETDATE()
			print 'Loading Duration ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds'

			print ''
			Set @start_time = GETDATE()
			print '>> Truncating Table: bronze.erp_PX_CAT_G1V2 '
			Truncate table  bronze.erp_PX_CAT_G1V2 ;
			print'Inserting bronze.erp_PX_CAT_G1V2 '
			Bulk insert bronze.erp_PX_CAT_G1V2 
			from 'D:\CODE\Data_engineering\sql_data_warehouse_project_main\datasets\source_erp\PX_CAT_G1V2.csv' 
			with (
				FIRSTROW = 2,
				Fieldterminator = ',',
				Tablock );
			Set @end_time = GETDATE()
			print 'Loading Duration ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds'
	set @batch_end_time = GETDATE()
	print '=============================================== ' 
	print 'Loading broznze Layer is Completed';
	print '		- Total Batch Duration ' + cast(datediff(second,@batch_start_time,@batch_end_time) as nvarchar) + ' seconds'		
	print '=============================================== ' 
	end try 
	begin catch
	print '=============================================== ' 
	print 'Error Occurred during Loading bronze Layer' 
	print 'Error Message' + Error_Message() ;
	print 'Error Message' + cast (error_Number() as Nvarchar);
	print 'Error Message' + cast (error_State() as Nvarchar);
	print '=============================================== ' 

	end catch	
	

end



