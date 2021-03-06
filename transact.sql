--USE TRANSACT_SQL
--SELECT * FROM INFORMATION_SCHEMA.TABLES

--------------------------------------------------------------------------------------------
----------------------------------ADD_CUSTOMER----------------------------------------------
--------------------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------------------
----------------------------------DELETE_ALL_CUSTOMERS--------------------------------------
--------------------------------------------------------------------------------------------


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


-- BEGIN
--     DECLARE @customers INT
--     EXEC @customers = DELETE_ALL_CUSTOMERS

--     PRINT(@customers)
-- END

--------------------------------------------------------------------------------------------
----------------------------------ADD_PRODUCT-----------------------------------------------
--------------------------------------------------------------------------------------------


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

-- DELETE FROM PRODUCT

-- EXEC ADD_PRODUCT @pprodid = 1000, @pprodname = "pasta", @pprice = 2
-- EXEC ADD_PRODUCT @pprodid = 1001, @pprodname = "carrots", @pprice = 3

-- --duplicate primary key check
-- EXEC ADD_PRODUCT @pprodid = 1000, @pprodname = "pasta", @pprice = 2

-- --prodid range check
-- EXEC ADD_PRODUCT @pprodid = 999, @pprodname = "pasta", @pprice = 2
-- EXEC ADD_PRODUCT @pprodid = 2501, @pprodname = "pasta", @pprice = 2

-- --price range check
-- EXEC ADD_PRODUCT @pprodid = 1000, @pprodname = "pasta", @pprice = -1
-- EXEC ADD_PRODUCT @pprodid = 1000, @pprodname = "pasta", @pprice = 1000

-- SELECT * FROM PRODUCT


--------------------------------------------------------------------------------------------
----------------------------------DELETE_ALL_PRODUCTS---------------------------------------
--------------------------------------------------------------------------------------------

IF OBJECT_ID('DELETE_ALL_PRODUCTS') IS NOT NULL
    DROP PROCEDURE DELETE_ALL_PRODUCTS;

GO

CREATE PROCEDURE DELETE_ALL_PRODUCTS AS
BEGIN
    DECLARE @ROW_COUNT INT
    BEGIN TRY
        
        DELETE FROM PRODUCT;
        SET @ROW_COUNT = @@ROWCOUNT

    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1

    END CATCH
    RETURN @ROW_COUNT
END

GO

-- DECLARE @products INT
-- EXEC @products = DELETE_ALL_PRODUCTS

-- SELECT @products


--------------------------------------------------------------------------------------------
----------------------------------GET_CUSTOMER_STRING---------------------------------------
--------------------------------------------------------------------------------------------

IF OBJECT_ID('GET_CUSTOMER_STRING') IS NOT NULL
    DROP PROCEDURE GET_CUSTOMER_STRING;

GO

CREATE PROCEDURE GET_CUSTOMER_STRING @pcustid INT, @pReturnString NVARCHAR(100) OUTPUT AS
BEGIN
    BEGIN TRY
        DECLARE @CustName NVARCHAR(100), @SYTD MONEY, @Status NVARCHAR(7)

        SELECT @CustName = CUSTNAME, @SYTD = SALES_YTD, @Status = [STATUS]
        FROM CUSTOMER
        WHERE CUSTID = @pcustid

        IF @@ROWCOUNT = 0
            THROW 50060, 'Customer ID not found', 1

        SET @pReturnString = CONCAT('Custid: ', @pcustid, ' Name: ', @CustName, ' Status: ', @Status, ' SalesYTD: ', @SYTD)

    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 50060
            THROW
        ELSE
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1

    END CATCH
END

GO


-- BEGIN
--     DECLARE @testOutput NVARCHAR(100);

--     EXEC GET_CUSTOMER_STRING @pcustid = 1, @pReturnString = @testOutput OUTPUT;

--     PRINT(@testOutput);

-- END


--------------------------------------------------------------------------------------------
----------------------------------UPD_CUST_SALESYTD-----------------------------------------
--------------------------------------------------------------------------------------------

