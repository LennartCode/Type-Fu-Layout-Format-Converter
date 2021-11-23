# TypeFu-Keyboard-Format-Converter
Convert Windows .klc to Type Fu .tfl files

[Type Fu](https://type-fu.com/) is a great website to practice touch typing with custom keyboard layouts while not having to install them.
You can upload custom keyboard layouts in the .tfl format - nobody elese uses it though. This script allows you to convert .klc file into .tfl. You can generate a .klc file using the (old) [Windows Keyboard Layout Creator MSKLC v1.4](https://www.microsoft.com/en-us/download/details.aspx?id=102134) or [KLFC](https://github.com/39aldo39/klfc) which is cross plattform compatible.

## Usage
1. Fire up a PowerShell:  
1.1 Right-click the Windows icon  
1.2 Select Windows PowerShell  
  
2. Run in PowerShell:  

```path\to\the\script\klctotfl.ps1 -klcFilePath 'path\to\klc\file\thefile.klc' -tflFilePath 'path\to\where\you\want\the\tfl\file\yourFileName.tfl'```



