IntelShot - Is nothing more than PowerWebsShot found at https://github.com/dafthack/PowerWebShot/blob/master/PowerWebShot.ps1 just slightly modified.

Tool was modified to assist my intel analyst do quick review of Intel web sites they visit on a daily basis.  

**Special thanks to dafthack for doing all the hard work!

## Requirements
This tool utilizes Selenium and PhantomJS to screenshot web servers. I've included the phantomjs.exe and Selenium WebDriver.dll in this repository but if you would like to download them directly from their sources they can be found here:

Selenium - http://www.seleniumhq.org/download/

PhantomJS -http://phantomjs.org/

The phantomjs.exe and WebDriver.dll must be in the current working directory of the IntelShot.ps1 script.

## Usage
1. Download zip or git clone
2. unzip
3. Add your URLs to urls.txt and save.
4. Double click Run_IntelShot shotcut which runs this command "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -Sta -W hidden -File IntelShot.ps1"
5. Creates a folder within directory with "today's date".
6. Give it a few moments to run, a file with appear within the new directory "today_date.html".

**Pleas note if you run this more than once with the same date it will overwrite previous ran items unless you rename the folder.