IF OBJECT_ID('UPD_CUST_SALESYTD') IS NOT NULL
    DROP PROCEDURE UPD_CUST_SALESYTD;

GO

CREATE PROCEDURE UPD_CUST_SALESYTD @pcustid INT, @pamt MONEY AS
BEGIN
    BEGIN TRY

        UPDATE CUSTOMER
        SET SALES_YTD += @pamt
        WHERE CUSTID = @pcustid

        IF @@ROWCOUNT = 0
            THROW 50070, 'Customer ID not found', 1
        IF @pamt < -999.99 OR @pamt > 999.99
            THROW 50080, 'Amount out of range', 1

    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (50070, 50080)
            THROW
        ELSE
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1

    END CATCH
END

GO

-- BEGIN
--     EXEC UPD_CUST_SALESYTD @pcustid = 1, @pamt = 20;
--     --cust does not exist check
--     EXEC UPD_CUST_SALESYTD @pcustid = 0, @pamt = 10;
--     --amt range check
--     EXEC UPD_CUST_SALESYTD @pcustid = 1, @pamt = -1000;
--     EXEC UPD_CUST_SALESYTD @pcustid = 1, @pamt = 1000;
-- END

--------------------------------------------------------------------------------------------
----------------------------------GET_PROD_STRING-------------------------------------------
--------------------------------------------------------------------------------------------

IF OBJECT_ID('GET_PROD_STRING') IS NOT NULL
    DROP PROCEDURE GET_PROD_STRING;

GO

CREATE PROCEDURE GET_PROD_STRING @pprodid INT, @pReturnString NVARCHAR(100) OUTPUT AS
BEGIN
    BEGIN TRY
        DECLARE @ProdName NVARCHAR(100), @Price MONEY, @SYTD MONEY

        SELECT @ProdName = PRODNAME, @Price = SELLING_PRICE, @SYTD = SALES_YTD
        FROM PRODUCT
        WHERE PRODID = @pprodid

        IF @@ROWCOUNT = 0
            THROW 50060, 'Product ID not found', 1

        SET @pReturnString = CONCAT('Prodid: ', @pprodid, ' Name: ', @ProdName, ' Price: ', @Price, ' SalesYTD: ', @SYTD)

    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 50060
            THROW
        ELSE
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1

    END CATCH
END

GO


-- BEGIN
--     DECLARE @testOutput NVARCHAR(100);

--     EXEC GET_PROD_STRING @pprodid = 1000, @pReturnString = @testOutput OUTPUT;

--     PRINT(@testOutput);

-- END

--------------------------------------------------------------------------------------------
----------------------------------UPD_PROD_SALESYTD-----------------------------------------
--------------------------------------------------------------------------------------------

IF OBJECT_ID('UPD_PROD_SALESYTD') IS NOT NULL
    DROP PROCEDURE UPD_PROD_SALESYTD;

GO

CREATE PROCEDURE UPD_PROD_SALESYTD @pprodid INT, @pamt MONEY AS
BEGIN
    BEGIN TRY

        UPDATE PRODUCT
        SET SALES_YTD += @pamt
        WHERE PRODID = @pprodid

        IF @@ROWCOUNT = 0
            THROW 50070, 'Product ID not found', 1
        IF @pamt < -999.99 OR @pamt > 999.99
            THROW 50080, 'Amount out of range', 1

    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (50070, 50080)
            THROW
        ELSE
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1

    END CATCH
END

GO

-- BEGIN
--     EXEC UPD_PROD_SALESYTD @pprodid = 1000, @pamt = 20;
--     --prod does not exist check
--     EXEC UPD_PROD_SALESYTD @pprodid = 0, @pamt = 10;
--     --amt range check
--     EXEC UPD_PROD_SALESYTD @pprodid = 1000, @pamt = -1000;
--     EXEC UPD_PROD_SALESYTD @pprodid = 1000, @pamt = 1000;
-- END

