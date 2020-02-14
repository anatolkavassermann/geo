<#
    Файл содержит функции:
        1. ReturnFormattedData

     1. Функция ReturnFormattedData возвращает
        объект определенного класса.
#>

# Modules
using module .\Errors.psm1

# Classes
using module ..\classes\Point.psm1
using module ..\classes\Distance.psm1
using module ..\classes\Angle.psm1
using module ..\classes\Height.psm1
using module ..\classes\Speed.psm1

function ReturnFormattedData () {
    param(
        [parameter (Mandatory=$true)]
        [System.String]
        $Section,
        [parameter (Mandatory=$true)]
        [System.Xml.XmlNode]
        $Parameter,
        [parameter(Mandatory=$false)]
        [System.String]
        $PatternName,
        [parameter (Mandatory=$true)]
        [System.String]
        $ConfigFilePath
    )
    switch (
        ($Parameter.ParamName -ne "") -and `
        ($Parameter.Data -ne "") -and `
        ($Parameter.ParamDataType -ne "")
    )
    {
        $true {
            switch ($Parameter.ParamDataType) {
                "Point" { 
                    [Point] $Data = [Point]::new($Parameter.Data,$Parameter.ParamName,$ConfigFilePath,$PatternName,$Section)
                    return $Data;
                 }
                "Angle" { 
                    [Angle] $Data = [Angle]::new($Parameter.Data,$Parameter.ParamName,$ConfigFilePath,$PatternName,$Section)
                    return $Data;
                 }
                "Distance" { 
                    [Distance] $Data = [Distance]::new($Parameter.Data,$Parameter.ParamName,$ConfigFilePath,$PatternName,$Section)
                    return $Data;
                 }
                "Speed" { 
                    [Speed] $Data = [Speed]::new($Parameter.Data,$Parameter.ParamName,$ConfigFilePath,$PatternName,$Section)
                    return $Data;
                 }
                "Height" { 
                    [Height] $Data = [Height]::new($Parameter.Data,$Parameter.ParamName,$ConfigFilePath,$PatternName,$Section)
                    return $Data;
                 }
            }
         }
        $false {
            ShowMessageWrongConf -Section $Section -ParameterName $Parameter.ParamName -PatternName $PatternName -ConfigFilePath $ConfigFilePath -ErrorMessage "Not enough information about parameter!"
            return $null
         }
    }
    
}