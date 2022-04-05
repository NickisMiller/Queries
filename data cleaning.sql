----- Standardized Date Format ------

select SaleDateConverted, CONVERT(date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
Set SaleDate = CONVERT(date, SaleDate)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
add SaleDateConverted Date;

Update PortfolioProject.dbo.NashvilleHousing
Set SaleDateConverted = CONVERT(date, SaleDate)

------- Populate the Property Address ----------------

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


------put Addresss into seperate columns (Address, City, State)--------

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))

select 
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing



ALTER TABLE PortfolioProject.dbo.NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)


------- Change Y and N to Yes and No in "sold as vacant" column -----

select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end
from PortfolioProject.dbo.NashvilleHousing


update PortfolioProject.dbo.NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end


----------------------- Remove Duplicates -----------------------

with RowNumCTE as(
select *,
	ROW_NUMBER() OVER(
	PARTITION BY  ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY UniqueID) row_num
from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Delete
from RowNumCTE
where row_num>1 



----------------Delete Unused Columns ----------------------

select *
from PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


Alter Table PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate
