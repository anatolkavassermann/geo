# Modules
using module ..\modules\Errors.psm1

# Classes
using module ..\classes\World.psm1
using module ..\classes\Plane.psm1

function CreatePlane ([hashtable]$PatternConfiguration, [World]$WorldCoords) {
	[System.String]$ID = GenerateID
	$CoordsAndAngle = GenerateCoordsAndAngle -World $WorldCoords
    [Plane]$PlaneObject = [Plane]::new(        
		$WorldCoords,        
		$PatternConfiguration["patname"],		
		$ID,		
		$PatternConfiguration["refreshrate"],		
		$CoordsAndAngle["Coords"],
		$PatternConfiguration["minspeed"],		
		$PatternConfiguration["maxspeed"],		
		$PatternConfiguration["speedadj"],		
		$PatternConfiguration["speeddec"],		
		$PatternConfiguration["minheight"],		
		$PatternConfiguration["maxheight"],		
		$PatternConfiguration["maxupangle"],        
		$PatternConfiguration["maxrotangle"],        
		$CoordsAndAngle["Angle"]    
	)
    return $PlaneObject
}

function GenerateID ()
{
	[System.Text.StringBuilder]$sb = [System.Text.StringBuilder]::new(16)
	[System.Random]$rand = [System.Random]::new()
	for ($i = 0; $i -lt 16; $i++)
	{
		$l = [System.Text.Encoding]::ASCII.GetString([System.Convert]::ToByte($rand.Next(48, 57)))
		$sb.Append($l) | Out-Null
	}
	return $sb.ToString();
}

function GenerateCoordsAndAngle ([World]$World) {
    [System.Random]$rnd = [System.Random]::new()
	$LatitudeOrLongtitude = $rnd.Next(0, 10)
	switch (($LatitudeOrLongtitude % 2) -eq 0)
	{
		$true
		{
			$UpOrDown = $rnd.Next(0, 10)
			switch (($UpOrDown % 2) -eq 0)
			{
				$true
				{
					$Data = Generator -Quater "00" -World $World
					return $Data;
				}
				
				$false
				{
					$Data = Generator -Quater "01" -World $World
					return $Data;
				}
			}
		}
		
		$false
		{
			$LeftOrRight = $rnd.Next(0, 10)
			switch (($LeftOrRight % 2) -eq 0)
			{
				$true
				{
					$Data = Generator -Quater "10" -World $World
					return $Data;
				}
				
				$false
				{
					$Data = Generator -Quater "11" -World $World
					return $Data;
				}
			}
		}
	}
}