--------------------------------------------------------------------------------------------
----------------------------------UPD_CUSTOMER_STATUS---------------------------------------
--------------------------------------------------------------------------------------------

IF OBJECT_ID('UPD_CUSTOMER_STATUS') IS NOT NULL
    DROP PROCEDURE UPD_CUSTOMER_STATUS

GO

CREATE PROCEDURE UPD_CUSTOMER_STATUS @pcustid INT, @pstatus NVARCHAR(7) AS
BEGIN
    BEGIN TRY

        IF @pstatus <> 'OK' AND @pstatus <> 'SUSPEND'
            THROW 50130, 'Invalid Status value', 1

        UPDATE CUSTOMER
        SET [STATUS] = @pstatus
        WHERE CUSTID = @pcustid

        IF @@ROWCOUNT = 0
            THROW 50120, 'Customer ID not found', 1

    END TRY
    BEGIN CATCH

        IF ERROR_NUMBER() IN (50120, 50130)
            THROW
        ELSE
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1

    END CATCH
END

GO

-- BEGIN
--     EXEC UPD_CUSTOMER_STATUS @pcustid = 1, @pstatus = 'OK'
--     EXEC UPD_CUSTOMER_STATUS @pcustid = 2, @pstatus = 'SUSPEND'
--     --invalid status check
--     EXEC UPD_CUSTOMER_STATUS @pcustid = 2, @pstatus = 'fbewiuauohef'
--     --cust id not found check
--     EXEC UPD_CUSTOMER_STATUS @pcustid = 453125432, @pstatus = 'OK'
-- END


--------------------------------------------------------------------------------------------
----------------------------------ADD_SIMPLE_SALE-------------------------------------------
--------------------------------------------------------------------------------------------

IF OBJECT_ID('ADD_SIMPLE_SALE') IS NOT NULL
    DROP PROCEDURE ADD_SIMPLE_SALE

GO

CREATE PROCEDURE ADD_SIMPLE_SALE @pcustid INT, @pprodid INT, @pqty INT AS
BEGIN
    BEGIN TRY
        DECLARE @price INT, @ytdValue INT

        IF @pqty < 1 OR @pqty > 999
            THROW 50140, 'Sale Quantity outside valid range', 1

        IF (SELECT [STATUS] FROM CUSTOMER WHERE CUSTID = @pcustid) <> 'OK'
            THROW 50150, 'Customer status is not OK', 1
        
        IF NOT EXISTS(SELECT * FROM CUSTOMER WHERE CUSTID = @pcustid)
            THROW 50160, 'Customer ID not found', 1
        
        IF NOT EXISTS(SELECT * FROM PRODUCT WHERE PRODID = @pprodid)
            THROW 50170, 'Product ID not found', 1

        SELECT @price = SELLING_PRICE
        FROM PRODUCT
        WHERE PRODID = @pprodid

        SET @ytdValue = @pqty * @price

        EXEC UPD_CUST_SALESYTD @pcustid = @pcustid, @pamt = @ytdValue
        EXEC UPD_PROD_SALESYTD @pprodid = @pprodid, @pamt = @ytdValue

    END TRY
    BEGIN CATCH

        IF ERROR_NUMBER() IN (50140, 50150, 50160, 50170)
            THROW
        ELSE
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1

    END CATCH
END

GO

-- BEGIN 
--     EXEC ADD_SIMPLE_SALE @pcustid = 1, @pprodid = 1000, @pqty = 2
--     EXEC ADD_SIMPLE_SALE @pcustid = 2, @pprodid = 1000, @pqty = 12

