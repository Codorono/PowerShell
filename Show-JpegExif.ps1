#=======================================================================================================================

param
(
	[string] $Path,
	[switch] $Map
)

#=======================================================================================================================

Set-StrictMode -Version Latest

#=======================================================================================================================

Set-Variable "PropertyTagGpsLatitudeRef" 0x0001 -Option Constant
Set-Variable "PropertyTagGpsLatitude" 0x0002 -Option Constant
Set-Variable "PropertyTagGpsLongitudeRef" 0x0003 -Option Constant
Set-Variable "PropertyTagGpsLongitude" 0x0004 -Option Constant
Set-Variable "PropertyTagGpsAltitudeRef" 0x0005 -Option Constant
Set-Variable "PropertyTagGpsAltitude" 0x0006 -Option Constant
Set-Variable "PropertyTagEquipMake" 0x010F -Option Constant
Set-Variable "PropertyTagEquipModel" 0x0110 -Option Constant
Set-Variable "PropertyTagSoftwareUsed" 0x0131 -Option Constant
Set-Variable "PropertyTagDateTime" 0x0132 -Option Constant
Set-Variable "PropertyTagExifDTOrig" 0x9003 -Option Constant
Set-Variable "PropertyTagExifDTDigitized" 0x9004 -Option Constant
Set-Variable "PropertyTagExifDTSubsec" 0x9290 -Option Constant
Set-Variable "PropertyTagExifDTOrigSS" 0x9291 -Option Constant
Set-Variable "PropertyTagExifDTDigSS" 0x9292 -Option Constant
Set-Variable "PropertyTagExifPixXDim" 0xA002 -Option Constant
Set-Variable "PropertyTagExifPixYDim" 0xA003 -Option Constant

# create ascii encoding

$ASCIIEncoding = [System.Text.Encoding]::ASCII

# create file stream

$FilePath = (Get-Item $Path).FullName

$FileStream = [System.IO.File]::OpenRead($FilePath)

# create image

$Image = [System.Drawing.Image]::FromStream($FileStream, $false, $false)

# get property id list

$PropertyIdList = $Image.PropertyIdList

# get latitude

if (($PropertyIdList.Contains($PropertyTagGpsLatitudeRef)) -and ($PropertyIdList.Contains($PropertyTagGpsLatitude)))
{
	$PropertyItem = $Image.GetPropertyItem($PropertyTagGpsLatitudeRef)

	if (($PropertyItem.Type -ne 2) -or ($PropertyItem.Len -ne 2))
	{
		throw "Bad GpsLatitudeRef"
	}

	$GpsLatitudeRef = $ASCIIEncoding.GetString($PropertyItem.Value, 0, $PropertyItem.Len - 1)

	"GpsLatitudeRef: {0}" -f $GpsLatitudeRef

	$PropertyItem = $Image.GetPropertyItem($PropertyTagGpsLatitude)

	if (($PropertyItem.Type -ne 5) -or ($PropertyItem.Len -ne 24))
	{
		throw "Bad GpsLatitude"
	}

	$Bytes = $PropertyItem.Value

	$DegreeNum = [System.BitConverter]::ToUInt32($Bytes, 0)
	$DegreeDen = [System.BitConverter]::ToUInt32($Bytes, 4)
	$Degree = [uint] [System.Math]::Round($DegreeNum / $DegreeDen)

	$MinuteNum = [System.BitConverter]::ToUInt32($Bytes, 8)
	$MinuteDen = [System.BitConverter]::ToUInt32($Bytes, 12)
	$Minute = [uint] [System.Math]::Round($MinuteNum / $MinuteDen)

	$SecondNum = [System.BitConverter]::ToUInt32($Bytes, 16)
	$SecondDen = [System.BitConverter]::ToUInt32($Bytes, 20)
	$Second = $SecondNum / $SecondDen

	$Latitude = $Degree
	$Latitude += $Minute / 60
	$Latitude += $Second / 3600

	if ($GpsLatitudeRef -eq "S")
	{
		$Latitude = -$Latitude
	}

	"GpsLatitude: {0}:{1:D2}:{2} ({3})" -f $Degree, $Minute, $Second, $Latitude
}

# get longitude

