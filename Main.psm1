# Classes
using module .\classes\Plane.psm1
using module .\classes\World.psm1
# Engines
using module .\engines\WorldCoordsCreationEngine.psm1
using module .\engines\PlaneObjectCreationEngine.psm1

# Modules
using module .\parsers\ConfigPathParser.psm1
using module .\parsers\WorldSectionConfigurationParser.psm1
using module .\parsers\PlaneSectionConfigurationParser.psm1
using module .\parsers\MainSectionConfigurationParser.psm1

function Main () {
    param (
        [parameter(Mandatory=$false)]
        [System.Int64]
        $InitialTime
    )
    
    trap {
        Write-Host "Error was found" -ForegroundColor Red
        Write-Host -Object $_ -ForegroundColor Red
        return
    }
    $ModuleName = "Module main"
    ShowAuther -ModuleName $ModuleName
    $OutputConfigFilepath = ".\conf\Output.txt"
    $OutputExcelConfigFilepath = ".\conf\Output.xlsx"
    $IfOutputConfigFileExsists = Test-Path $OutputConfigFilepath
    $IfOutputExcelConfigFileExsists = Test-Path $OutputExcelConfigFilepath
    switch ($IfOutputConfigFileExsists) {
        $false {
            Set-Content -Value $null -Path $OutputConfigFilepath
        }
    }
    switch ($IfOutputExcelConfigFileExsists) {
        $false {
            Set-Content -Value $null -Path $OutputExcelConfigFilepath
        }
    }
    $OutputConfigFilepath = $OutputConfigFilepath | Resolve-Path
    $OutputExcelConfigFilepath = $OutputExcelConfigFilepath | Resolve-Path
    #$OutputExcelConfigFilepath
    [System.String]$InitialConfigFilePath = ".\conf\main_conf.xml"
    $RealConfigFilePath = ParseConfigFilePath -ConfigFilePath $InitialConfigFilePath
    IfNull -Data $RealConfigFilePath
    
    [xml]$Configuration = Get-Content -Path $RealConfigFilePath
    
    $WorldConfiguration = CheckWorldSectionConfiguration -WorldSection $Configuration.conf.sectionWorld -ConfigFilePath $RealConfigFilePath
    IfNull -Data $WorldConfiguration
    
    [World]$WorldsCoords = CalculateWorldsCoords -WorldConfigurationData $WorldConfiguration
    
    $PlanePatternConfiguration = CheckPlaneSectionConfiguration -PlaneSection $Configuration.conf.sectionPlanePattern -ConfigFilePath $RealConfigFilePath  
    IfNull -Data $PlanePatternConfiguration
    
    $PatternsToGenerateConfiguration = CheckMainSectionConfiguration -MainSection $Configuration.conf.sectionMain -ConfigFilePath $RealConfigFilePath
    IfNull -Data $PatternsToGenerateConfiguration
    
    $CompleteConfiguration = @{ }
    for ($PatternIndex = 0; $PatternIndex -lt $PatternsToGenerateConfiguration.Count-1; $PatternIndex++) { # Изменить!!!
        switch ($PlanePatternConfiguration.Contains($PatternsToGenerateConfiguration[$PatternIndex.ToString()].PatternName)) {
            $true {
                $TempData = @{ }
                $TempData.Add("PatternConfiguration",$PlanePatternConfiguration[$PatternsToGenerateConfiguration[$PatternIndex.ToString()].PatternName])
                $TempData.Add("Count",$PatternsToGenerateConfiguration[$PatternIndex.ToString()].($PatternsToGenerateConfiguration[$PatternIndex.ToString()].PatternName))
                $CompleteConfiguration.Add($PatternIndex.ToString(),$TempData)
             }
            $false {
                ShowMessageWrongConf -Section $Configuration.conf.sectionMain.Name -ParameterName "PatternsToUse" -ConfigFilePath $RealConfigFilePath -ErrorMessage ("Wrong config! The template " + $PatternsToGenerateConfiguration[$PatternIndex.ToString()].PatternName +" is not described.")
                return;
             }
        }
    }
    
    for ($PatternIndex = 0; $PatternIndex -lt $CompleteConfiguration.Count; $PatternIndex++) {
        for ($PatternCount = 0; $PatternCount -lt $CompleteConfiguration[$PatternIndex.ToString()].Count; $PatternCount++) {
            [Plane]$Plane = CreatePlane -PatternConfiguration $CompleteConfiguration[$PatternIndex.ToString()].PatternConfiguration -WorldCoords $WorldsCoords
            $PlaneIsOnMap = $false
            Write-Host -Object ("Generating coords for " + $Plane.ObjID) -ForegroundColor Green
            $Step = $InitialTime
            $CurrStep = 0
            while ($Plane.CanFly) {
                $CurrStep++
                switch ($PlaneIsOnMap) {
                    $false {
                        [System.Int64]$Milisecond = $Plane.RefreshRate * $Step
                        [System.String]$OutputResult = [System.String]::Join(":",$Plane.Coords)
                        $OutputResult = "s" + $Milisecond.ToString() + "t" + $OutputResult + ";" + $Plane.CurHeight.ToString() + ";" + $Plane.ObjID + ";" + $Plane.CurAngle.ToString()
                        Add-Content -Path $OutputConfigFilepath -Value $OutputResult
                        $PlaneIsOnMap = $true
                     }
                }
                $Plane.MakeStep()
                switch ($Plane.CanFly) {
                    $true {
                        $Step ++
                        [System.Int64]$Milisecond = $Plane.RefreshRate * $Step
                        [System.String]$OutputResult = [System.String]::Join(":",$Plane.Coords)
                        $OutputResult = "s" + $Milisecond.ToString() + "t" + $OutputResult + ";" + $Plane.CurHeight.ToString() + ";" + $Plane.ObjID + ";" + $Plane.CurAngle.ToString()
                        Add-Content -Path $OutputConfigFilepath -Value $OutputResult
                     }
                    $false {
                        break
                     }
                }
                switch ($CurrStep -ge 1000) {
                    $true {
                        break
                     }
                }
            }
        }
    }
    Get-Content $OutputConfigFilepath | Sort-Object -Property {$_.Substring(1,$_.IndexOf("t")).Length;"$_[0..9]"} | Set-Content $OutputConfigFilepath
    WriteToExcel -OutputExcelFile $OutputExcelConfigFilepath -OutputConfigFilepath $OutputConfigFilepath
}

