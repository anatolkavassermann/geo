<#
    Файл содержит функции: 
        1. CheckWorldConfiguration

     1. Функция CheckMainSectionConfiguration парсит
        секцию sectionMain конфигурационного 
        файла main_conf.xml и возвращает словарь
        с названиями шаблонов и количеством объектов 
        необходимых для создания, иначе выдает ошибку
        и возвращает значене null.
#>

# Modules
using module ..\modules\Errors.psm1

function CheckMainSectionConfiguration () {
    param (
        [parameter (Mandatory=$true)]
        [System.Xml.XmlNode]
        $MainSection,
        [parameter (Mandatory=$true)]
        [System.String]
        $ConfigFilePath
    )

    trap {
        throw $_.Exception

        trap [System.Management.Automation.MethodInvocationException] { 
            ShowMessageWrongConf -Section $MainSection.Name -ParameterName "EachPatternCount" -ConfigFilePath $ConfigFilePath -PatternName $null -ErrorMessage "Verify that the parameter entry is correct"
            return $null
        }
    }

    [System.Int32]$PlanesToGenerate = 0
    switch ($MainSection.ChildNodes.Count -eq 2) {
        $true {
            for ($ParameterIndex = 0; $ParameterIndex -lt 2; $ParameterIndex ++) {
                switch (
                    ($Parameter.ParamName -ne "") -and `
                    ($Parameter.Data -ne "") -and `
                    ($Parameter.ParamDataType -ne "")
                 ) {
                    $true {
                        switch ($MainSection.param[$ParameterIndex].ParamName)
						{
							"PatternsToUse"
							{
                                [System.String[]]$PatternNames = $MainSection.param[$ParameterIndex].Data.Split("|")
                                for ($EachPatternNameIndex = 0; $EachPatternNameIndex -lt $PatternNames.Length; $EachPatternNameIndex++) {
                                    switch ($PatternNames[$EachPatternNameIndex] -eq "") {
                                        $true {
                                            ShowMessageWrongConf -Section $MainSection.Name -ParameterName "PatternsToUse" -PatternName $null -ConfigFilePath $ConfigFilePath -ErrorMessage "Pattern name cannot be empty"
                                            return $null
                                        }
                                    }
                                }
							}
							"EachPatternCount"
							{
								[System.String[]]$EachPatternCountStr = $MainSection.param[$ParameterIndex].Data.Split("|")
								[System.Int16[]]$EachPatternCount = [System.Int16[]]::new($PatternNames.Length)
								for ($EPC = 0; $EPC -lt $PatternNames.Length; $EPC++)
								{
                                    $EachPatternCount[$EPC] = [System.Convert]::ToInt16($EachPatternCountStr[$EPC])
								}
							}
						}
                     }
                    $false {
                        ShowMessageWrongConf -Section $Section -ParameterName $Parameter.ParamName -PatternName $PatternName -ConfigFilePath $ConfigFilePath -ErrorMessage "Not enough information about parameter!"
                        return $null
                     }
                }
            }
            $PatternsToUseAndPlanesToGenerate = @{ }
            for ($EachPatternNameIndex = 0; $EachPatternNameIndex -lt $PatternNames.Length; $EachPatternNameIndex++) {
                $TempData = @{ }
                $TempData.Add($PatternNames[$EachPatternNameIndex],$EachPatternCount[$EachPatternNameIndex])
                $TempData.Add("PatternName", $PatternNames[$EachPatternNameIndex])
                $PatternsToUseAndPlanesToGenerate.Add($EachPatternNameIndex.ToString(), $TempData)
                $PlanesToGenerate += $EachPatternCount[$EachPatternNameIndex]
            }
            $PatternsToUseAndPlanesToGenerate.Add("PlanesToGenerateCount",$PlanesToGenerate)
         }
        $false {
            ShowMessageWrongConf -Section $MainSection.Name -ConfigFilePath $ConfigFilePath -ErrorMessage "Not enough parameters specified"
            return $null;
         }
    }
    return $PatternsToUseAndPlanesToGenerate
}