# geo

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
