function Invoke-PowerWebShot{
 Param
  (
    [Parameter(Position = 0, Mandatory = $false)]
    [string]
    $URL = "",

    [Parameter(Position = 1, Mandatory = $false)]
    [string]
    $UrlList = "",

    [Parameter(Position = 2, Mandatory = $false)]
    [string]
    $Threads = "",

    [Parameter(Position = 3, Mandatory = $false)]
    [string]
    $OutputDir = ""
  )

  if (($URL -eq "") -and ($UrlList -eq ""))
    {
        Write-Output "[*] No URL's were specified to be scanned. Please use the -URL option to specify a single URL or -UrlList to specify a list."
        break
    }

$SeleniumDriverPath = ".\WebDriver.dll"
Add-Type -path $SeleniumDriverPath
[OpenQA.Selenium.PhantomJS.PhantomJSOptions]$options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
$cli_args = @()
$cli_args +=  "--web-security=no"
$cli_args += "--ignore-ssl-errors=yes"
$options.AddAdditionalCapability("phantomjs.cli.args", $cli_args)
$options.AddAdditionalCapability("phantomjs.page.settings.ignore-ssl-errors", $true)
$options.AddAdditionalCapability("phantomjs.page.settings.webSecurityEnabled", $false)
$options.AddAdditionalCapability("phantomjs.page.settings.userAgent", "Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv:11.0) like Gecko")
$phantomjspath = ".\"
$driver = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver($phantomjspath, $options)

$driver.Url = "about:constant"

$location = get-location
$date = get-date -Format MM-dd-yyyy
$dir = New-Item -ItemType Directory -Path .\$date -Force #mkdir $date -ErrorAction SilentlyContinue
$OutputDir = "$location\$date"


$Provider=New-Object Microsoft.CSharp.CSharpCodeProvider
$Compiler=$Provider.CreateCompiler()
$Params=New-Object System.CodeDom.Compiler.CompilerParameters
$Params.GenerateExecutable=$False
$Params.GenerateInMemory=$True
$Params.IncludeDebugInformation=$False
$Params.ReferencedAssemblies.Add("System.DLL") > $null

$TASource=@'
  namespace Local.ToolkitExtensions.Net.CertificatePolicy {
    public class TrustAll : System.Net.ICertificatePolicy {
      public TrustAll() { 
      }
      public bool CheckValidationResult(System.Net.ServicePoint sp,
        System.Security.Cryptography.X509Certificates.X509Certificate cert, 
        System.Net.WebRequest req, int problem) {
        return true;
      }
    }
  }
'@ 
  $TAResults=$Provider.CompileAssemblyFromSource($Params,$TASource)
  $TAAssembly=$TAResults.CompiledAssembly

 
  $TrustAll=$TAAssembly.CreateInstance("Local.ToolkitExtensions.Net.CertificatePolicy.TrustAll")
  [System.Net.ServicePointManager]::CertificatePolicy=$TrustAll
  
function EscapeFileName{
        param($filename)

        $pattern = "[{0}]" -f ([Regex]::Escape([String] [System.IO.Path]::GetInvalidFileNameChars()))              
        $newfile = [Regex]::Replace($filename, $pattern, '')
        $newfile
    }

$global:images = @()
$global:UrlNames = @()
$global:PrevName = ""


function Take-ScreenShot{
        param($driver, $name)        
        
        $fileName = ($name + ".png")
        $fileName = EscapeFileName -filename $fileName
        $driver.Url = $name
        $driver.Manage().Window
       
        
            if (($driver.Url -eq "") -or ($driver.Url -eq "about:blank") -or ($driver.Url -eq "about:constant") -or ($driver.Url -eq $PrevName))
            {
                Write-Output "[*] Something went wrong for $name"
            }
            else
            {
            $driver.GetScreenshot().SaveAsFile(($Outputdir + "\" + $fileName), [System.Drawing.Imaging.ImageFormat]::Png)
            $global:images += $filename
            $global:UrlNames += $name
            }

        
            $global:PrevName = $driver.Url
            $driver.Navigate().Back()
    
  }

If($URL -ne "")
    {
        Take-ScreenShot -driver $driver -name $URL

    } 
else
    {
        $URLArray = @()
        $URLArray = Get-Content $UrlList
        Foreach ($link in $UrlArray)
            {
                Write-Output "[*] Now analyzing $link"
                Take-ScreenShot -driver $driver -name $link
            }
    }

function GenerateHtml{
    param($images, $OutputPath)
    $Html = @()
    $Html = "<html><body>
    <style>

</style>"
    $counter = 0
    foreach($img in $images)
    {
	    
        $Html += '<div id ="wrapper">
<div id ="sidebar"><p><a href="'
        $Html += $global:UrlNames[$counter]
        $Html += '"><font size="20"><b>'
        $Html += $global:UrlNames[$counter]
        $Html += '</font></a></p></div>'
        $Html += '<div id ="content">'
        $Html += '<div id="sample"><a href="'
        $Html += $img
        $Html += '">'
        $Html += "<img src='$img' style=`"width:100%`"/></a></div></div>"
        $Html += '<div id="cleared"></div>
</div>
<br>
<br>
<br>'
        
        $counter++
    }
    $Html += "</body></html>"
    $date = (get-date -f yyyy-MM-dd)
    $Html | Out-File -FilePath ($OutputPath + "\" + $date + "_report.html")
    }

GenerateHtml -images $global:images -OutputPath $Outputdir

$driver.Quit()


}
Invoke-powerwebshot -Urllist urls.txt 