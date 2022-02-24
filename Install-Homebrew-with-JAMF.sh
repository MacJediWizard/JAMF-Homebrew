#!/bin/bash

##########################################################################################
# General Information
##########################################################################################
#
#
#	Script created By William Grzybowski February 24, 2022
#
#   This script was created to customize the install of Homebrew from a policy in
#   JAMF SelfService. The Users do not need admin privileges to do this install.
#
# 
#	Jamf Variable Label Names
#
#	Parameter 4 -eq Your log file path. (Recommended "/Library/Logs/<Company Name>")
#	Parameter 5 -eq Your log file name. (Recommended "<scriptName>.log")
#	Parameter 6 -eq Your Company Name for the Log
#
##########################################################################################


##########################################################################################
# Version Info
##########################################################################################
#
#   Current Version Number 
    version="1.0.0" 
#
#   Version History 
#   1.0.0 - Initial Creation of Script 
#
##########################################################################################


##########################################################################################
# License information
##########################################################################################
#
#	Copyright (c) 2022 William Grzybowski
#
#	Permission is hereby granted, free of charge, to any person obtaining a copy
#	of this software and associated documentation files (the "Software"), to deal
#	in the Software without restriction, including without limitation the rights
#	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#	copies of the Software, and to permit persons to whom the Software is
#	furnished to do so, subject to the following conditions:
#
#	The above copyright notice and this permission notice shall be included in all
#	copies or substantial portions of the Software.
#
#	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#	SOFTWARE.
#
##########################################################################################


#########################################################################################
# Logging Information
#########################################################################################
#Build Logging for script
logFilePath="${4}"
logFile="${logFilePath}/${5}"
companyName="${6}"
logFileDate=`date +"%Y-%b-%d %T"`

# Check if log path exists
if [ ! -d "$logFilePath" ]; then
    mkdir $logFilePath
fi


# Logging Script
function readCommandOutputToLog(){
    if [ -n "$1" ];	then
        IN="$1"
    else
        while read IN 
        do
            echo "$(date +"%Y-%b-%d %T") : $IN" | tee -a "$logFile"
        done
    fi
}

