--USE TRANSACT_SQL
--SELECT * FROM INFORMATION_SCHEMA.TABLES


----------------------------------ADD_CUSTOMER---------------------------------------

IF OBJECT_ID('ADD_CUSTOMER') IS NOT NULL
    DROP PROCEDURE ADD_CUSTOMER;

GO

CREATE PROCEDURE ADD_CUSTOMER @pcustid INT, @pcustname NVARCHAR(100) AS
BEGIN
    BEGIN TRY

        IF @pcustid < 1 OR @pcustid > 499
            THROW 50020, 'Customer ID out of range', 1

        INSERT INTO CUSTOMER (CUSTID, CUSTNAME, SALES_YTD, STATUS) 
        VALUES (@pcustid, @pcustname, 0, 'OK');

    END TRY
    BEGIN CATCH

        IF ERROR_NUMBER() = 2627
            THROW 50010, 'Duplicate customer ID', 1
        ELSE IF ERROR_NUMBER() = 50020
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END

    END CATCH
END

GO

-- SELECT * FROM CUSTOMER
-- DELETE FROM CUSTOMER

-- EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'a';
-- EXEC ADD_CUSTOMER @pcustid = 2, @pcustname = 'b';
-- EXEC ADD_CUSTOMER @pcustid = 0, @pcustname = 'c';
-- EXEC ADD_CUSTOMER @pcustid = 500, @pcustname = 'd';
-- EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'e';


----------------------------------DELETE_ALL_CUSTOMERS---------------------------------------

IF OBJECT_ID('DELETE_ALL_CUSTOMERS') IS NOT NULL
    DROP PROCEDURE DELETE_ALL_CUSTOMERS;

GO

CREATE PROCEDURE DELETE_ALL_CUSTOMERS AS
BEGIN
    DECLARE @ROW_COUNT INT
    BEGIN TRY
        
        DELETE FROM CUSTOMER;
        SET @ROW_COUNT = @@ROWCOUNT

    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1

    END CATCH
    RETURN @ROW_COUNT
END

GO

DECLARE @customers INT
EXEC @customers = DELETE_ALL_CUSTOMERS

SELECT @customers


----------------------------------ADD_PRODUCT---------------------------------------

IF OBJECT_ID('ADD_PRODUCT') IS NOT NULL
    DROP PROCEDURE ADD_PRODUCT;

GO

CREATE PROCEDURE ADD_PRODUCT @pprodid INT, @pprodname NVARCHAR(100), @pprice MONEY AS
BEGIN
    BEGIN TRY
        
        IF @pprodid < 1000 OR @pprodid > 2500
            THROW 50040, 'Product ID out of range', 1
        
        IF @pprice < 0 OR @pprice > 999.99
            THROW 50050, 'Price out of range', 1
        
        INSERT INTO PRODUCT (PRODID, PRODNAME, SELLING_PRICE, SALES_YTD)
        VALUES (@pprodid, @pprodname, @pprice, 0);

    END TRY
    BEGIN CATCH

        IF ERROR_NUMBER() = 2627
            THROW 50030, 'Duplicate product ID', 1
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END

    END CATCH
END

GO

DELETE FROM PRODUCT

EXEC ADD_PRODUCT @pprodid = 1000, @pprodname = "pasta", @pprice = 2

--duplicate primary key check
EXEC ADD_PRODUCT @pprodid = 1000, @pprodname = "pasta", @pprice = 2

--prodid range check
EXEC ADD_PRODUCT @pprodid = 999, @pprodname = "pasta", @pprice = 2
EXEC ADD_PRODUCT @pprodid = 2501, @pprodname = "pasta", @pprice = 2

--price range check
EXEC ADD_PRODUCT @pprodid = 1000, @pprodname = "pasta", @pprice = -1
EXEC ADD_PRODUCT @pprodid = 1000, @pprodname = "pasta", @pprice = 1000

SELECT * FROM PRODUCT