# JAMF-Homebrew

## Install-Homebrew-with-JAMF.sh
	This script will install Homebrew from a policy in JAMF. It will install
	Xcode Command Line Tools if needed as well. The script has logging built in
	that uses the parameters from JAMF.
	
	
###	Jamf Variable Label Names

	Parameter 4 -eq Your log file path. (Recommended "/Library/Logs/<Company Name>")
	Parameter 5 -eq Your log file name. (Recommended "<scriptName>.log")
	Parameter 6 -eq Your Company Name for the Log
	
	You can also test the script from the command line by sending some empty variables.
	(e.x. Install-Homebrew-with-JAMF.sh empty1 empty2 empty3 "/Library/Logs/<Company Name>" "<scriptName>.log" "<Company Name>"
	
	
### Paths for machine type

	This script creates the folder Homebrew in one of the two paths below.
	
		M1/arm64 installs into: /opt/homebrew
		   Intel installs into: /usr/local
		


# Get-Current-Version-of-Homebrew-Extention-Attribute.sh
	This script will create a Jamf extension attribute to record Homebrew version.
	It uses the same method to detect device type and looks where the script installs.
	
	*If Homebrew is installed in different locations this will not detect it!*