( # To Capture output into Date and Time log file
    
    # Get Local Info
    logBannerDate=`date +"%Y-%b-%d %T"`
    
    echo " "
    echo "##########################################################################################"
    echo "#                                                                                        #"
    echo "#                 Starting Homebrew Setup on the Mac - $logBannerDate              #"
    echo "#                                                                                        #"
    echo "##########################################################################################"
    echo "${companyName} Homebrew Setup ${version} process on the Mac has Started..."
    
    
    ##########################################################################################
    # Variables
    ##########################################################################################
    loggedInUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
    arch=$(/usr/bin/arch)
    allFiles="/*"
    
    
    ##########################################################################################
    # Core Script
    ##########################################################################################
    
    # Set Homebrew Path Prefix for Machine Type 
    echo "Checking Mac Machine Type"
    if [[ "${arch}" == "arm64" ]]; then
        
        # M1/arm64 machines
        echo "Machine Type is: ${arch}. Setting Homebrew Path prefix to: /opt/homebrew"
        homebrewPrefix="/opt/homebrew"
    
    else
        
        # Intel machines
        echo "Machine Type is: ${arch}. Setting Homebrew Path prefix to: /usr/local"
        homebrewPrefix="/usr/local"
        
    fi
    
    
    # Check if Homebrew exists and if it does update
    echo "Checking in Homebrew in already on the Mac."
    if [[ -e "${homebrewPrefix}/bin/brew" ]]; then
        
        echo "We found Homebrew /bin/brew. We will now update Homebrew since we do not need to install."
        su -l "$loggedInUser" -c "${homebrewPrefix}/bin/brew update"
        echo "Homebrew is now updated. We will Exit."
        exit 0
        
    fi
    
    
    # Checking that we are we in the right group
    echo "Checking that we are in the right group"
    checkGroup=$(groups ${loggedInUser} | grep -c '_developer')
    
    if [[ $checkGroup != 1 ]]; then
        
        echo "${loggedInUser} is not in the _developer group. Adding to group now."
        /usr/sbin/dseditgroup -o edit -a "${loggedInUser}" -t user _developer

    fi
    
    
    # Have the xcode command line tools been installed?
    echo "Checking for the Xcode Command Line Tools installation now"
    checkCLTInstallation=$( pkgutil --pkgs | grep -c "CLTools_Executables" )
    
    if [[ "$checkCLTInstallation" != 1 ]]; then
        
        echo "Xcode Command Line Tools are not installed."
        echo "Installing Xcode Command Line Tools now"
        
        # This temporary file prompts the 'softwareupdate' utility to list the Command Line Tools
        touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
        
        echo "Getting latest version of Xcode Command Line Tools from Apple"
        getCLTLabel=$(softwareupdate -l | grep  "Label: Command Line Tools for Xcode" | tail -1 | sed 's#\* Label: \(.*\)#\1#')
            
        echo "We found ${getCLTLabel} from Apple. Installing now."
        softwareupdate -i "${getCLTLabel}"
        
        rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
        /usr/bin/xcode-select --switch /Library/Developer/CommandLineTools
        echo "${getCLTLabel} is now installed."
    fi


    # Check if homebrew is already installed
    echo "Checking for Homebrew /bin/brew"
    if [[ ! -e "${homebrewPrefix}/bin/brew" ]]; then
        
        echo "We did not find Homebrew /bin/brew."
        
        # Install Homebrew. This doesn't like being run as root so we must do this manually.
        echo "Starting the Homebrew installation now"
        
        echo "Creating the Directory: ${homebrewPrefix}/Homebrew"
        mkdir -p "${homebrewPrefix}/Homebrew"
        
        # Curl down the latest tarball and install to ${homebrewPrefix}/Homebrew
        echo "Getting the latest Homebrew tarball and installing to: ${homebrewPrefix}/Homebrew"
        curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "${homebrewPrefix}/Homebrew"
        
        
        # Manually make all the appropriate directories and set permissions
        echo "Creating all the needed directories in ${homebrewPrefix}/Homebrew"
        mkdir -p "${homebrewPrefix}/Cellar" "${homebrewPrefix}/Homebrew"
        mkdir -p "${homebrewPrefix}/Caskroom" "${homebrewPrefix}/Frameworks" "${homebrewPrefix}/bin"
        mkdir -p "${homebrewPrefix}/include" "${homebrewPrefix}/lib" "${homebrewPrefix}/opt" "${homebrewPrefix}/etc" "${homebrewPrefix}/sbin"
        mkdir -p "${homebrewPrefix}/share/zsh/site-functions" "${homebrewPrefix}/var"
        mkdir -p "${homebrewPrefix}/share/doc" "${homebrewPrefix}/man/man1" "${homebrewPrefix}/share/man/man1"
        
        echo "Setting Permissions on directories in ${homebrewPrefix}/Homebrew"
        chown -R "$loggedInUser":_developer "${homebrewPrefix}/Cellar"
        chown -R "$loggedInUser":_developer "${homebrewPrefix}/Homebrew"
        chown -R "$loggedInUser":_developer "${homebrewPrefix}/Caskroom"
        chown -R "$loggedInUser":_developer "${homebrewPrefix}/Frameworks"
        chown -R "$loggedInUser":_developer "${homebrewPrefix}/bin"
        chown -R "$loggedInUser":_developer "${homebrewPrefix}/include"
        chown -R "$loggedInUser":_developer "${homebrewPrefix}/lib"
        chown -R "$loggedInUser":_developer "${homebrewPrefix}/opt"
        chown -R "$loggedInUser":_developer "${homebrewPrefix}/etc"
        chown -R "$loggedInUser":_developer "${homebrewPrefix}/sbin"
        chown -R "$loggedInUser":_developer "${homebrewPrefix}/share"
        chown -R "$loggedInUser":_developer "${homebrewPrefix}/var"
        chown -R "$loggedInUser":_developer "${homebrewPrefix}/man"
        
        sleep 5
        
        chmod -R g+rwx ${homebrewPrefix}${allFiles}
        chmod 755 "${homebrewPrefix}/share/zsh" "${homebrewPrefix}/share/zsh/site-functions"
        
        
        # Create a system wide cache folder
        echo "Creating a System Wide Cache folder."
        mkdir -p /Library/Caches/Homebrew
        chmod g+rwx /Library/Caches/Homebrew
        chown "${loggedInUser}:_developer" /Library/Caches/Homebrew
        
        
        # put brew where we can find it
        echo "Creating a link so we can find it at: ${homebrewPrefix}/bin/brew"
        ln -s "${homebrewPrefix}/Homebrew/bin/brew" "${homebrewPrefix}/bin/brew"
        
        
        # Install the MD5 checker or the recipes will fail
        echo "Installing the MD5 checker for Recipes"
        su -l "$loggedInUser" -c "${homebrewPrefix}/bin/brew install md5sha1sum"
        
        echo 'export PATH="${homebrewPrefix}/opt/openssl/bin:$PATH"' | tee -a /Users/${loggedInUser}/.bash_profile /Users/${loggedInUser}/.zshrc
        chown ${loggedInUser} /Users/${loggedInUser}/.bash_profile /Users/${loggedInUser}/.zshrc
        
        
        # clean some directory stuff for Catalina
        chown -R root:wheel /private/tmp
        chmod 777 /private/tmp
        chmod +t /private/tmp
        
        # Adding to path directory
        touch /etc/paths.d/brew
        echo "${homebrewPrefix}/bin" > /etc/paths.d/brew
    fi
    
    
    # Make sure everything is up to date
    echo "Make sure Homebrew is up to date."
    su -l "$loggedInUser" -c "${homebrewPrefix}/bin/brew update"
    
    
    # Log install is complete
    echo "The Homebrew installation in now complete."
    
    
    exit 0
    
    
) 2>&1 | readCommandOutputToLog # To Capture output into Date and Time log file