#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root." 1>&2
  exit 1
fi


DIRECTORY=`dirname "$(readlink -f "$0")"`

if [ ! -f $DIRECTORY/preflight.conf ]; then
  echo "Preflight Configuration not found, starting wizard"
  echo '#!/bin/bash' > $DIRECTORY/preflight.conf
  read -p 'Desired Username: ' username
  read -p 'User Full Name: ' user_fullname
  echo -e "username='${username}'" >> $DIRECTORY/preflight.conf
  echo -e "user_fullname='${user_fullname}'" >> $DIRECTORY/preflight.conf
fi

source $DIRECTORY/preflight.conf

echo "Updating Pacman"
pacman -Syy
pacman -Syu
echo "Done Updating Pacman"

# Install Basic XFCE Environment
if ! hash xfce4-session 2>/dev/null; then
  echo "Installing basic XFCE Environment"
  pacman -S xfce4 xfce4-goodies --noconfirm
  echo "Done installing XFCE"
fi

# Install git
if ! hash git 2>/dev/null; then
  echo "Installing Git"
  pacman -S git --noconfirm
  echo "Done installing Git."
fi

# Install salt
if ! hash salt-minion 2>/dev/null; then
  echo "Installing Salt"
  curl -L https://bootstrap.saltstack.com -o bootstrap_salt.sh
  sh bootstrap_salt.sh git develop
  rm bootstrap_salt.sh
  echo "Done installing Salt"
fi

if hash salt-minion 2>/dev/null; then
  mkdir -p /etc/salt/minion.d
  echo "file_client: local" > /etc/salt/minion.d/file_client.conf
  echo -e "file_roots:\n  base:\n    - $DIRECTORY/base" > /etc/salt/minion.d/file_roots.conf
  echo -e "providers:\n  pkg: pacman" > /etc/salt/minion.d/providers.conf
  echo "About to run Salt Highstate"
  salt-call -l debug --local state.highstate pillar="{'username': '${username}', 'user_fullname': '${user_fullname}', 'preflight_dir': '${DIRECTORY}'}"
  echo -e "Run the following to set Numix themes:"
  echo -e "'xfconf-query -c xsettings -p /Net/ThemeName -s \"Numix\"'"
  echo -e "'xfconf-query -c xfwm4 -p /general/theme -s \"Numix\"'"
  echo -e "Job Complete. User ${username} has been created. If you haven't already, run 'passwd ${username}' to set a password"
fi
