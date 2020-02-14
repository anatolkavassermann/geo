<#
	Данный модуль парсит конфиг plane_pattern_conf.xml
	и, при условии, что все требования к нему соблюдены, 
	возвращает значения, которые передаются модулю для 
	создания объектов.

	Правила для конфигурационного файла plane_pattern_conf.xml:

		<PatName>Имя шаблона, например, Pattern1. Тип данных: string.</PatName>
		<RefreshRate>Скорость опроса объекта в миллисекундах. Тип данных: int16</RefreshRate>
		<MinSpeed>Минимальная скорость полета объекта. Тип данных: double</MinSpeed>
		<MaxSpeed>Максимальная скорость полета объекта. Тип данных: double </MaxSpeed>
		<SpeedAdj>Увеличение скорости за единицу времени RefreshRate. Тип данных: double</SpeedAdj>
		<SpeedDec>Уменьшение скорости за единицу времени RefreshRate. Тип данных: double</SpeedDec>
		<MinHeight>Минимальная высота полета объекта. Тип данных: double</MinHeight>
		<MaxHeight>Максимальная высота полета объекта. Тип данных: double</MaxHeight>
		<MaxUpAngle>Максимальный угол подъема носа объекта за единицу времени RefreshRate. Тип данных: double</MaxUpAngle>
		<MaxRotAngle>Максимальный угол поворота объекта в пространстве за единицу времени RefreshRate. Тип данных: double</MaxRotAngle>

	Пример конфигурации шаблона:

	<config>
		<pattern>
			<PatternName>Pattern1</PatternName>
			<RefreshRate>1000</RefreshRate>
			<Params.Param>
				<Param>
					<ParamName>MinSpeed</ParamName>
					<Data>240</Data>
					<ParamDataType>Speed</ParamDataType>
				</Param>
				<Param>
					<ParamName>MaxSpeed</ParamName>
					<Data>560</Data>
					<ParamDataType>Speed</ParamDataType>
				</Param>
				<Param>
					<ParamName>SpeedAdj</ParamName>
					<Data>24</Data>
					<ParamDataType>Speed</ParamDataType>
				</Param>
				<Param>
					<ParamName>SpeedDec</ParamName>
					<Data>21</Data>
					<ParamDataType>Speed</ParamDataType>
				</Param>
				<Param>
					<ParamName>MinHeight</ParamName>
					<Data>1000</Data>
					<ParamDataType>Height</ParamDataType>
				</Param>
				<Param>
					<ParamName>MaxHeight</ParamName>
					<Data>6000</Data>
					<ParamDataType>Height</ParamDataType>
				</Param>
				<Param>
					<ParamName>MaxUpAngle</ParamName>
					<Data>35</Data>
					<ParamDataType>Angle</ParamDataType>
				</Param>
				<Param>
					<ParamName>MaxRotAngle</ParamName>
					<Data>14</Data>
					<ParamDataType>Angle</ParamDataType>
				</Param>
			</Params>
		</pattern>
	</config>

	Внимание!
	Если у числа присутсвует дробная часть, ее необходимо указывать после символа ",", т.е. 100,34576; или 200,12312; или -32,1256
#>

# Classes
using module ..\classes\Angle.psm1
using module ..\classes\Height.psm1
using module ..\classes\Speed.psm1

# Modules 
using module ..\modules\Errors.psm1
using module ..\modules\ReturnFormattedData.psm1

function CheckPlaneSectionConfiguration () {
	param(
        [parameter (Mandatory=$true)]
        [System.Xml.XmlNode]
        $PlaneSection,
        [parameter (Mandatory=$true)]
        [System.String]
        $ConfigFilePath
	)
	$PlanePatterns = @{ }
	[System.Int16]$PatternCount = $PlaneSection.ChildNodes.Count
	switch ($PatternCount -gt 0) {
		$true {
			switch ($PatternCount -eq 1) {
				$true {
					$CurrentPlanePattern = Checker -PlanePattern $PlaneSection.Pattern -ConfigFilePath $ConfigFilePath -Section $PlaneSection.Name

					switch ($null -eq $CurrentPlanePattern) {
						$true { 
							return $null
						 }
					}

					$PlanePatterns.Add($CurrentPlanePattern['patname'],$CurrentPlanePattern)
					return $PlanePatterns
				 }
				$false {
					for ($PlanePatternsIndex = 0; $PlanePatternsIndex -lt $PatternCount; $PlanePatternsIndex++) {
						$CurrentPlanePattern = Checker -PlanePattern $PlaneSection.Pattern[$PlanePatternsIndex] -ConfigFilePath $ConfigFilePath -Section $PlaneSection.Name

						switch ($null -eq $CurrentPlanePattern) {
							$true { 
								return $null
							 }
						}

						$PlanePatterns.Add($CurrentPlanePattern['patname'],$CurrentPlanePattern)
					}
					return $PlanePatterns
				 }
			}
		 }
		$false {
			ShowMessageWrongConf -Section $PlaneSection.Name -ParameterName "null" -PatternName $null -ErrorMessage "No patterns specified!"
			return $null
		 }
	}
}

