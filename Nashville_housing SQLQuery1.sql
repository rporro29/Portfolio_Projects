--- Showing full Data 

Select *
From Dataportfolio..NashvilleHousing

----------------------------

--Cleanup  SaleDates Column

Select SaleDateCoverted, CONVERT(Date,SaleDate)  
From Dataportfolio..NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(Date,SaleDate)

Alter Table NashvilleHousing
add SaleDateCoverted Date;


update NashvilleHousing
set SaleDateCoverted = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;
--------------------------------------
----Diving into more Data, Checking out the property address

Select *
from Dataportfolio..NashvilleHousing
Where PropertyAddress is null 

Select *
from Dataportfolio..NashvilleHousing
Order by ParcelID
---- self join, Clearing nulls 
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Dataportfolio..NashvilleHousing a
join Dataportfolio..NashvilleHousing b
      on a.ParcelID = b.ParcelID
	  and a.[UniqueID ] <> b.[UniqueID ]
Where A.PropertyAddress is null


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Dataportfolio..NashvilleHousing a
join Dataportfolio..NashvilleHousing b
      on a.ParcelID = b.ParcelID
	  and a.[UniqueID ] <> b.[UniqueID ]
Where A.PropertyAddress is null


-----------------------
--- Creating diffent Column from the address column( Address, City, State)
Select PropertyAddress
from Dataportfolio..NashvilleHousing
---Where PropertyAddress is null 

Select 
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as address
from Dataportfolio..NashvilleHousing

--- Getting rid of the comma
Select 
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as address,
Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))as address
from Dataportfolio..NashvilleHousing


Alter Table NashvilleHousing
add PropertySplitAddress Nvarchar(255)


update NashvilleHousing
set PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


Alter Table NashvilleHousing
add PropertySplitCity Nvarchar(255)


update NashvilleHousing
set PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))



Select *
From Dataportfolio..NashvilleHousing



----- Cleaning Owener Address 

Select OwnerAddress
From Dataportfolio..NashvilleHousing


Select 
PARSENAME(Replace(OwnerAddress,',','.'), 3),
PARSENAME(Replace(OwnerAddress,',','.'), 2),
PARSENAME(Replace(OwnerAddress,',','.'), 1)
From Dataportfolio..NashvilleHousing


Alter Table NashvilleHousing
add OwnerSplitAddress Nvarchar(255)


update NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'), 3)


Alter Table NashvilleHousing
add OwnerSplitCity Nvarchar(255)


update NashvilleHousing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'), 2)


Alter Table NashvilleHousing
add OwnerSplitState Nvarchar(255)


update NashvilleHousing
set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'), 1)




Select *
From Dataportfolio..NashvilleHousing


--- Modifing the SoldAsVacant column

Select Distinct(SoldAsVacant), count(SoldAsVacant)
From Dataportfolio..NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
Case when SoldAsVacant = 'Y' THEN 'YES'
     When SoldAsVacant = 'N' THEN 'NO'
     Else SoldAsVacant
	 END
From Dataportfolio..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant =
Case when SoldAsVacant = 'Y' THEN 'YES'
     When SoldAsVacant = 'N' THEN 'NO'
     Else SoldAsVacant
	 END


--- Removing Duplicates

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
					) row_num

From Dataportfolio..NashvilleHousing
--order by ParcelID
)

Select *
from RowNumCTE
Where row_num >1 
order by PropertyAddress




---- Deleting unused Columns ( dont do it to raw data ) 

Select *
From Dataportfolio..NashvilleHousing


Alter Table Dataportfolio.dbo.NashvilleHousing
Drop Column Owneraddress, TaxDistrict, PropertyAddress