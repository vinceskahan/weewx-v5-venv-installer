
Demonstration script to install v5 weewx in a python venv

To install:
   bash install-weewx.sh
or
   curl https://raw.githubusercontent.com/vinceskahan/weewx-v5-venv-installer/main/install-weewx.sh | bash

Detailed log is in ${HOME}/install-weewx.log

Contents:
   install-weewx.sh           the script
   install-weewx.log          sample logfile from a debian12 vagrant box
   example-stdout.txt         what a successful installation looks like

Notes:
  - please 'read' the script.  It is heavily commented.
  - this installs my 'mem' extension as a test of the extension installer
  - it also installs nginx and configures weewx into the nginx web docroot
  - if you don't like any of the above, "when in doubt comment it out"
