<#
    Файл содержит функции: 
        1. CalculateCoords
    
     1. Функция получает на вход параметры
        -Координаты
        -Азимут
        -Расстояние
        и решает прямую геодезическую задачу.
        Функция возвращает координаты.
#>

function CalculateCoords {
    param (
        [parameter(Mandatory=$true)]
        [System.Double[]]
        $InitCoords,
        [parameter(Mandatory=$true)]
        [System.Double]
        $InitAngle,
        [parameter(Mandatory=$true)]
        [System.Double]
        $DistanceToGo
    )
    [System.Double]$Latitude = $InitCoords[0]
    [System.Double]$Longtitude = $InitCoords[1]
    $os = [System.Environment]::OSVersion.VersionString
    switch ($os -match "Unix") {
        $true {
            [System.String]$Answer = python3 ./engines/shp/dir.py "$Latitude $Longtitude $InitAngle $DistanceToGo"
            [System.String[]]$StringCoords =  $Answer.Split([System.Text.Encoding]::ASCII.GetString(32))
         }
    }
    switch ($os -match "Windows") {
        $true { 
            [System.String]$Answer = [System.String]$Answer = "$Latitude $Longtitude $InitAngle $DistanceToGo" | .\engines\shp\dir.exe
            [System.String[]]$StringCoords =  $Answer.Split([System.Text.Encoding]::ASCII.GetString(9))
            for ($i = 0; $i -lt $StringCoords.Count; $i++) {
                write-host $StringCoords[$i]
                $StringCoords[$i] = $StringCoords[$i].Replace(".",",")
                write-host $StringCoords[$i]
            }
         }
    }
    [System.Double[]]$ResultingCoords = [System.Double[]]::new(2)
    for ($i = 0; $i -le $StringCoords.Length - 2; $i++)
	{
		$ResultingCoords[$i] = [System.Double]::Parse($StringCoords[$i])
	}
	return $ResultingCoords;
}