function IfNull () {
    param (
        [parameter(Mandatory=$true)]
        $Data
    )
    switch (
                ("" -eq $Data) -or `
                ($null -eq $Data)
            ) 
    {
        $true { 
            Write-Host "Exiting!" -ForegroundColor Red
            exit;
         }
    }
}

function WriteToExcel () {
    param (
        [parameter(Mandatory=$false)]
        [System.String]
        $OutputExcelFile,
        [parameter(Mandatory=$false)]
        [System.String]
        $OutputConfigFilepath
    )

    trap {
        Write-Host "Error was found" -ForegroundColor Red
        Write-Host -Object $_ -ForegroundColor Red
        $xl.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($xl) | Out-Null
        return
    }
    $ModuleName = "Module WriteToExcel"
    ShowAuther -ModuleName $ModuleName
    #Write-Host $OutputExcelFile
    [System.String[]]$AllMillisecondsStr = Get-Content -Path $OutputConfigFilepath | ForEach-Object {$_.Substring(1,$_.IndexOf("t")-1)}
    [System.Int64[]]$AllMilliseconds = $AllMillisecondsStr | Sort-Object -Unique
    [System.Array]::Sort($AllMilliseconds)
    $OutputConfigFile = Get-Content $OutputConfigFilepath
    [System.Int64[]]$CountPerMillisecond = [System.Int64[]]::new($AllMilliseconds.Count)
    $DataForExcel = [System.Collections.ArrayList]::new()
    for ($MillisecondIndex = 0; $MillisecondIndex -lt $AllMilliseconds.Count; $MillisecondIndex ++) {
        $CountPerMillisecond[$MillisecondIndex] = ($OutputConfigFile | Select-String -Pattern ("s" + $AllMilliseconds[$MillisecondIndex].ToString() + "t")).Matches.Count
        $TempArray = $AllMilliseconds[$MillisecondIndex],$CountPerMillisecond[$MillisecondIndex]
        $DataForExcel.Add($TempArray) | Out-Null
    }

    Add-Type -AssemblyName Microsoft.Office.Interop.Excel
    $xl = New-Object -ComObject Excel.Application
    $xl.DisplayAlerts = $false
    $OutputData = $DataForExcel|ForEach-Object{[PSCustomObject][Ordered]@{'Milliseconds'=$_[0];'Count'=$_[1]}}
    $wb = $xl.workbooks.Add()
    $ws = $wb.ActiveSheet
    $xl.Visible = $false

    $OutputData | ConvertTo-Csv -NoTypeInformation -Delimiter "`t" | C:\Windows\System32\clip.exe
    $ws.Range("A1").Select | Out-Null
    $ws.paste()
    $ws.UsedRange.Columns.AutoFit() | Out-Null

    $Chart = $ws.Shapes.AddChart().Chart
    $Chart.ChartType = [Microsoft.Office.Interop.Excel.XLChartType]::xlLine
    $wb.SaveAs($OutputExcelFile)
    $wb.CLose()
    $xl.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($xl) | Out-Null
}

function ShowAuther () {

    param (
        [parameter(Mandatory=$true)]
        [System.String]
        $ModuleName
    )

    $AutherData = 
"Trajectory generator v.1.0.
Author: AnatolkaBasurman
Welcome!
Running $ModuleName
"
    Write-Host -Object $AutherData -ForegroundColor Green
}