--     --custid check
--     EXEC ADD_SIMPLE_SALE @pcustid = 0, @pprodid = 1000, @pqty = 2
--     --prodid check
--     EXEC ADD_SIMPLE_SALE @pcustid = 1, @pprodid = 0, @pqty = 2
--     --qty range check
--     EXEC ADD_SIMPLE_SALE @pcustid = 1, @pprodid = 1000, @pqty = 0
--     EXEC ADD_SIMPLE_SALE @pcustid = 1, @pprodid = 1000, @pqty = 1000
--     --status OK check
--     EXEC UPD_CUSTOMER_STATUS @pcustid = 1, @pstatus = 'SUSPEND'
--     EXEC UPD_CUSTOMER_STATUS @pcustid = 1, @pstatus = 'OK'
--     EXEC ADD_SIMPLE_SALE @pcustid = 1, @pprodid = 1000, @pqty = 2
-- END


--------------------------------------------------------------------------------------------
----------------------------------SUM_CUSTOMER_SALESYTD-------------------------------------
--------------------------------------------------------------------------------------------

IF OBJECT_ID('SUM_CUSTOMER_SALESYTD') IS NOT NULL
    DROP PROCEDURE SUM_CUSTOMER_SALESYTD

GO

CREATE PROCEDURE SUM_CUSTOMER_SALESYTD AS
BEGIN
    BEGIN TRY
        DECLARE @SUM INT

        SELECT @SUM = SUM(SALES_YTD)
        FROM CUSTOMER

    END TRY
    BEGIN CATCH

        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1

    END CATCH
    RETURN @SUM
END

GO

-- BEGIN
--     DECLARE @SUM_CUST_SALES INT
--     EXEC @SUM_CUST_SALES = SUM_CUSTOMER_SALESYTD
--     PRINT(@SUM_CUST_SALES)
-- END

--------------------------------------------------------------------------------------------
----------------------------------SUM_PRODUCT_SALESYTD--------------------------------------
--------------------------------------------------------------------------------------------

IF OBJECT_ID('SUM_PRODUCT_SALESYTD') IS NOT NULL
    DROP PROCEDURE SUM_PRODUCT_SALESYTD

GO

CREATE PROCEDURE SUM_PRODUCT_SALESYTD AS
BEGIN
    BEGIN TRY
        DECLARE @SUM INT

        SELECT @SUM = SUM(SALES_YTD)
        FROM PRODUCT

    END TRY
    BEGIN CATCH

        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1

    END CATCH
    RETURN @SUM
END

GO

-- SELECT * FROM PRODUCT
-- BEGIN
--     DECLARE @SUM_PROD_SALES INT
--     EXEC @SUM_PROD_SALES = SUM_PRODUCT_SALESYTD
--     PRINT(@SUM_PROD_SALES)
-- END


--------------------------------------------------------------------------------------------
----------------------------------GET_ALL_CUSTOMERS-----------------------------------------
--------------------------------------------------------------------------------------------

IF OBJECT_ID('GET_ALL_CUSTOMERS') IS NOT NULL
    DROP PROCEDURE GET_ALL_CUSTOMERS

GO

CREATE PROCEDURE GET_ALL_CUSTOMERS @POUTCUR CURSOR VARYING OUTPUT AS
BEGIN
    BEGIN TRY
        SET @POUTCUR = CURSOR
        FORWARD_ONLY STATIC FOR
        SELECT * FROM CUSTOMER
        OPEN @POUTCUR

    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END CATCH
END


--------------------------------------------------------------------------------------------
----------------------------------GET_ALL_PRODUCTS------------------------------------------
--------------------------------------------------------------------------------------------

IF OBJECT_ID('GET_ALL_PRODUCTS') IS NOT NULL
    DROP PROCEDURE GET_ALL_PRODUCTS

GO

CREATE PROCEDURE GET_ALL_PRODUCTS @POUTCUR CURSOR VARYING OUTPUT AS
BEGIN
    BEGIN TRY
        SET @POUTCUR = CURSOR
        FORWARD_ONLY STATIC FOR
        SELECT * FROM PRODUCT
        OPEN @POUTCUR

    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END CATCH
END


--------------------------------------------------------------------------------------------
----------------------------------ADD_LOCATION----------------------------------------------
--------------------------------------------------------------------------------------------

