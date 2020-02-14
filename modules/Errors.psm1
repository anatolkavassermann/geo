<#

    $SomeVariable - обозначение некой переменной

    Файл содержит функции:
        1. ShowMessageWrongConf

     1. Функция ShowMessageWrongConf выводит 
        сведения о возникновении ошибок в 
        конфигурационном файле или при попытке
        получения к нему доступа. Пример вывода:

        ----------------------------------------------

        Cannot parse config $ConfigFilePath:
        Section: $Section,
        ParameterName: $ParameterName,
        Pattern: $Pattern,
        Please, correct all mistakes and try again.
        ______________________________________________
#>


function ShowMessageWrongConf () {
    param (
        [System.String]
        $Section,
        [System.String]
        $ParameterName,
        [System.String]
        $PatternName,
        [System.String]
        $ConfigFilePath,
        [System.String]
        $ErrorMessage
    )
    #[System.Text.StringBuilder]$OutputErrorData = [System.Text.StringBuilder]::new()
    [System.String]$OutputErrorData = ""
    $OutputErrorData += ("Some errors occured during parsing config file $ConfigFilePath
")
    switch ("" -eq $Section) {
        $false {
            $OutputErrorData += ("Section: $Section,
")
         }
    }
    switch ("" -eq $ParameterName) {
        $false {
            $OutputErrorData += ("Parameter Name: $ParameterName,
")
         }
    }
    switch ("" -eq $PatternName) {
        $false {
            $OutputErrorData += ("Pattern Name: $PatternName,
")
         }
    }
    switch ("" -eq $ErrorMessage) {
        $false {
            $OutputErrorData += ("Error Message: $ErrorMessage,
")
         }
    }
    $OutputErrorData += ("Please, correct all mistakes and try again.
")
    $OutputErrorData += ("____________________________
")
    $OutputError = $OutputErrorData.ToString()    
    Write-Host -Object $OutputError -ForegroundColor Red
}