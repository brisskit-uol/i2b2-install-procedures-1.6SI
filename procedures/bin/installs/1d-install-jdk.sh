#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Installs the Java SDK:
#
# Mandatory: the I2B2_INSTALL_PROCS_HOME environment variable to be set.
# Optional : the I2B2_INSTALL_WORKSPACE environment variable.
# The latter is an optional full path to a workspace area. If not set, defaults to a workspace
# within the install home.
#
# Pre-reqs:
#   script-file-name.sh has been run at some point to acquire the JDK
#
# USAGE: {script-file-name}.sh job-name
# Where: 
#   job-name is a suitable tag to group all jobs associated with the overall workflow
# Notes:
#   The job-name is used to create a work directory for the overall workflow; eg:
#   I2B2_INSTALL_PROCS_HOME/job-name
#   This work directory must already exist.
#
# Further tailoring can be achieved via the defaults.sh script.
#
# Author: Jeff Lusted (jl99@leicester.ac.uk)
#-----------------------------------------------------------------------------------------------
source $I2B2_INSTALL_PROCS_HOME/bin/common/setenv.sh
source $I2B2_INSTALL_PROCS_HOME/bin/common/functions.sh

#=======================================================================
# First, some basic checks...
#=======================================================================
#
# Check on the usage...
if [ ! $# -eq 1 ]
then
	echo "Error! Incorrect number of arguments."
	echo ""
	print_usage
	exit 1
fi

#
# Retrieve job-name into its variable...
JOB_NAME=$1

#
# It is possible to set your own procedures workspace.
# But if it doesn't exist, we create one for you within the procedures home...
if [ -z $I2B2_INSTALL_WORKSPACE ]
then
	I2B2_INSTALL_WORKSPACE=$I2B2_INSTALL_PROCS_HOME/work
fi

#
# Establish a log file for the job...
WORK_DIR=$I2B2_INSTALL_WORKSPACE/$JOB_NAME
LOG_FILE=$WORK_DIR/$JOB_LOG_NAME

#
# We must already have a work directory for this job step
# (otherwise no acquisitions)...
if [ ! -d $WORK_DIR ]
then
	echo "Error! Could not find work directory."
	echo "Please check acquisitions step has been run and that job name \"$JOB_NAME\" is correct."
	exit 1
fi

#===========================================================================
# Print a banner for this step of the job.
#===========================================================================
print_banner $( basename $0 ) $JOB_NAME $LOG_FILE 

#===========================================================================
# The real work is about to start.
# Give the user a warning...
#=========================================================================== 
echo "About to install JDK..."
echo ""
echo "   Please note detailed log messages are written to $LOG_FILE"
echo "   If you want to see this during execution, try: tail -f $LOG_FILE"
echo ""

#
# Copy JDK installable to the install directory...
JDK_PACKAGE=$( basename $JDK_DOWNLOAD_PATH )
cp $WORK_DIR/$ACQUISITIONS_DIRECTORY/$JDK_PACKAGE $I2B2_INSTALL_DIRECTORY
chmod u+x $I2B2_INSTALL_DIRECTORY/$JDK_PACKAGE

#
# Execute the install package...
cd $I2B2_INSTALL_DIRECTORY
$I2B2_INSTALL_DIRECTORY/$JDK_PACKAGE 
rm $I2B2_INSTALL_DIRECTORY/$JDK_PACKAGE
cd $I2B2_INSTALL_PROCS_HOME/bin/installs

#
# Give jdk a symbolic link...
ln -s $I2B2_INSTALL_DIRECTORY/$JDK_DIRECTORY_NAME $I2B2_INSTALL_DIRECTORY/jdk 

#=========================================================================
# If we got this far, we must be successful...
#=========================================================================
print_message "JDK installation completed." $LOG_FILE
print_footer $( basename $0 ) $JOB_NAME $LOG_FILE