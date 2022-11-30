select *
from NashvilleHousing

select *
from NashvilleHousing

--Standardise date format
select SaleDate
from NashvilleHousing

update NashvilleHousing
SET SaleDate = Convert(Date,SaleDate)


-- Populate property address data
Select PropertyAddress
from NashvilleHousing

-- Identifying the number of rows with a NULL value in the PropertyAddress variable
select *
from NashvilleHousing
Where PropertyAddress is null

-- Populating the missing property address with data corresponding to the Parcel ID variable (The ParcelID variable has a corresponding address variable that can replace the NULLs)
Select a.ParcelID, a.PropertyAddress, b.ParcelId, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) as TestAddress
From NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID<>b.UniqueID
Where a.PropertyAddress is null

-- Now that I have tested the replacement address will work I can go ahead and update the table
Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID<>b.UniqueID
Where a.PropertyAddress is null

-- Seperating PropertyAddress into Address, City, State (Now there are no NULLS in PropertyAddress but the way it is written (eg. "StreetNumber, Street, City, State")
-- still needs to be seperated into a more usable series of variables

Select PropertyAddress
from NashvilleHousing

Select
-- The "1" means start at position 1 of PropertyAddress. Then it returns everything until CHARINDEX is used to tell it to stop at comma (',') in PropertyAddress
-- Then to not return the comma itself but everything before is a "-1" is used.
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 ) as Address,

-- Here it starts its return at the comman (as indicated by the CHARINDEX command. The +2 is included so it returns everything after the comma and the space after 
-- the comman (i.e. the comman and space is removed leaving only the city)
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +2 , LEN(PropertyAddress)) as Address
FROM NashvilleHousing


-- Then using these commands above, which we've tested to work, to now update the table. Note, you have to run these commands one at a time. If you run them altogether
-- you get an error.

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 )

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +2 , LEN(PropertyAddress))

select *
from NashvilleHousing

-- Seperating OwnerAddress into Address, City, State

Select
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

select *
from NashvilleHousing

Update NashvilleHousing
Set OwnerSplitCity = trim(OwnerSplitCity)

--- Change 0 to 'Yes' and 1 to 'No' in "sold as Vacant"
Select Distinct(SoldAsVacant)
From NashvilleHousing

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant

Select SoldAsVacant
, CASE	When SoldAsVacant = 0 THEN 'Yes'
		ELSE 'No'
		END
From NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE	When SoldAsVacant = '0'  THEN 'Yes'
		ELSE 'No'
		END
From NashvilleHousing


--Remove duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION By ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY
		UniqueID
		) row_num
FROM NashvilleHousing
)
Select *
From RowNumCTE
Where Row_num > 1
Order by PropertyAddress

-- Delete unused columns
Select*
FRom NashvilleHousing
ALTER TABLE NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyADDRESS

ALTER Table NashvilleHousing
Drop Column SaleDate
