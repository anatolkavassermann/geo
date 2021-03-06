<#
    Класс Distance проверяет правильность параметра, 
    ParamDataType которого указан Distance.

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

class Distance : MyData {

    [System.Double]$FormattedData

    Distance (        
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
        $this.FormattedData = 0
        $this.TryConvert()
    }

    hidden [void] TryConvert ()
	{
        trap {
            throw $_.Exception
            trap [System.Management.Automation.MethodInvocationException] { 
                ShowMessageWrongConf -Section $this.SectionName -ParameterName $this.ParameterName -ConfigFilePath $this.ConfigFilePath -PatternName $null -ErrorMessage "Verify that the parameter entry is correct"
                $this.DataIsCorrect = $false
                return;
            }
        }

		$this.FormattedData = [System.Convert]::ToDouble($this.InputData)
        
        switch (($this.FormattedData -lt 0) -or ($this.FormattedData -gt 100)) {
		    $true
		    {
			    $this.DataIsCorrect = $false
			    ShowMessageWrongConf -Section $this.SectionName -ParameterName $this.ParameterName -ConfigFilePath $this.ConfigFilePath -PatternName $null -ErrorMessage "The angle value cannot be more than 100 km and less than 0 km"
			    return;
            }
        }
		return;
	}
}