/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject.dbo.[Nashville Housing$]



-- Standardize Data Format
Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.[Nashville Housing$]

Update [Nashville Housing$]
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE [NashvilleHousing$]
ADD SaleDateConverted Date;

Update [Nashville Housing$]
SET SaleDateConverted = CONVERT(Date, SaleDate)



-- Populate Property Addtess Date
Select *
From PortfolioProject.dbo.[Nashville Housing$]
-- Where PropertyAddress IS NULL
Order By ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.[Nashville Housing$] AS a
JOIN PortfolioProject.dbo.[Nashville Housing$] AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress IS NULL

Update a
SET propertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.[Nashville Housing$] AS a
JOIN PortfolioProject.dbo.[Nashville Housing$] AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress IS NULL



-- Breaking Out Property Address into Individual Columns (Address, City, State)
Select propertyAddress
From PortfolioProject.dbo.[Nashville Housing$]
-- Where PropertyAddress IS NULL
-- Order By ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
From PortfolioProject.dbo.[Nashville Housing$]

ALTER TABLE [Nashville Housing$]
ADD PropertySplitAddress NVARCHAR(255);

Update [Nashville Housing$]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE [Nashville Housing$]
ADD PropertySplitCity Date;

Update [Nashville Housing$]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



-- Another Method for Breaking Out Owner Address into Individual Columns (Address, City, State)
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.[Nashville Housing$]

ALTER TABLE [Nashville Housing$]
ADD OwnerSplitAddress NVARCHAR(255);

Update [Nashville Housing$]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [Nashville Housing$]
ADD OwnerSplitCity Date;

Update [Nashville Housing$]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [Nashville Housing$]
ADD PropertySplitState Date;

Update [Nashville Housing$]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



-- Change 'Y' and 'N' to 'Yes' and 'No' in "Sold as Vacant" Field
Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.[Nashville Housing$]
Group By SoldAsVacant
Order By 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END
From PortfolioProject.dbo.[Nashville Housing$]

Update [Nashville Housing$]
SET SoldAsVacant =
  CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END



-- Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) AS row_num

From PortfolioProject.dbo.[Nashville Housing$]
-- Order By ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
-- Order By PropertyAddress

Select *
From PortfolioProject.dbo.[Nashville Housing$]



-- Delete Unused Column
ALTER TABLE PortfolioProject.dbo.[Nashville Housing$]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.[Nashville Housing$]
DROP COLUMN SaleDate

Select *
From PortfolioProject.dbo.[Nashville Housing$]