function Checker () {
	param (
		[parameter(Mandatory=$true)]
		[System.Xml.XmlNode]
		$PlanePattern,
		[parameter (Mandatory=$true)]
        [System.String]
		$ConfigFilePath,
		[parameter (Mandatory=$true)]
        [System.String]
        $Section
	)

	trap {
		throw $_.Exception
		trap [System.Management.Automation.MethodInvocationException] {
			return $null
		}
	}

	$ParametersInEachPatternCount = $PlanePattern.Params.ChildNodes.Count
	switch ($PlanePattern.PatternName -eq "") {
		$true {
			ShowMessageWrongConf -Section $Section -ParameterName "PatternName" -PatternName $null -ConfigFilePath $ConfigFilePath -ErrorMessage "Not enough parameters specified"
			return $null
		 }
		$false {
			switch ($PlanePattern.RefreshRate -eq "") {
				$true {
					ShowMessageWrongConf -Section $Section -ParameterName "RefreshRate" -PatternName $PlanePattern.PatternName -ConfigFilePath $ConfigFilePath -ErrorMessage "Not enough parameters specified"
					return $null;
				 }
			}
		 }
	}
	[System.String]$PatternName = $PlanePattern.PatternName
	[System.Int16]$RefreshRate = $PlanePattern.RefreshRate
	switch ($ParametersInEachPatternCount -eq 8) {
		$true {
			for ($ParamIndex = 0; $ParamIndex -lt $ParametersInEachPatternCount; $ParamIndex++) {
				switch ($PlanePattern.Params.Param[$ParamIndex].ParamName) {
					"MinSpeed" {
						$MinSpeed = ReturnFormattedData -Section $Section -Parameter $PlanePattern.Params.Param[$ParamIndex] -ConfigFilePath $ConfigFilePath -PatternName $PatternName
						switch ($null -eq $MinSpeed) {
                            $true {
                                return $null
                             }
                        }
					 }
					"MaxSpeed" {
						$MaxSpeed = ReturnFormattedData -Section $Section -Parameter $PlanePattern.Params.Param[$ParamIndex] -ConfigFilePath $ConfigFilePath -PatternName $PatternName
						switch ($null -eq $MaxSpeed) {
                            $true {
                                return $null
                             }
                        }
					 }
					"SpeedAdj" {
						$SpeedAdj = ReturnFormattedData -Section $Section -Parameter $PlanePattern.Params.Param[$ParamIndex] -ConfigFilePath $ConfigFilePath -PatternName $PatternName
						switch ($null -eq $SpeedAdj) {
                            $true {
                                return $null
                             }
                        }
					 }
					"SpeedDec" {
						$SpeedDec = ReturnFormattedData -Section $Section -Parameter $PlanePattern.Params.Param[$ParamIndex] -ConfigFilePath $ConfigFilePath -PatternName $PatternName
						switch ($null -eq $SpeedDec) {
                            $true {
                                return $null
                             }
                        }
					 }
					"MinHeight" {
						$MinHeight = ReturnFormattedData -Section $Section -Parameter $PlanePattern.Params.Param[$ParamIndex] -ConfigFilePath $ConfigFilePath -PatternName $PatternName
						switch ($null -eq $MinHeight) {
                            $true {
                                return $null
                             }
                        }
					 }
					"MaxHeight" {
						$MaxHeight = ReturnFormattedData -Section $Section -Parameter $PlanePattern.Params.Param[$ParamIndex] -ConfigFilePath $ConfigFilePath -PatternName $PatternName
						switch ($null -eq $MaxHeight) {
                            $true {
                                return $null
                             }
                        }
					 }
					"MaxUpAngle" {
						$MaxUpAngle = ReturnFormattedData -Section $Section -Parameter $PlanePattern.Params.Param[$ParamIndex] -ConfigFilePath $ConfigFilePath -PatternName $PatternName
						switch ($null -eq $MaxUpAngle) {
                            $true {
                                return $null
                             }
                        }
					 }
					"MaxRotAngle" {
						$MaxRotAngle = ReturnFormattedData -Section $Section -Parameter $PlanePattern.Params.Param[$ParamIndex] -ConfigFilePath $ConfigFilePath -PatternName $PatternName
						switch ($null -eq $MaxRotAngle) {
                            $true {
                                return $null
                             }
                        }
					 }
				}
			}
			switch (
						(
							($MinSpeed.DataIsCorrect -eq $true) -and `
							($MaxSpeed.DataIsCorrect -eq $true) -and `
							($SpeedAdj.DataIsCorrect -eq $true) -and `
							($SpeedDec.DataIsCorrect -eq $true) -and `
							($MinHeight.DataIsCorrect -eq $true) -and `
							($MaxHeight.DataIsCorrect -eq $true) -and `
							($MaxUpAngle.DataIsCorrect -eq $true) -and `
							($MaxRotAngle.DataIsCorrect -eq $true)
						)
					) {
				$true {
					switch (
								($MinSpeed.FormattedData -le $MaxSpeed.FormattedData) -and `
								($MinHeight.FormattedData -le $MaxHeight.FormattedData)
							) {
						$true {
							$PlanePatternConfiguration = @{
								'patname'		    = $PatternName;
								'refreshrate'	    = $RefreshRate;
								'minspeed'		    = $MinSpeed.FormattedData;
								'maxspeed'		    = $MaxSpeed.FormattedData;
								'speedadj'		    = $SpeedAdj.FormattedData;
								'speeddec'		    = $SpeedDec.FormattedData;
								'minheight'	 	   	= $MinHeight.FormattedData;
								'maxheight'	    	= $MaxHeight.FormattedData;
								'maxupangle'	    = $MaxUpAngle.FormattedData;
								'maxrotangle'	    = $MaxRotAngle.FormattedData;
							}
							return $PlanePatternConfiguration
						 }
						$false {
							ShowMessageWrongConf -Section $Section -ParameterName $null -PatternName $PatternName -ConfigFilePath $ConfigFilePath -ErrorMessage "MinHeight param must be less than or equal to the MaxHeight param and MinSpeed param must be less than or equal to the MaxSpeed param"
							return $null
						 }
					}	
				 }
				$false {
					switch ($null -eq $MinSpeed) {
                        $true {
                            ShowMessageWrongConf -Section $Section -ParameterName "MinSpeed" -ConfigFilePath $ConfigFilePath -PatternName $PatternName -ErrorMessage "Parameter is not specified"
                            return $null;
                         }
					}
					switch ($null -eq $MaxSpeed) {
                        $true {
                            ShowMessageWrongConf -Section $Section -ParameterName "MaxSpeed" -ConfigFilePath $ConfigFilePath -PatternName $PatternName -ErrorMessage "Parameter is not specified"
                            return $null;
                         }
					}
					switch ($null -eq $SpeedAdj) {
                        $true {
                            ShowMessageWrongConf -Section $Section -ParameterName "SpeedAdj" -ConfigFilePath $ConfigFilePath -PatternName $PatternName -ErrorMessage "Parameter is not specified"
                            return $null;
                         }
					}
					switch ($null -eq $SpeedDec) {
                        $true {
                            ShowMessageWrongConf -Section $Section -ParameterName "SpeedDec" -ConfigFilePath $ConfigFilePath -PatternName $PatternName -ErrorMessage "Parameter is not specified"
                            return $null;
                         }
					}
					switch ($null -eq $MinHeight) {
                        $true {
                            ShowMessageWrongConf -Section $Section -ParameterName "MinHeight" -ConfigFilePath $ConfigFilePath -PatternName $PatternName -ErrorMessage "Parameter is not specified"
                            return $null;
                         }
					}
					switch ($null -eq $MaxHeight) {
                        $true {
                            ShowMessageWrongConf -Section $Section -ParameterName "MaxHeight" -ConfigFilePath $ConfigFilePath -PatternName $PatternName -ErrorMessage "Parameter is not specified"
                            return $null;
                         }
					}
					switch ($null -eq $MaxUpAngle) {
                        $true {
                            ShowMessageWrongConf -Section $Section -ParameterName "MaxUpAngle" -ConfigFilePath $ConfigFilePath -PatternName $PatternName -ErrorMessage "Parameter is not specified"
                            return $null;
                         }
					}
					switch ($null -eq $MaxRotAngle) {
                        $true {
                            ShowMessageWrongConf -Section $Section -ParameterName "MaxRotAngle" -ConfigFilePath $ConfigFilePath -PatternName $PatternName -ErrorMessage "Parameter is not specified"
                            return $null;
                         }
                    }
				 }
			}

		 }
		$false {
			ShowMessageWrongConf -Section $Section -ParameterName $null -PatternName $PlanePattern.PatternName -ConfigFilePath $ConfigFilePath -ErrorMessage "Not enough parameters specified"
			return $null
		 }
	}
}
