<#
    Класс Point проверяет правильность параметра, 
    ParamDataType которого указан Point.

    В классе есть метод TryConvert, который 
    предусматривает 2 вида проверок: форматный и
    логический.

    Форматный контроль позволяет определить, правильно 
    ли сформирован конфигурационный файл.
    Логический контроль определяет правильность значений с 
    точки зрения логики (не может быть 1.5 человека, или
    скорость не может быть отрицательной).
#>

# Classes
using module .\MyObject.psm1

# Modules
using module ..\modules\Errors.psm1

class Point : MyData {

    [System.Double[]]$FormattedData

    Point (
        [System.String]$_InputData,
		[System.String]$_ParameterName,
		[System.String]$_ConfigFilePath,
		[System.String]$_PatternName,
		[System.String]$_SectionName
        ) 
    {
        $this.InputData = $_InputData
        $this.ParameterName = $_ParameterName
        $this.ConfigFilePath = $_ConfigFilePath
        $this.PatternName = $_PatternName
        $this.SectionName = $_SectionName
        $this.DataIsCorrect = $true
        $this.FormattedData = [System.Double[]]::new(2)
        $this.TryConvert()
    }

    hidden [void] TryConvert () {
        trap {
            throw $_.Exception
            trap [System.Management.Automation.MethodInvocationException] { 
                ShowMessageWrongConf -Section $this.SectionName -ParameterName $this.ParameterName -ConfigFilePath $this.ConfigFilePath -PatternName $null -ErrorMessage "Verify that the parameter entry is correct"
                $this.DataIsCorrect = $false
                return;
            }
        }

        [System.String[]]$Coords = $this.InputData.Split("|")
        switch ($Coords.Length -eq 2) {
            $true { 
                for ($CoordIndex = 0; $CoordIndex -lt 2; $CoordIndex++) {
                    $this.FormattedData[$CoordIndex] = [System.Convert]::ToDouble($Coords[$CoordIndex])
                    switch ($CoordIndex) {
                        0 {
                            switch ([System.Math]::Abs($this.FormattedData[$CoordIndex]) -gt 90) {
                                $true {
                                    $this.DataIsCorrect = $false
                                    ShowMessageWrongConf -Section $this.SectionName -ParameterName $this.ParameterName -ConfigFilePath $this.ConfigFilePath -PatternName $null -ErrorMessage "The latitude value cannot be more than 90 degrees and less than -90 degrees"
                                    return;
                                }
                            }
                         }
                        1 {
                            switch (($this.FormattedData[$CoordIndex] -gt 360) -or ($this.FormattedData[$CoordIndex] -lt 0)) {
                                $true {
                                    $this.DataIsCorrect = $false
                                    ShowMessageWrongConf -Section $this.SectionName -ParameterName $this.ParameterName -ConfigFilePath $this.ConfigFilePath -PatternName $null -ErrorMessage "The longtitude value cannot be more than 360 degrees and less than 0 degrees"
                                    return;
                                }
                            }
                         }
                    }
                }
             }
            $false { 
                ShowMessageWrongConf -Section $this.SectionName -ParameterName $this.ParameterName -ConfigFilePath $this.ConfigFilePath -PatternName $null -ErrorMessage "Longtitude or latitude is not specified"
                $this.DataIsCorrect = $false
             }
        }
    }
}