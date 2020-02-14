<#
    Файл содержит функции:
        1. CalculateWorldsCoords
    
     1. Функция CalculateWorldsCoords принимает 
        на вход словарь, содержащий координаты 
        и сторону квадрата наблюдения и возвращает
        объект класса World.
#>

# Namespaces
using namespace System.Collections.Generic

# Classes
using module ..\classes\World.psm1

# Engines
using module .\CoordsCalculation.psm1

function CalculateWorldsCoords {
    param (
        [parameter(Mandatory=$true)]
        $WorldConfigurationData
    )
    [System.Double[]]$WorldsTopLeftCornerCoords = $WorldConfigurationData['WorldsLeftCornerCoords']
    [System.Double]$WorldsSide = $WorldConfigurationData['WorldsSide']
    [System.Double]$Angle = 180
    [System.Double[]]$WorldsBottomLeftCornerCoords = CalculateCoords -InitCoords $WorldsTopLeftCornerCoords -InitAngle $Angle -DistanceToGo $WorldsSide
    [System.Double]$Angle = 90
    [System.Double[]]$WorldsTopRightCornerCoords = CalculateCoords -InitCoords $WorldsTopLeftCornerCoords -InitAngle $Angle -DistanceToGo $WorldsSide
    [World]$World = [World]::new($WorldsTopLeftCornerCoords, $WorldsBottomLeftCornerCoords, $WorldsTopRightCornerCoords)
    return $World
} 