IF OBJECT_ID('ADD_LOCATION') IS NOT NULL
    DROP PROCEDURE ADD_LOCATION

GO

CREATE PROCEDURE ADD_LOCATION @ploccode NVARCHAR(MAX), @pminqty INT, @pmaxqty INT AS
BEGIN
    BEGIN TRY
        --could not find how to check if a constraint check failed
        IF LEN(@ploccode) <> 5
            THROW 50190, 'Location Code length invalid', 1
        ELSE IF @pminqty < 0 OR @pminqty > 999
            THROW 50200, 'Minimum Qty out of range', 1
        ELSE IF @pmaxqty < 0 OR @pmaxqty > 999
            THROW 50210, 'Maximum Qty out of range', 1
        ELSE IF @pminqty > @pmaxqty
            THROW 50220, 'Minimum Qty larger than Maximum Qty', 1

        INSERT INTO LOCATION (LOCID, MINQTY, MAXQTY) 
        VALUES (@ploccode, @pminqty, @pmaxqty);

    END TRY
    BEGIN CATCH

        IF ERROR_NUMBER() = 2627
            THROW 50180, 'Duplicate location ID', 1
        ELSE IF ERROR_NUMBER() IN (50190, 50200, 50210, 50220)
            THROW
        ELSE
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1

    END CATCH
END

GO

-- DELETE FROM LOCATION
-- SELECT * FROM LOCATION;

-- EXEC ADD_LOCATION @ploccode = "aaa11", @pminqty = 5, @pmaxqty = 10;
-- EXEC ADD_LOCATION @ploccode = "aaa22", @pminqty = 5, @pmaxqty = 10;
-- EXEC ADD_LOCATION @ploccode = "aaaaa", @pminqty = 11, @pmaxqty = 10;
-- EXEC ADD_LOCATION @ploccode = 'aaaaa', @pminqty = 10, @pmaxqty = 115;


--------------------------------------------------------------------------------------------
----------------------------------ADD_COMPLEX_SALE------------------------------------------
--------------------------------------------------------------------------------------------

IF OBJECT_ID('ADD_COMPLEX_SALE') IS NOT NULL
    DROP PROCEDURE ADD_COMPLEX_SALE

GO

CREATE PROCEDURE ADD_COMPLEX_SALE @pcustid INT, @pprodid INT, @pqty INT, @pdate NVARCHAR(MAX) AS
BEGIN
    DECLARE @price MONEY
    DECLARE @ytdValue MONEY
    BEGIN TRY

        IF @pqty < 1 OR @pqty > 999
            THROW 50230, 'Sale Quantity outside valid range', 1
        ELSE IF (SELECT [STATUS] FROM CUSTOMER WHERE CUSTID = @pcustid) <> 'OK'
            THROW 50240, 'Customer status is not OK', 1
        ELSE IF ISDATE(@pdate) = 0
            THROW 50250, 'Date not valid', 1
        ELSE IF NOT EXISTS(SELECT * FROM CUSTOMER WHERE CUSTID = @pcustid)
            THROW 50260, 'Customer ID not found', 1
        ELSE IF NOT EXISTS(SELECT * FROM PRODUCT WHERE PRODID = @pprodid)
            THROW 50270, 'Product ID not found', 1

        SELECT @price = SELLING_PRICE FROM PRODUCT WHERE PRODID = @pprodid;

        INSERT INTO SALE (SALEID, CUSTID, PRODID, QTY, PRICE, SALEDATE) VALUES
        (NEXT VALUE FOR SALE_SEQ, @pcustid, @pprodid, @pqty, @price, @pdate);

        SELECT @price = SELLING_PRICE
        FROM PRODUCT
        WHERE PRODID = @pprodid

        SET @ytdValue = @pqty * @price

        EXEC UPD_CUST_SALESYTD @pcustid = @pcustid, @pamt = @ytdValue
        EXEC UPD_PROD_SALESYTD @pprodid = @pprodid, @pamt = @ytdValue

    END TRY
    BEGIN CATCH

        IF ERROR_NUMBER() IN (50230, 50240, 50250, 50260, 50270)
            THROW
        ELSE
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1

    END CATCH
