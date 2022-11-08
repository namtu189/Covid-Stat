/*
Cleaning Data in SQL Queries
*/


SELECT *
FROM PortfolioProject.dbo.nashvillehousing
--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


ALTER TABLE nashvillehousing
ADD saledateconverted date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM PortfolioProject.dbo.nashvillehousing
ORDER BY ParcelID;

--Use self join to assign property address to parcelID
SELECT n1.parcelID, n1.propertyaddress, n2.parcelID, n2.propertyaddress, ISNULL(n1.propertyaddress, n2.propertyaddress) AS truepropertyaddress
FROM PortfolioProject.dbo.NashvilleHousing AS n1
JOIN PortfolioProject.dbo.NashvilleHousing AS n2
	ON n1.parcelID = n2.parcelID
	AND n1.uniqueid <> n2.uniqueid
WHERE n1.propertyaddress IS NULL

UPDATE n1
SET propertyaddress = ISNULL(n1.propertyaddress, n2.propertyaddress)
FROM PortfolioProject.dbo.NashvilleHousing AS n1
JOIN PortfolioProject.dbo.NashvilleHousing AS n2
	ON n1.parcelID = n2.parcelID
	AND n1.uniqueid <> n2.uniqueid
WHERE n1.propertyaddress IS NULL


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT SUBSTRING(propertyaddress,1,CHARINDEX(',', propertyaddress) -1) AS address,
SUBSTRING (propertyaddress, CHARINDEX(',', propertyaddress) +1, LEN(propertyaddress)) AS city
--SUBSTRING (propertyaddress, LEN(propertyaddress)-2, LEN(propertyaddress)) AS State
From PortfolioProject.dbo.NashvilleHousing

--Update table
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))



--Check table
Select *
From PortfolioProject.dbo.NashvilleHousing;

-- Break owner address to address, city, State
Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing;


SELECT
PARSENAME(REPLACE(owneraddress,',','.'), 3),
PARSENAME(REPLACE(owneraddress,',','.'), 2),
PARSENAME(REPLACE(owneraddress,',','.'), 1)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(owneraddress,',','.'), 3);

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject.dbo.NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH rownumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY parcelid,
				propertyaddress,
				saleprice,
				legalreference,
					saledate
				ORDER BY uniqueid
				) as row_num

FROM PortfolioProject.dbo.NashvilleHousing
)
DELETE
FROM rownumCTE
WHERE row_num > 1


WITH rownumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY parcelid,
				propertyaddress,
				saleprice,
				legalreference,
					saledate
				ORDER BY uniqueid
				) as row_num

FROM PortfolioProject.dbo.NashvilleHousing
)
SELECT*
FROM rownumCTE
WHERE row_num > 1;



Select *
From PortfolioProject.dbo.NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, saledate

















-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
