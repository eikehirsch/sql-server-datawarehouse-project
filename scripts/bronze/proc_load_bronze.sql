/*
===============================================================================
Stored Procedure: Carregamento da Camada Bronze (Source -> Bronze)
===============================================================================
Script Purpose:
    Essa stored procedure carrega dados no esquema 'bronze' a partir de arquivos CSV files externos. 
    Ela realiza as seguintes ações:
    - Faz um truncate nas tabelas bronze antes de carregar os dados.
    - Usa o comando `BULK INSERT` para carregar dados de arquivos CSV para as tabelas bronze.

Parâmetros:
    Nenhum. 
	  Essa stored procedure não aceita parâmetros tampouco retorna valores.

Exemplo de uso:
    EXEC bronze.load_bronze;
===============================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME;
	BEGIN TRY
		PRINT '================================================';
		PRINT 'Carregando Camada Bronze';
		PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Carregando Tabelas CRM';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();

		TRUNCATE TABLE bronze.crm_cust_info;
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\Eike\Documents\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		TRUNCATE TABLE bronze.crm_prd_info;
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\Eike\Documents\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);


		TRUNCATE TABLE bronze.crm_sales_details;
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\Eike\Documents\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		PRINT '------------------------------------------------';
		PRINT 'Carregando Tabelas ERP';
		PRINT '------------------------------------------------';

		TRUNCATE TABLE bronze.erp_cust_az12;
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\Eike\Documents\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);


		TRUNCATE TABLE bronze.erp_loc_a101;
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\Eike\Documents\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);


		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\Eike\Documents\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();

		PRINT '>> Duração do carregamento da Camada Bronze: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos.';
	END TRY

	BEGIN CATCH
		PRINT '==================================================';
		PRINT 'ERRO OCORRIDO DURANTE O CARREGAMENTO DA CAMADA BRONZE';
		PRINT 'Mensagem do Erro' + ERROR_MESSAGE();
		PRINT 'Mensagem do Erro' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Mensagem do Erro' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '==================================================';
	END CATCH
END;