END

GO

-- --test data
-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 1000, @pqty = 3, @pdate = '2021/08/13'
-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 1000, @pqty = 3, @pdate = '2021/08/13'

-- --check valid cust and prop id
-- EXEC ADD_COMPLEX_SALE @pcustid = 321, @pprodid = 1000, @pqty = 3, @pdate = '2021/08/13'
-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 23, @pqty = 3, @pdate = '2021/08/13'
-- --qty range check
-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 1000, @pqty = 0, @pdate = '2021/08/13'
-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 1000, @pqty = 1000, @pdate = '2021/08/13'
-- --check valid date
-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 1000, @pqty = 1, @pdate = 'fgrewstrew'

-- DELETE FROM SALE
-- SELECT * FROM SALE


--------------------------------------------------------------------------------------------
----------------------------------GET_ALL_SALES---------------------------------------------
--------------------------------------------------------------------------------------------

IF OBJECT_ID('GET_ALL_SALES') IS NOT NULL
    DROP PROCEDURE GET_ALL_SALES

GO

CREATE PROCEDURE GET_ALL_SALES @POUTCUR CURSOR VARYING OUTPUT AS
BEGIN
    BEGIN TRY
        SET @POUTCUR = CURSOR
        FORWARD_ONLY STATIC FOR
        SELECT * FROM SALE
        OPEN @POUTCUR

    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END CATCH
END


--------------------------------------------------------------------------------------------
----------------------------------COUNT_PRODUCT_SALES---------------------------------------
--------------------------------------------------------------------------------------------

IF OBJECT_ID('COUNT_PRODUCT_SALES') IS NOT NULL
    DROP PROCEDURE COUNT_PRODUCT_SALES

GO

CREATE PROCEDURE COUNT_PRODUCT_SALES @pdays INT AS
BEGIN
    DECLARE @numSales INT
    BEGIN TRY
        SELECT @numSales = COUNT(*)
        FROM SALE
        WHERE DATEDIFF(day, SALEDATE, GETDATE()) BETWEEN 0 AND @pdays
    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END CATCH
    RETURN @numSales
END


--test data
-- DELETE FROM SALE

-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 1000, @pqty = 3, @pdate = '2021/08/12'
-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 1000, @pqty = 3, @pdate = '2021/08/11'
-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 1000, @pqty = 3, @pdate = '2021/08/10'
-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 1000, @pqty = 3, @pdate = '2021/08/9'
-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 1000, @pqty = 3, @pdate = '2021/08/8'

-- SELECT * FROM SALE

-- BEGIN
--     DECLARE @sales INT
--     EXEC @sales = COUNT_PRODUCT_SALES @pdays = 3
--     PRINT(@sales)
-- END


--------------------------------------------------------------------------------------------
----------------------------------DELETE_SALE-----------------------------------------------
--------------------------------------------------------------------------------------------

IF OBJECT_ID('DELETE_SALE') IS NOT NULL
    DROP PROCEDURE DELETE_SALE

GO

CREATE PROCEDURE DELETE_SALE @saleid BIGINT OUTPUT AS
BEGIN
    DECLARE @custid INT, @prodid INT, @price INT, @qty INT, @amt INT
    BEGIN TRY
        SELECT @saleid = SALEID, @custid = CUSTID, @prodid = PRODID, @price = PRICE, @qty = QTY
        FROM SALE
        WHERE SALEID = (SELECT MIN(SALEID) FROM SALE)

        IF @@ROWCOUNT = 0
            THROW 50280, 'No Sale Rows Found', 1;

        SET @amt = -1 * (@price * @qty)
        EXEC UPD_CUST_SALESYTD @pcustid = @custid, @pamt = @amt
        EXEC UPD_PROD_SALESYTD @pprodid = @prodid, @pamt = @amt

        DELETE FROM SALE
        WHERE SALEID = (SELECT MIN(SALEID) FROM SALE)

        IF @@ROWCOUNT = 0
            THROW 50280, 'No Sale Rows Found', 1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 50280
            THROW
        ELSE
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
    END CATCH
