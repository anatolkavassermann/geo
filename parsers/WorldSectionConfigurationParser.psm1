<#
    Файл содержит функции: 
        1. CheckWorldSectionConfiguration

     1. Функция CheckWorldSectionConfiguration парсит
        секцию sectionWorld конфигурационного 
        файла main_conf.xml и возвращает словарь
        с координатами и стороной квадрата 
        наблюдения, иначе выдает ошибку и возвращает 
        значене null.
#>

# Modules
using module ..\modules\Errors.psm1
using module ..\modules\ReturnFormattedData.psm1

# Classes
using module ..\classes\Point.psm1
using module ..\classes\Distance.psm1

function CheckWorldSectionConfiguration () {
    param(
        [parameter (Mandatory=$true)]
        [System.Xml.XmlNode]
        $WorldSection,
        [parameter (Mandatory=$true)]
        [System.String]
        $ConfigFilePath
    )

    switch ($WorldSection.ChildNodes.Count -eq 2) {
        $true {
            for ($ParameterIndex = 0; $ParameterIndex -lt 2; $ParameterIndex++) {
                switch ($WorldSection.param[$ParameterIndex].ParamName) {
                    "Point" {
                        $WorldsLeftCornerCoords = ReturnFormattedData -Section $WorldSection.Name -Parameter $WorldSection.param[$ParameterIndex] -ConfigFilePath $ConfigFilePath
                        switch ($null -eq $WorldsLeftCornerCoords) {
                            $true {
                                return $null
                             }
                        }
                     }
                    "Distance" {
                        $WorldsSide = ReturnFormattedData -Section $WorldSection.Name -Parameter $WorldSection.param[$ParameterIndex] -ConfigFilePath $ConfigFilePath
                        switch ($null -eq $WorldsSide) {
                            $true {
                                return $null
                             }
                        }
                     }
                }
            }
            switch (($WorldsLeftCornerCoords.DataIsCorrect -eq $true) -and ($WorldsSide.DataIsCorrect -eq $true)) {
                $true {
                    $WorldConfiguration = @{'WorldsLeftCornerCoords'=$WorldsLeftCornerCoords.FormattedData;'WorldsSide' = $WorldsSide.FormattedData}
                    return $WorldConfiguration;
                 }
                $false {
                    switch ($null -eq $WorldsLeftCornerCoords) {
                        $true {
                            ShowMessageWrongConf -Section $WorldSection.Name -ParameterName "Point" -ConfigFilePath $ConfigFilePath -PatternName $null -ErrorMessage "Parameter is not specified"
                            return $null;
                         }
                    }
                    switch ($null -eq $WorldsSide) {
                        $true {
                            ShowMessageWrongConf -Section $WorldSection.Name -ParameterName "Distance" -ConfigFilePath $ConfigFilePath -PatternName $null -ErrorMessage "Parameter is not specified"
                            return $null;
                         }
                    }
                 }
            }
         }
        
         $false {
            ShowMessageWrongConf -Section $WorldSection.Name -ConfigFilePath $ConfigFilePath -ErrorMessage "Not enough parameters specified"
            return $null;
         }
    }
}