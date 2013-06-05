#!/bin/bash
#
# Install script for i2b2 Workplace Framework cell
#
# Mandatory: the I2B2_INSTALL_PROCS_HOME environment variable to be set.
# Optional : the I2B2_INSTALL_WORKSPACE environment variable.
# The latter is an optional full path to a workspace area. If not set, defaults to a workspace
# within the install home.
#
# USAGE: {script-file-name}.sh job-name
# Where: 
#   job-name is a suitable tag to group all jobs associated with the overall workflow
# Notes:
#   The job-name is used to locate a work directory for the overall workflow; eg:
#   I2B2_INSTALL_PROCS_HOME/job-name
#   This work directory must already exist.
#
# Further tailoring can be achieved via the defaults.sh script.
#
# Stops and starts JBoss.
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
echo "About to install i2b2 workplace cell..."
echo ""
echo "   Please note detailed log messages are written to $LOG_FILE"
echo "   If you want to see this during execution, try: tail -f $LOG_FILE"
echo ""

#
# Verify JBOSS is not running.
echo "Attempting to stop JBoss, if it is running."
$JBOSS_HOME/bin/shutdown.sh -S >/dev/null 2>/dev/null 
sleep 65

#
# Copy some build/config files to required locations and substitute variables...
merge_config $I2B2_INSTALL_PROCS_HOME/config/config.properties \
             $I2B2_INSTALL_PROCS_HOME/config/$DB_TYPE/work-cell/build.properties \
             $WORK_DIR/$SOURCE_DIRECTORY/edu.harvard.i2b2.workplace/build.properties
exit_if_bad $? "Failed to merge properties into $WORK_DIR/$SOURCE_DIRECTORY/edu.harvard.i2b2.workplace/build.properties" $LOG_FILE

merge_config $I2B2_INSTALL_PROCS_HOME/config/config.properties \
             $I2B2_INSTALL_PROCS_HOME/config/$DB_TYPE/work-cell/work-ds.xml \
             $WORK_DIR/$SOURCE_DIRECTORY/edu.harvard.i2b2.workplace/etc/jboss/work-ds.xml
exit_if_bad $? "Failed to merge properties into $WORK_DIR/$SOURCE_DIRECTORY/edu.harvard.i2b2.workplace/etc/jboss/work-ds.xml" $LOG_FILE

merge_config $I2B2_INSTALL_PROCS_HOME/config/config.properties \
             $I2B2_INSTALL_PROCS_HOME/config/$DB_TYPE/work-cell/workplace_application_directory.properties \
             $WORK_DIR/$SOURCE_DIRECTORY/edu.harvard.i2b2.workplace/etc/spring/workplace_application_directory.properties
exit_if_bad $? "Failed to merge properties into $WORK_DIR/$SOURCE_DIRECTORY/edu.harvard.i2b2.workplace/etc/spring/workplace_application_directory.properties" $LOG_FILE

merge_config $I2B2_INSTALL_PROCS_HOME/config/config.properties \
             $I2B2_INSTALL_PROCS_HOME/config/$DB_TYPE/work-cell/workplace.properties \
             $WORK_DIR/$SOURCE_DIRECTORY/edu.harvard.i2b2.workplace/etc/spring/workplace.properties
exit_if_bad $? "Failed to merge properties into $WORK_DIR/$SOURCE_DIRECTORY/edu.harvard.i2b2.workplace/etc/spring/workplace.properties" $LOG_FILE

#============================
# Deploy Workplace cell
#============================
print_message "" $LOG_FILE
print_message "About to deploy Workplace Framework cell." $LOG_FILE

cd $WORK_DIR/$SOURCE_DIRECTORY/edu.harvard.i2b2.workplace
$ANT_HOME/bin/ant -f master_build.xml \
                  clean build-all deploy \
                  >>$LOG_FILE 2>>$LOG_FILE 
exit_if_bad $? "Failed to deploy Workplace Framework." $LOG_FILE
print_message "Success! Workplace Framework cell deployed." $LOG_FILE

#====================================
# START JBOSS (as a background task)
#====================================
print_message "" $LOG_FILE
print_message "Starting JBoss in the background..." $LOG_FILE
$JBOSS_HOME/bin/run.sh -b 0.0.0.0 >>$LOG_FILE 2>>$LOG_FILE &

sleep 65
echo ""
echo "Services should have started, but please check the install log or the JBoss logs."
echo "In a browser, use the following URL: $LIST_SERVICES_URL"
echo "to verify WorkplaceService is listed as active."

#=========================================================================
# If we got this far, we must be successful (hopefully) ...
#=========================================================================
print_message "Workplace Framework install complete." $LOG_FILE
print_footer $( basename $0 ) $JOB_NAME $LOG_FILE