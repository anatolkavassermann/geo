<#
    Класс, хранящий в себе координаты мира
#>

class World {
    [System.Double[]]$WorldsTopLeftCornerCoords
    [System.Double[]]$WorldsBottomLeftCornerCoords
    [System.Double[]]$WorldsTopRightCornerCoords
    
    World (
        [System.Double[]]$WorldsTopLeftCornerCoords,
        [System.Double[]]$WorldsBottomLeftCornerCoords,
        [System.Double[]]$WorldsTopRightCornerCoords
    ) {
        $this.WorldsBottomLeftCornerCoords = $WorldsBottomLeftCornerCoords
        $this.WorldsTopLeftCornerCoords = $WorldsTopLeftCornerCoords
        $this.WorldsTopRightCornerCoords = $WorldsTopRightCornerCoords
    }
}