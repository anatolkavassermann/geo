```# geo

Версия powershell для Windows: 5.1.18362.628 и выше

Версия powershell для Unix: 7.0.0-rc.2 и выше

Для запуска:
1. Перейдите в директорию, куда был сохранен проект
2. Выполните Import-Module Main.psm1
3. Выполните Main -InitialTime $time_in_milliseconds, где $time_in_milliseconds - время начала процесса генерации объектов

Для вывода данных в формат Excel выполните (работает только на ОС Windows):
1. Перейдите в директорию, куда был сохранен проект
2. Выполните Import-Module Main.psm1
3. Выполните WriteToExcel -OutputExcelFile ./conf/Output.xlsx -OutputConfigFilepath ./conf/Output.txt

Настройка конфигурационного файла:

Особенности строения конфигурационного файла:
Конфигурационный файл состоит из трех секций:
sectionMain, sectionPlanePattern и sectionWorld
В sectionMain указываются шаблоны из секции sectionPlanePattern, по которомым будут генерироваться летательные аппараты, и количество генерируемых летательных аппаратов каждого шаблона.
Пример sectionMain:
    <sectionMain>
        <param>
            <ParamName>PatternsToUse</ParamName> 
            <Data>Boeng|Fighter</Data> #Следует изменять только это значение. Каждый следующий используемый шаблон следует отделять от предыдущего символом "|". Название шаблона не может содержать символа "|".
            <ParamDataType>None</ParamDataType>
        </param>
        <param>
            <ParamName>EachPatternCount</ParamName>
            <Data>250|361</Data> #Следует изменять только это значение. В данном примере будут сгенерированы 250 аппаратов по шаблону Boeng и 361 аппарат по шаблону Fighter. Значениями могут быть только натуральные числа.
            <ParamDataType>None</ParamDataType>
        </param>
    </sectionMain>


В sectionWorld указываются координаты верхнего левого угла квадрата наблюдения и сторона квадрата наблюдения.
Пример sectionWorld: 
    <sectionWorld>
    		<param>
	    			<paramname>Point</paramname>
		    		<data>28|36</data> #Следует изменять только это значение. Первое значение - широта, второе - долгота. Значения обязательно должны быть разделены символом "|". Широта может принимать значения от -180 до 180, долгота: от -90 до 90. Если у числа присутсвует дробная часть, ее необходимо указывать после символа ",", т.е. 100,34576; или 200,12312; или -32,1256
		    		<paramdatatype>Point</paramdatatype>
	    	</param>
	    	<param>
	    		<paramname>Distance</paramname>
		    	<data>100</data> #Следует изменять только это значение. Сторона квадрата наблюдения указывается в километрах и может принимать значения от 1 до 100. Если у числа присутсвует дробная часть, ее необходимо указывать после символа ",", т.е. 100,34576; или 200,12312; или -32,1256
		    	<paramdatatype>Distance</paramdatatype>
	    	</param>
    </sectionWorld>

В sectionPlanePattern задаются характеристики летательных аппаратов.
Шаблоны указываются следующим образом:
		<sectionPlanePattern>
			<Pattern>
				....
			</Pattern>
			<Pattern>
				....
			</Pattern>
			....
			<Pattern>
				....
			</Pattern>
			
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
	<sectionPlanePattern>
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
	</sectionPlanePattern>
	Внимание!
	Если у числа присутсвует дробная часть, ее необходимо указывать после символа ",", т.е. 100,34576; или 200,12312; или -32,1256
```
