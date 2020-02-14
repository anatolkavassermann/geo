<#
    Класс MyData является абстрактным.
    В дальнейшем планируется перенос всех форматных 
    и логических проверок в этот класс. Классы, которые
    будут наследовать класс MyData, будут принимать на 
    вход границы для осуществления логического контроля.
#>

class MyData {
    [System.String]$InputData
    [System.String]$ParameterName
    [System.String]$ConfigFilePath
    [System.String]$PatternName
    [System.String]$SectionName
	[System.Boolean]$DataIsCorrect

    MyData () {
        switch ($this.GetType() -eq [MyData]) {
            $true {
                throw ("Class " + $this.GetType() + " must be inherited")
            }
        }
    }
}