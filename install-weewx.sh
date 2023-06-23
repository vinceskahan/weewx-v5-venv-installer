#----------------------------------------------------
# install weewx v5 in a python3 venv
# (tested in debian12 vagrant box)
#
# NOTE - this uses the 'source' command
#        which is a bash builtin, so this
#        should be invoked as "bash scriptname"
#----------------------------------------------------
#
# TESTED IN VAGRANT ON:
#    debian12
#    ubuntu2204
#    rocky9
#    almalinux9
#
# can't test centos/9 - no official vagrant boxes released
# can't test rhel/9   - no official vagrant boxes released
# can't test fedora   - no official vagrant boxes released
#
#
# TESTING NOTE:
#   running 'apt-get upgrade -y' can sometimes still pop a
#   dialog box causing this script to hang, asking what to
#   do with pre-existing os config files.  This was seen in
#   updating the ssh package(s) to current while using an
#   old vagrant base box.   It would be likely wiser to
#   do the os package updates outside this script....
#


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

function upgrade_apt() {
    echo "updating apt"
    run_command "sudo apt-get update"
    echo "upgrading dpkg packages"
    run_command "sudo apt-get upgrade -y"
}

function upgrade_rpm() {
    echo "upgrading rpm packages"
    run_command "sudo yum update -y"
}

function os_prerequisites_rpm() {
    echo "installing pip"
    run_command "sudo yum install -y python3-pip"
}

echo "#-----------------------------------------" >  $LOGFILE
echo "# installing weewx v5 in python venv      " >> $LOGFILE
echo "# `date` "                                  >> $LOGFILE
echo "#-----------------------------------------" >> $LOGFILE
echo ""                                           >> $LOGFILE

echo "installing weewx..."

echo "detecting os family and upgrading os packages"
if [ -f /etc/os-release ]
then
    . /etc/os-release
fi
case ${ID} in
debian)    upgrade_apt; 
           run_command "sudo apt-get install -y python3-pip python3-venv";
           ;;
ubuntu)    upgrade_apt;
           run_command "sudo apt-get install -y python3-pip python3-venv";
           ;;
rocky)     upgrade_rpm;
           run_command "sudo yum install -y python3-pip";
           run_command "sudo pip3 install virtualenv"
           ;;
almalinux) upgrade_rpm;
           run_command "sudo yum install -y python3-pip";
           run_command "sudo pip3 install virtualenv"
           ;;
fedora)    upgrade_rpm;
           run_command "sudo yum install -y python3-pip";
           run_command "sudo pip3 install virtualenv"
           ;;
*)         echo "unknown os family - exiting" ; exit 1;;
esac

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

# this is u.g.l.y. but lets force it for now to nuke selinux so the daemon starts
if [ -f /usr/sbin/setenforce ]
then
    echo "disabling selinux - TEMPORARY DEVELOPMENT HACK ALERT"
    run_command "sudo setenforce 0"
fi

echo "start weewx"
run_command "sudo systemctl start weewx"

echo "done"

