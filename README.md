# JAMF-Homebrew

## Install-Homebrew-with-JAMF.sh
	This script will install homebrew from a policy in JAMF. It will install
	Xcode Command Line Tools if needed as well. The script has logging built in
	that uses the parameters from JAMF.
	
	
###	Jamf Variable Label Names

	Parameter 4 -eq Your log file path. (Recommended "/Library/Logs/<Company Name>")
	Parameter 5 -eq Your log file name. (Recommended "<scriptName>.log")
	Parameter 6 -eq Your Company Name for the Log
	
	

## Paths for machine type

	This script creates the folder Homebrew in one of the two paths below.
	
		M1/arm64 installs into /opt/homebrew
		Intel installs into /usr/local
		

# Get-Current-Version-of-Homebrew-Extention-Attribute.sh
	This script will produce a Jamf extension attribute to record brew version.
	It uses the same method to detect device type and looks where the script installs.
	
	*If brew is installed in different locations this will not detect it!*