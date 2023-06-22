--Cleaning data in sql Queries
select*
from DataCleaning

--standardize date format

select saledate, convert(date, saledate)
from DataCleaning

update DataCleaning
set SaleDate = convert(date, saledate)

alter table DataCleaning
alter column SaleDate date

--Populate property address

select *
from DataCleaning
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from DataCleaning a
join DataCleaning b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress =  isnull(a.PropertyAddress, b.PropertyAddress)
from DataCleaning a
join DataCleaning b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out address into indivual columns (address, city, state)

select PropertyAddress
from DataCleaning

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as address,
substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))
from DataCleaning

alter table DataCleaning
add PropertySplitAddress nvarchar(255)

update DataCleaning
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

alter table DataCleaning
add PropertySplitCity nvarchar(255)

update DataCleaning
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))

--select PropertySplitAddress + space(1) + PropertySplitCity
--from DataCleaning

select 
parsename(replace(Owneraddress,',','.'),3),
parsename(replace(Owneraddress,',','.'),2),
parsename(replace(Owneraddress,',','.'),1), 
from DataCleaning

alter table DataCleaning
add OwnerSplitAddress nvarchar(255)

alter table DataCleaning
add OwnerSplitCity nvarchar(255)

alter table DataCleaning
add OwnerSplitState nvarchar(255)

update DataCleaning
set Owneraddress = parsename(replace(Owneraddress,',','.'),3)

update DataCleaning
set OwnerSplitCity = parsename(replace(Owneraddress,',','.'),2)

update DataCleaning
set OwnerSplitState = parsename(replace(Owneraddress,',','.'),1)

select *
from DataCleaning

--change Y and N in sold as vacant filed

select distinct(soldasvacant), count(soldasvacant)
from DataCleaning
group by soldasvacant
order by 2

select soldasvacant,
case when soldasvacant = 'Y' then 'Yes'
     when soldasvacant = 'N' then 'No'
	 else soldasvacant
	 end
from DataCleaning

update DataCleaning
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
     when soldasvacant = 'N' then 'No'
	 else soldasvacant
	 end

--Remove Duplicates
with RowNumCTE as( 
select *, 
row_number() over( partition by parcelID, 
                                propertyAddress,
								Saleprice,
								Saledate,
								LegalReference
								order by UniqueID ) row_num
from DataCleaning)
Select*
from RowNumCTE
where row_num > 1
--order by PropertyAddress

-- Delete unused columns
select *
from DataCleaning

alter table DataCleaning
drop column Owneraddress, TaxDistrict, PropertyAddress

alter table DataCleaning
drop column SaleDate