function Generator ([System.String]$Quater, [World]$World) {
    [System.Random]$rnd = [System.Random]::new()
    switch ($Quater)
	{
		"00"
		{
			$lat = $World.WorldsTopLeftCornerCoords[0]
			[System.Double[]]$Data = [System.Double[]]::new(2)
			$Data[0] = $World.WorldsTopLeftCornerCoords[1] 
			$Data[1] = $World.WorldsTopRightCornerCoords[1] 
			switch ($Data[1] -ge $Data[0])
			{
                $true
				{
					$lon = $rnd.Next($Data[0]*1000000,($Data[1]*1000000+1))
                    $lon = $lon / 1000000
				 }
                $false
				{
                    $LeftOrRight = $rnd.Next(0,10)
                    switch ($LeftOrRight % 2 -eq 0) {
                        $true {
                            $lon = $rnd.Next($Data[0]*1000000,180000001)
                            $lon = $lon / 1000000
                         }
                        $false {
                            $lon = $rnd.Next([System.Math]::Abs($Data[1]*1000000),180000001)
                            $lon = $lon / 1000000
                            $lon = $lon * (-1)
                         }
                    }
				}
			}
			$Angle = [System.Random]::new().Next(90, 271)
			$Coords = [System.Double[]]::new(2)
			$Coords[0] = $lat
			$Coords[1] = $lon
			$AngleAndCoords = @{ }
			$AngleAndCoords.Add("Coords", $Coords)  
			$AngleAndCoords.Add("Angle", $Angle)
			$AngleAndCoords.Add("Quater", $Quater)
			return $AngleAndCoords
		}
		
		"01"
		{
			$lat = $World.WorldsBottomLeftCornerCoords[0]
			[System.Double[]]$Data = [System.Double[]]::new(2)
			$Data[0] = $World.WorldsBottomLeftCornerCoords[1]
			$Data[1] = $World.WorldsTopRightCornerCoords[1]
			switch ($Data[1] -ge $Data[0])
			{
                $true
				{
					$lon = $rnd.Next($Data[0]*1000000,($Data[1]*1000000+1))
                    $lon = $lon / 1000000
				 }
                $false
				{
                    $LeftOrRight = $rnd.Next(0,10)
                    switch ($LeftOrRight % 2 -eq 0) {
                        $true {
                            $lon = $rnd.Next($Data[0]*1000000,180000001)
                            $lon = $lon / 1000000
                         }
                        $false {
                            $lon = $rnd.Next([System.Math]::Abs($Data[1]*1000000),180000001)
                            $lon = $lon / 1000000
                            $lon = $lon * (-1)
                         }
                    }
				}
			}
			$Angle = [System.Random]::new().Next(-90, 91)
			switch ($Angle -lt 0)
			{
				$true
				{
					$Angle = 360 + ($Angle)
				}
			}
			$Coords = [System.Double[]]::new(2)
			$Coords[0] = $lat
			$Coords[1] = $lon
			$AngleAndCoords = @{ }
			$AngleAndCoords.Add("Coords", $Coords)
			$AngleAndCoords.Add("Angle", $Angle)
			$AngleAndCoords.Add("Quater", $Quater)
			return $AngleAndCoords
		}
		
		"10"
		{
			$lon = $World.WorldsTopLeftCornerCoords[1]
			[System.Double[]]$Data = [System.Double[]]::new(2)
			$Data[0] = $World.WorldsTopLeftCornerCoords[0]
			$Data[1] = $World.WorldsBottomLeftCornerCoords[0]
			switch ([System.Math]::Abs($Data[0] - $Data[1]) -eq 180) {
                $true {
                    $UpOrDown = $rnd.Next(0,10)
                    switch ($Data[0] -lt 0) {
                        $true {
                            switch ($UpOrDown % 2 -eq 0) {
                                $true {
                                    $lat = $rnd.Next([System.Math]::Abs($Data[0]*1000000),90000001)
                                    $lat = $lat / 1000000
                                    $lat = $lat * (-1)
                                 }
                                $false {
                                    $lat = $rnd.Next([System.Math]::Abs($Data[1]*1000000),90000001)
                                    $lat = $lat / 1000000
                                    $lat = $lat * (-1)
                                 }
                            }
                         }
                        $false {
                            switch ($UpOrDown % 2 -eq 0) {
                                $true {
                                    $lat = $rnd.Next([System.Math]::Abs($Data[0]*1000000),90000001)
                                    $lat = $lat / 1000000
                                 }
                                $false {
                                    $lat = $rnd.Next([System.Math]::Abs($Data[1]*1000000),90000001)
                                    $lat = $lat / 1000000
                                 }
                            }
                         }
                    }
                 }
                $false {
                    switch ($Data[1] -lt 0) {
                        $true {
                            $lat = $rnd.Next($Data[0]*1000000,($Data[1]*1000000+1))
                            $lat = $lat / 1000000
                         }
                        $false {
                            $lat = $rnd.Next($Data[1]*1000000,($Data[0]*1000000+1))
                            $lat = $lat / 1000000
                         }
                    }    
                 }
            }
			$Angle = [System.Random]::new().Next(0, 181)
			$Coords = [System.Double[]]::new(2)
			$Coords[0] = $lat
			$Coords[1] = $lon
			$AngleAndCoords = @{ }
			$AngleAndCoords.Add("Coords", $Coords)
			$AngleAndCoords.Add("Angle", $Angle)
			$AngleAndCoords.Add("Quater", $Quater)
			return $AngleAndCoords
		}
		
		"11"
		{
			$lon = $World.WorldsTopRightCornerCoords[1]
			[System.Double[]]$Data = [System.Double[]]::new(2)
			$Data[0] = $World.WorldsTopLeftCornerCoords[0]
			$Data[1] = $World.WorldsBottomLeftCornerCoords[0]
			switch ([System.Math]::Abs($Data[0] - $Data[1]) -eq 180) {
                $true {
                    $UpOrDown = $rnd.Next(0,10)
                    switch ($Data[0] -lt 0) {
                        $true {
                            switch ($UpOrDown % 2 -eq 0) {
                                $true {
                                    $lat = $rnd.Next([System.Math]::Abs($Data[0]*1000000),90000001)
                                    $lat = $lat / 1000000
                                    $lat = $lat * (-1)
                                 }
                                $false {
                                    $lat = $rnd.Next([System.Math]::Abs($Data[1]*1000000),90000001)
                                    $lat = $lat / 1000000
                                    $lat = $lat * (-1)
                                 }
                            }
                         }
                        $false {
                            switch ($UpOrDown % 2 -eq 0) {
                                $true {
                                    $lat = $rnd.Next([System.Math]::Abs($Data[0]*1000000),90000001)
                                    $lat = $lat / 1000000
                                 }
                                $false {
                                    $lat = $rnd.Next([System.Math]::Abs($Data[1]*1000000),90000001)
                                    $lat = $lat / 1000000
                                 }
                            }
                         }
                    }
                 }
                $false {
                    switch ($Data[1] -lt 0) {
                        $true {
                            $lat = $rnd.Next($Data[0]*1000000,($Data[1]*1000000+1))
                            $lat = $lat / 1000000
                         }
                        $false {
                            $lat = $rnd.Next($Data[1]*1000000,($Data[0]*1000000+1))
                            $lat = $lat / 1000000
                         }
                    } 
                 }
            }
			$Angle = [System.Random]::new().Next(0, 181)
			$Coords = [System.Double[]]::new(2)
			$Coords[0] = $lat
			$Coords[1] = $lon
			$AngleAndCoords = @{ }
			$AngleAndCoords.Add("Coords", $Coords)
			$AngleAndCoords.Add("Angle", $Angle)
			$AngleAndCoords.Add("Quater", $Quater)
			return $AngleAndCoords
		}		
	}
}