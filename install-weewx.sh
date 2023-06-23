#----------------------------------------------------
# install weewx v5 in a python3 venv
# (tested in debian12 vagrant box)
#
# NOTE - this uses the 'source' command
#        which is a bash builtin, so this
#        should be invoked as "bash scriptname"
#----------------------------------------------------

LOGFILE=${HOME}/install-weewx.log

function run_command() {
    cmd=$1
    echo "#-------------------------------------" >> $LOGFILE
    echo "# running command: ${cmd}" >> $LOGFILE
    echo "#-------------------------------------" >> $LOGFILE
    ${cmd} >> $LOGFILE 2>&1
    retval=$?
    if [ "x${retval}" = "x0" ]
    then
	echo "   ok"
    else 
        echo "#  failed - error ${retval}" >> $LOGFILE
        echo "   failed - error ${retval}"
        # TO DO - this should back out previous steps (possibly)
        # TO DO - this should abort out gracefully (probably)
    fi
    echo "#"                                      >> $LOGFILE
}

echo "#-----------------------------------------" >  $LOGFILE
echo "# installing weewx v5 in python venv      " >> $LOGFILE
echo "# `date` "                                  >> $LOGFILE
echo "#-----------------------------------------" >> $LOGFILE
echo ""                                           >> $LOGFILE

echo "installing weewx..."

echo "updating apt"
run_command "sudo apt-get update"

echo "upgrading packages"
run_command "sudo apt-get upgrade -y"

echo "installing python venv modules"
run_command "sudo apt-get install -y python3-pip python3-venv"

echo "creating python venv"
run_command "python3 -m venv weewx-data"

echo "activating python venv"
run_command "source weewx-data/bin/activate"

echo "cd to venv"
run_command "cd weewx-data"

echo "installing weewx"
run_command "pip3 install weewx"

echo "create default Simulator station"
run_command "weectl station create --no-prompt"

echo "install systemd service"
run_command "sudo cp ./util/systemd/weewx.service /lib/systemd/system/weewx.service"

echo "reloading systemd"
run_command "sudo systemctl daemon-reload"

echo "enable weewx"
run_command "sudo systemctl enable weewx"

echo "start weewx"
run_command "sudo systemctl start weewx"

echo "done"

