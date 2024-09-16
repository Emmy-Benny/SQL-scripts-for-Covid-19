--Cleaning Data in SQL Queries

Select *
From PortfolioProjects.dbo.NashvilleHousing

--Standardize Date Format

Select SaleDateConverted, Convert(Date,SaleDate)
From PortfolioProjects.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = convert(date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDate = convert(date,SaleDate)

--Populate Property Address Data
Select PropertyAddress
From PortfolioProjects.dbo.NashvilleHousing
Where PropertyAddress is Null

Select *
From PortfolioProjects.dbo.NashvilleHousing
--Where PropertyAddress is Null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProjects.dbo.NashvilleHousing a
Join PortfolioProjects.dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjects.dbo.NashvilleHousing a
Join PortfolioProjects.dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjects.dbo.NashvilleHousing a
Join PortfolioProjects.dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

--Breaking Address into Individual columns (Address, City,State)

Select PropertyAddress
From PortfolioProjects.dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From PortfolioProjects.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255),

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Select *
From PortfolioProjects.dbo.NashvilleHousing

Select OwnerAddress
From PortfolioProjects.dbo.NashvilleHousing


Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 
From PortfolioProjects.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


Select *
From PortfolioProjects.dbo.NashvilleHousing

--Change Y and N to YES and NO in ''Sold as Vacant'' field

Select Distinct(SoldAsVacant)
From PortfolioProjects.dbo.NashvilleHousing

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProjects.dbo.NashvilleHousing
Group By SoldAsVacant
Order by 2

Select SoldAsVacant,
Case when SoldAsVacant = 'Y' Then 'YES'
	when SoldAsVacant = 'N' Then 'NO'
	Else SoldAsVacant 
	END
From PortfolioProjects.dbo.NashvilleHousing

--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order By
					UniqueID) row_num
From PortfolioProjects.dbo.NashvilleHousing
--Order By ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

--Delete Unusual Columns

Select *
From PortfolioProjects.dbo.NashvilleHousing

Alter Table PortfolioProjects.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProjects.dbo.NashvilleHousing
Drop Column SaleDate