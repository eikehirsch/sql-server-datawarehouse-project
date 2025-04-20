/*
===============================================================================
Testes de qualidade
===============================================================================
Objetivo do Script:
    Esse script executa testes de qualidade para validar a integridade e 
consistêcia da camada Gold. Esses testes incluem:
    - Exclusividade das surrogate keys nas tabelas dimensões.
    - Integridade referencial entre as tabelas dimensões e a tabela fato.
    - Validação de relacionamentos no modelo de dados para fins analíticos.

Notas de uso:
    - Investigar e resolver quaisquer discrepâncias encontradas durantes as checagens.
===============================================================================
*/

-- ====================================================================
-- Checando 'gold.dim_customers'
-- ====================================================================
-- Checagem de exclusividade do Customer Key na tabela gold.dim_customers
-- Esperado: 0 resultados
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checando 'gold.product_key'
-- ====================================================================
-- Checagem de exclusividade do Product Key na tabela gold.dim_products
-- Esperado: 0 resultados
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- Checagem para descobrir se algum registro da fato não possui relação com as dimensões
-- Esperado: zero resultados
SELECT
	*
FROM
	gold.fact_sales f
LEFT JOIN
	gold.dim_customers c ON f.customer_key = c.customer_key
LEFT JOIN
	gold.dim_products p ON f.product_key = p.product_key
WHERE
	p.product_key IS NULL;
