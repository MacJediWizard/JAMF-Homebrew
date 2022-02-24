#!/bin/bash

##########################################################################################
# General Information
##########################################################################################
#
#	Extention Attribute created By William Grzybowski February 24, 2022
#
#   This Extention Attribute was created to return the version of HomeBrew
#   installed on the Mac in JAMF.
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
#   1.0.0 - Initial Creation of EA
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


##########################################################################################
# Variables
##########################################################################################
# Default Answer to desplay in JAMF
RESULT="Not Found"

# Find machine type
arch=$(/usr/bin/arch)


##########################################################################################
# Core Script for Extention Attribute
##########################################################################################

# Check Mac Machine Type 
if [[ "${arch}" == "arm64" ]]; then
    
    # M1/arm64 machines
    if [[ -e /opt/homebrew/bin/brew ]]; then
        
        RESULT=$(/opt/homebrew/bin/brew -v | head -n 1 | awk '{ print $2 }')
        
    fi 
    
else
    
    # Intel machines
    if [[ -e /usr/local/bin/brew ]]; then
        
        RESULT=$(/usr/local/bin/brew -v | head -n 1 | awk '{ print $2 }')
        
    fi
    
fi


##########################################################################################
# Result to Desplay Extention Attribute
##########################################################################################

echo "<result>$RESULT</result>"