END

GO

-- DELETE FROM SALE
-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 1000, @pqty = 3, @pdate = '2021/08/12'
-- SELECT * FROM SALE

-- BEGIN
-- DECLARE @saleid BIGINT
-- EXEC DELETE_SALE @saleid = @saleid OUTPUT
-- PRINT(@saleid)
-- END


--------------------------------------------------------------------------------------------
----------------------------------DELETE_ALL_SALES------------------------------------------
--------------------------------------------------------------------------------------------

IF OBJECT_ID('DELETE_ALL_SALES') IS NOT NULL
    DROP PROCEDURE DELETE_ALL_SALES

GO

CREATE PROCEDURE DELETE_ALL_SALES  AS
BEGIN
    BEGIN TRY
        DELETE FROM SALE

        UPDATE CUSTOMER
        SET SALES_YTD = 0;

        UPDATE PRODUCT
        SET SALES_YTD = 0;

    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END CATCH
END

GO

-- EXEC DELETE_ALL_SALES


--------------------------------------------------------------------------------------------
----------------------------------DELETE_CUSTOMER-------------------------------------------
--------------------------------------------------------------------------------------------

IF OBJECT_ID('DELETE_CUSTOMER') IS NOT NULL
    DROP PROCEDURE DELETE_CUSTOMER

GO

CREATE PROCEDURE DELETE_CUSTOMER @pcustid INT AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS(SELECT * FROM CUSTOMER WHERE CUSTID = @pcustid)
            THROW 50290, 'Customer ID not found', 1
        IF EXISTS(SELECT * FROM SALE WHERE CUSTID = @pcustid)
            THROW 50300, 'Customer cannot be deleted as sales exist', 1
        DELETE FROM CUSTOMER WHERE CUSTID = @pcustid

    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (50290, 50300)
            THROW
        ELSE
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
    END CATCH
END

GO

-- EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'a';
-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 1000, @pqty = 3, @pdate = '2021/08/12'
-- SELECT * FROM CUSTOMER
-- SELECT * FROM SALE

-- --test
-- EXEC DELETE_ALL_SALES
-- EXEC DELETE_CUSTOMER @pcustid = 1
-- --custid exists check
-- EXEC DELETE_CUSTOMER @pcustid = 10
-- --complex sale exists check
-- EXEC DELETE_CUSTOMER @pcustid = 1


--------------------------------------------------------------------------------------------
----------------------------------DELETE_PRODUCT--------------------------------------------
--------------------------------------------------------------------------------------------

IF OBJECT_ID('DELETE_PRODUCT') IS NOT NULL
    DROP PROCEDURE DELETE_PRODUCT

GO

CREATE PROCEDURE DELETE_PRODUCT @pprodid INT AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS(SELECT * FROM PRODUCT WHERE PRODID = @pprodid)
            THROW 50310, 'Product ID not found', 1
        IF EXISTS(SELECT * FROM SALE WHERE PRODID = @pprodid)
            THROW 50320, 'Product cannot be deleted as sales exist', 1
        DELETE FROM PRODUCT WHERE PRODID = @pprodid

    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (50290, 50300)
            THROW
        ELSE
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
    END CATCH
END

GO

-- EXEC ADD_PRODUCT @pprodid = 1000, @pprodname = "pasta", @pprice = 2
-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 1000, @pqty = 3, @pdate = '2021/08/12'
-- SELECT * FROM PRODUCT
-- SELECT * FROM SALE

-- --test
-- EXEC DELETE_ALL_SALES
-- EXEC DELETE_PRODUCT @pprodid = 1000
-- --prodid exists check
-- EXEC DELETE_PRODUCT @pprodid = 10
-- --complex sale exists check
-- EXEC DELETE_PRODUCT @pprodid = 1000