if (($PropertyIdList.Contains($PropertyTagGpsLongitudeRef)) -and ($PropertyIdList.Contains($PropertyTagGpsLongitude)))
{
	$PropertyItem = $Image.GetPropertyItem($PropertyTagGpsLongitudeRef)

	if (($PropertyItem.Type -ne 2) -or ($PropertyItem.Len -ne 2))
	{
		throw "Bad GpsLongitudeRef"
	}

	$GpsLongitudeRef = $ASCIIEncoding.GetString($PropertyItem.Value, 0, $PropertyItem.Len - 1)

	"GpsLongitudeRef: {0}" -f $GpsLongitudeRef

	$PropertyItem = $Image.GetPropertyItem($PropertyTagGpsLongitude)

	if (($PropertyItem.Type -ne 5) -or ($PropertyItem.Len -ne 24))
	{
		throw "Bad GpsLongitude"
	}

	$Bytes = $PropertyItem.Value

	$DegreeNum = [System.BitConverter]::ToUInt32($Bytes, 0)
	$DegreeDen = [System.BitConverter]::ToUInt32($Bytes, 4)
	$Degree = [uint] [System.Math]::Round($DegreeNum / $DegreeDen)

	$MinuteNum = [System.BitConverter]::ToUInt32($Bytes, 8)
	$MinuteDen = [System.BitConverter]::ToUInt32($Bytes, 12)
	$Minute = [uint] [System.Math]::Round($MinuteNum / $MinuteDen)

	$SecondNum = [System.BitConverter]::ToUInt32($Bytes, 16)
	$SecondDen = [System.BitConverter]::ToUInt32($Bytes, 20)
	$Second = $SecondNum / $SecondDen

	$Longitude = $Degree
	$Longitude += $Minute / 60
	$Longitude += $Second / 3600

	if ($GpsLongitudeRef -eq "W")
	{
		$Longitude = -$Longitude
	}

	"GpsLongitude: {0}:{1:D2}:{2} ({3})" -f $Degree, $Minute, $Second, $Longitude
}

# get altitude

if (($PropertyIdList.Contains($PropertyTagGpsAltitudeRef)) -and ($PropertyIdList.Contains($PropertyTagGpsAltitude)))
{
	$PropertyItem = $Image.GetPropertyItem($PropertyTagGpsAltitudeRef)

	if (($PropertyItem.Type -ne 1) -or ($PropertyItem.Len -ne 1))
	{
		throw "Bad GpsAltitudeRef"
	}

	$GpsAltitudeRef = ($PropertyItem.Value)[0]

	"GpsAltitudeRef: {0}" -f $GpsAltitudeRef

	$PropertyItem = $Image.GetPropertyItem($PropertyTagGpsAltitude)

	if (($PropertyItem.Type -ne 5) -or ($PropertyItem.Len -ne 8))
	{
		throw "Bad GpsAltitude"
	}

	$Bytes = $PropertyItem.Value

	$AltitudeNum = [System.BitConverter]::ToUInt32($Bytes, 0)
	$AltitudeDen = [System.BitConverter]::ToUInt32($Bytes, 4)
	$Altitude = ($AltitudeNum * 1250) / ($AltitudeDen * 381)

	"GpsAltitude: {0}" -f $Altitude
}

# get equip make

if ($PropertyIdList.Contains($PropertyTagEquipMake))
{
	$PropertyItem = $Image.GetPropertyItem($PropertyTagEquipMake)

	if (($PropertyItem.Type -ne 2) -or ($PropertyItem.Len -eq 0))
	{
		throw "Bad EquipMake"
	}

	$EquipMake = $ASCIIEncoding.GetString($PropertyItem.Value, 0, $PropertyItem.Len - 1)

	"EquipMake: {0}" -f $EquipMake
}

# get equip model

if ($PropertyIdList.Contains($PropertyTagEquipModel))
{
	$PropertyItem = $Image.GetPropertyItem($PropertyTagEquipModel)

	if (($PropertyItem.Type -ne 2) -or ($PropertyItem.Len -eq 0))
	{
		throw "Bad EquipModel"
	}

	$EquipModel = $ASCIIEncoding.GetString($PropertyItem.Value, 0, $PropertyItem.Len - 1)

	"EquipModel: {0}" -f $EquipModel
}

# get software used

if ($PropertyIdList.Contains($PropertyTagSoftwareUsed))
{
	$PropertyItem = $Image.GetPropertyItem($PropertyTagSoftwareUsed)

	if (($PropertyItem.Type -ne 2) -or ($PropertyItem.Len -eq 0))
	{
		throw "Bad SoftwareUsed"
	}

	$SoftwareUsed = $ASCIIEncoding.GetString($PropertyItem.Value, 0, $PropertyItem.Len - 1)

	"SoftwareUsed: {0}" -f $SoftwareUsed
}

# get datetime

