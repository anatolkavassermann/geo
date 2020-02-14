<#
    Файл содержит функции:

        Функция ParseConfigFilePath пробует прочитать 
        файл конфигурации. 
        На вход функйии подается путь до файла конфигурации.
        Если его не существует, или к нему нет доступа, 
        функция возвращает значение $null, иначе возвращает 
        значение, которое было подано на вход функции.
#>

# Modules
using module ..\modules\Errors.psm1
function ParseConfigFilePath {
    param (
        [Parameter(Mandatory=$true)]
        [System.String]
        $ConfigFilePath
    )
    
    trap {
        throw $_.Exception

        trap [System.Management.Automation.ItemNotFoundException] {
            ShowMessageWrongConf -Section $null -ParameterName $null -PatternName $null -ConfigFilePath $_.TargetObject -ErrorMessage $_
            return ""
        }

        trap [System.Management.Automation.RuntimeException] {
            ShowMessageWrongConf -Section $null -ParameterName $null -PatternName $null -ConfigFilePath $_.TargetObject -ErrorMessage $_
            return ""
        }

        trap [System.UnauthorizedAccessException] {
            ShowMessageWrongConf -Section $null -ParameterName $null -PatternName $null -ConfigFilePath $_.TargetObject -ErrorMessage $_
            return ""
        }
    }
        Get-Content -Path $ConfigFilePath -ErrorAction Stop | Out-Null   
        return $ConfigFilePath;
}
