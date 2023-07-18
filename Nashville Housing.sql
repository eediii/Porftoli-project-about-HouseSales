--Changing the date given in the table to a new date format.
SELECT SaleDate, CONVERT(Date, SaleDate) as SaleDateConverted
FROM Nashville

UPDATE Nashville
SET SaleDate = CONVERT(Date, SaleDate)

--Second way(adding new column)
ALTER TABLE Nashville
ADD SaleDateConverted date

UPDATE Nashville
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM Nashville


--Deleting whole column(SaleDate) 
ALTER TABLE Nashville
DROP COLUMN SaleDate


--Change PropertyAdress where parcell ids are same, but not unique id for deleting NULL PropertyAddresses
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville as a
JOIN Nashville as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

SELECT PropertyAddress
FROM Nashville
WHERE PropertyAddress is NULL


--Substring PropertyAddress
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as FirstAdress, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress)) as SecondAdress
FROM Nashville


--Find how many of SalePrices are same
SELECT SalePrice, count(SalePrice)
FROM Nashville
GROUP BY SalePrice
ORDER BY count(SalePrice) desc


--Temp table to find how many location2s are the same.
DROP TABLE IF exists #asd
CREATE TABLE #asd
(
SplitAddress nvarchar(255),
SplitCity nvarchar(50)
)

INSERT INTO #asd
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1), SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress))
FROM Nashville

SELECT SplitCity, COUNT(SplitCity) as NumberOfHouses
FROM #asd
GROUP BY SplitCity
ORDER BY COUNT(SplitCity) desc


--Splittin OwnerAddresses with PARCENAME function
SELECT OwnerAddress
FROM Nashville

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as OwnerSplitAddress,
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as OwnerSplitCity,
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as OwnerSplitState
FROM Nashville

UPDATE Nashville
SET OwnerAddress = REPLACE(OwnerAddress, ',', '.')

ALTER TABLE Nashville
ADD OwnerSplitAddress nvarchar(255)
UPDATE Nashville
SET OwnerSplitAddress = PARSENAME(OwnerAddress, 3)

ALTER TABLE Nashville
ADD OwnerSplitCity nvarchar(255);
UPDATE Nashville
SET OwnerSplitCity = PARSENAME(OwnerAddress, 2)

ALTER TABLE Nashville
ADD OwnerSplitState nvarchar(255)
UPDATE Nashville
SET OwnerSplitState = PARSENAME(OwnerAddress, 1)

SELECT *
FROM Nashville


--Change N and Y into No and Yes in SoldAsVacant column with Case statement
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'N' THEN 'No'
	 WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 ELSE SoldAsVacant
END
FROM Nashville

UPDATE Nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						ELSE SoldAsVacant
				   END

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Nashville
GROUP BY SoldAsVacant


--Delete duplicate sales
WITH RepeatingCTE AS(
SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) as Repeating
FROM Nashville
)
SELECT *
--DELETE
FROM RepeatingCTE
WHERE Repeating > 1