if ($PropertyIdList.Contains($PropertyTagDateTime))
{
	$PropertyItem = $Image.GetPropertyItem($PropertyTagDateTime)

	if (($PropertyItem.Type -ne 2) -or ($PropertyItem.Len -ne 20))
	{
		throw "Bad DateTime"
	}

	$DateTime = $ASCIIEncoding.GetString($PropertyItem.Value, 0, $PropertyItem.Len - 1)

	# get datetime subsecond

	if ($PropertyIdList.Contains($PropertyTagExifDTSubsec))
	{
		$PropertyItem = $Image.GetPropertyItem($PropertyTagExifDTSubsec)

		if (($PropertyItem.Type -ne 2) -or ($PropertyItem.Len -eq 0))
		{
			throw "Bad DTSubsec"
		}

		$DTSubsec = $ASCIIEncoding.GetString($PropertyItem.Value, 0, $PropertyItem.Len - 1)

		$DateTime += "." + $DTSubsec
	}

	"DateTime: {0}" -f $DateTime
}

# get datetime orig

if ($PropertyIdList.Contains($PropertyTagExifDTOrig))
{
	$PropertyItem = $Image.GetPropertyItem($PropertyTagExifDTOrig)

	if (($PropertyItem.Type -ne 2) -or ($PropertyItem.Len -ne 20))
	{
		throw "Bad DTOrig"
	}

	$DTOrig = $ASCIIEncoding.GetString($PropertyItem.Value, 0, $PropertyItem.Len - 1)

	# get datetime orig subsecond

	if ($PropertyIdList.Contains($PropertyTagExifDTOrigSS))
	{
		$PropertyItem = $Image.GetPropertyItem($PropertyTagExifDTOrigSS)

		if (($PropertyItem.Type -ne 2) -or ($PropertyItem.Len -eq 0))
		{
			throw "Bad DTOrigSS"
		}

		$DTOrigSS = $ASCIIEncoding.GetString($PropertyItem.Value, 0, $PropertyItem.Len - 1)

		$DTOrig += "." + $DTOrigSS
	}

	"DTOrig: {0}" -f $DTOrig
}

# get datetime digitized

if ($PropertyIdList.Contains($PropertyTagExifDTDigitized))
{
	$PropertyItem = $Image.GetPropertyItem($PropertyTagExifDTDigitized)

	if (($PropertyItem.Type -ne 2) -or ($PropertyItem.Len -ne 20))
	{
		throw "Bad DTDigitized"
	}

	$DTDigitized = $ASCIIEncoding.GetString($PropertyItem.Value, 0, $PropertyItem.Len - 1)

	# get datetime digitized subsecond

	if ($PropertyIdList.Contains($PropertyTagExifDTDigSS))
	{
		$PropertyItem = $Image.GetPropertyItem($PropertyTagExifDTDigSS)

		if (($PropertyItem.Type -ne 2) -or ($PropertyItem.Len -eq 0))
		{
			throw "Bad DTDigSS"
		}

		$DTDigSS = $ASCIIEncoding.GetString($PropertyItem.Value, 0, $PropertyItem.Len - 1)

		$DTDigitized += "." + $DTDigSS
	}

	"DTDigitized: {0}" -f $DTDigitized
}

# get pixel xy dim

if (($PropertyIdList.Contains($PropertyTagExifPixXDim)) -and ($PropertyIdList.Contains($PropertyTagExifPixYDim)))
{
	$PropertyItem = $Image.GetPropertyItem($PropertyTagExifPixXDim)

	if (($PropertyItem.Type -ne 4) -or ($PropertyItem.Len -ne 4))
	{
		throw "Bad PixXDim"
	}

	$PixXDim = [System.BitConverter]::ToUInt32($PropertyItem.Value, 0)

	$PropertyItem = $Image.GetPropertyItem($PropertyTagExifPixYDim)

	if (($PropertyItem.Type -ne 4) -or ($PropertyItem.Len -ne 4))
	{
		throw "Bad PixYDim"
	}

	$PixYDim = [System.BitConverter]::ToUInt32($PropertyItem.Value, 0)

	"PixDim: {0} x {1}" -f $PixXDim, $PixYDim
}

# open map

if (($Map) -and ($Latitude -ne $null) -and ($Longitude -ne $null))
{
	$MapsUrl = "https://www.bing.com/maps/default.aspx?v=2&q={0},{1}" -f $Latitude, $Longitude

	Start-Process $MapsUrl
}

# dispose

$Image.Dispose()
$FileStream.Dispose()

#=======================================================================================================================
