# Classes
using module .\World.psm1

# Engines
using module ..\engines\CoordsCalculation.psm1

# Modules
using module ..\modules\Errors.psm1

Class Plane {
    [World]$World
	[System.Boolean]$CanFly
	[System.String]$PatName
	[System.String]$ObjID
	[System.Double]$RefreshRate
	[System.Double[]]$Coords
	[System.Double]$MinSpeed
	[System.Double]$MaxSpeed
	[System.Double]$CurSpeed
	[System.Double]$SpeedAdj
	[System.Double]$SpeedDec
	[System.Double]$MinHeight
	[System.Double]$MaxHeight
	[System.Double]$CurHeight
	[System.Double]$MaxUpAngle
	[System.Double]$CurUpDownAngle
	[System.Double]$MaxRotAngle
	[System.Double]$CurAngle
    [System.Double]$CurRotAngle
    
    Plane (
        [World]$_world,
		[System.String]$_patName,
		[System.String]$_objID,
		[System.Double]$_refreshRate,
		[System.Double[]]$_coords,
		[System.Double]$_minSpeed,
		[System.Double]$_maxSpeed,
		[System.Double]$_speedAdj,
		[System.Double]$_speedDec,
		[System.Double]$_minHeight,
		[System.Double]$_maxHeight,
		[System.Double]$_maxUpAngle,
		[System.Double]$_maxRotAngle,
		[System.Double]$_curAngle
    ) {
        [System.Random]$rnd = [System.Random]::new()
        $this.World = $_world
		$this.CanFly = $true
		$this.PatName = $_patName
		$this.ObjID = $this.PatName + "-" + $_objID
		$this.RefreshRate = $_refreshRate
		$this.Coords = $_coords
		$this.MinSpeed = $_minSpeed
		$this.MaxSpeed = $_maxSpeed
		$this.CurSpeed = $rnd.Next($_minSpeed, $_maxSpeed)
		$this.SpeedAdj = $_speedAdj
		$this.SpeedDec = $_speedDec
		$this.MinHeight = $_minHeight
		$this.MaxUpAngle = $_maxUpAngle
		$this.MaxHeight = $_maxHeight
		$this.CurHeight = $rnd.Next($_minHeight, $_maxHeight)
		$this.MaxRotAngle = $_maxRotAngle
		$this.CurAngle = $_curAngle
		$this.CurUpDownAngle = $rnd.Next(0, $_maxUpAngle)
		$this.CurRotAngle = $rnd.Next(0, $_maxRotAngle)
    }

    hidden [void] IncreaseSpeed ()
	{
		if (($this.CurSpeed -lt $this.MaxSpeed) -and (($this.MaxSpeed - $this.CurSpeed) -ge $this.SpeedAdj))
		{
			$this.CurSpeed += $this.SpeedAdj
		}
		
		if (($this.CurSpeed -lt $this.MaxSpeed) -and (($this.MaxSpeed - $this.CurSpeed) -lt $this.SpeedAdj))
		{
			$this.CurSpeed = $this.MaxSpeed
		}
		
		return;
	}
	
	hidden [void] DecreaseSpeed ()
	{
		
		if (($this.CurSpeed -gt $this.MinSpeed) -and (($this.CurSpeed - $this.MinSpeed) -ge $this.SpeedDec))
		{
			$this.CurSpeed -= $this.SpeedDec
		}
		
		if (($this.CurSpeed -gt $this.MinSpeed) -and (($this.CurSpeed - $this.MinSpeed) -lt $this.SpeedDec))
		{
			$this.CurSpeed = $this.MinSpeed
		}
		
		return;
    }
    
    hidden [void] Ch_A ()
	{
		switch ($this.CurAngle -ge 360)
		{
			$true
			{
				$this.CurAngle = $this.CurAngle - 360
			}
		}
		
		switch ($this.CurAngle -lt 0)
		{
			$true
			{
				$this.CurAngle = $this.CurAngle + 360
			}
		}
	}

    hidden [void] RotateLeft ()
	{
		if (($this.CurRotAngle + 1) -lt $this.MaxRotAngle)
		{
			$this.CurRotAngle += 1
		}
		
		$this.CurAngle += $this.CurRotAngle
		if ($this.CurRotAngle -eq 0)
		{
			$this.CurAngle += 1
		}
		$this.Ch_A()
		return;
	}
	
	hidden [void] RotateRight ()
	{
		(($this.CurRotAngle - 1) -gt (($this.MaxRotAngle) * (-1)))
		{
			$this.CurRotAngle -= 1
		}
		
		$this.CurAngle += $this.CurRotAngle
		if ($this.CurRotAngle -eq 0)
		{
			$this.CurAngle -= 1
		}
		$this.Ch_A()
		return;
	}
	
	hidden [void] NoseUp ()
	{
		
		if (($this.CurUpDownAngle + 1) -lt (($this.MaxUpAngle)))
		{
			$this.CurUpDownAngle += 1
		}
		
		return;
	}
	
	hidden [void] NoseDown ()
	{
		if (($this.CurUpDownAngle - 1) -gt (($this.MaxUpAngle) * (-1)))
		{
			$this.CurUpDownAngle -= 1
		}
		
		return;
    }
    
    hidden [System.Double[]] CalculateTempCoords ([System.Double]$DistanceToGo) {
        [System.Double[]]$TempCoords = $this.Coords
        $TempCoords = CalculateCoords -InitCoords $TempCoords -InitAngle $this.CurAngle -DistanceToGo $DistanceToGo
        return $TempCoords
    }

    [void] Move() {
        [System.Double]$DistanceGone = $this.CurSpeed/(3600000/$this.RefreshRate)
        $DistanceGone = $DistanceGone * [System.Math]::Cos($this.CurUpDownAngle)
        [System.Double]$HeightGone = $DistanceGone * [System.Math]::Tan($this.CurUpDownAngle)
        $this.CurHeight += $HeightGone
        switch (
                ($this.CurHeight -gt $this.MaxHeight) -or `
                ($this.CurHeight -lt $this.MinHeight)) {
            $true {
                $this.CanFly = $false
                return
             }
		}
		
		[System.Double[]]$TempCoords = [System.Double[]]::New(2)
		$TempCoords = CalculateCoords -InitCoords $this.Coords -InitAngle $this.CurAngle -DistanceToGo $DistanceGone
		# Провека выхода за широту

        switch ([System.Math]::Abs($this.World.WorldsTopLeftCornerCoords[1] - $this.World.WorldsBottomLeftCornerCoords[1]) -eq 180) {
            $true {
                switch ($this.World.WorldsTopLeftCornerCoords[0] -lt 0) {
                    $true {
                        switch (($TempCoords[0] -gt $this.World.WorldsTopLeftCornerCoords[0]) -or ($TempCoords[0] -gt $this.World.WorldsBottomLeftCornerCoords[0]))
						{
							$true
							{
								$this.CanFly = $false
								return;
							}
						}
                     }
                    $false {
                        switch (($TempCoords[0] -lt $this.World.WorldsTopLeftCornerCoords[0]) -or ($TempCoords[0] -lt $this.World.WorldsBottomLeftCornerCoords[0]))
						{
							$true
							{
								$this.CanFly = $false
								return;
							}
						}
                     }
                }
             }
            $false {
                switch (
                    ($TempCoords[0] -gt $this.World.WorldsTopLeftCornerCoords[0]) -or `
                    ($TempCoords[0] -lt $this.World.WorldsBottomLeftCornerCoords[0])
                 ){
                    $true {
                        $this.CanFly = $false
                        return
                     }
                }
             }
        }

        # Проверка выхода за долготу

        switch (($TempCoords[1] -lt $this.World.WorldsTopLeftCornerCoords[1]) -or ($TempCoords[1] -gt $this.World.WorldsTopRightCornerCoords[1]))
		{
			$true
			{
				$this.CanFly = $false
				return;
			}
        }
        
        $this.Coords = $TempCoords
        return
    }

    [void] MakeStep () {
        [System.Random]$rnd = [System.Random]::new()
        switch ($this.CanFly) {
            $true {
                [System.Int16]$Command = $rnd.Next(0, 7)
                switch ($Command)
			    {
				    0
				    {
			    		$this.RotateLeft()
			    		$this.Move()
			    	}
                    1
				    {
				    	$this.RotateRight()
				    	$this.Move()
				    }
    				2
	    			{
		    			$this.IncreaseSpeed()
			    		$this.Move()
				    }
    				3
	    			{
		    			$this.DecreaseSpeed()
			    		$this.Move()
				    }
    				4
	    			{
		    			$this.NoseUp()
			    		$this.Move()
				    }
    				5
    				{
	    				$this.NoseDown()
		    			$this.Move()
			    	}
				    default
    				{
	    				$this.Move()
		    		}
			    }
            }
        }
    }
}