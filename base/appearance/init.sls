xfce:
  pkg.group_installed:
    - name: xfce4

xfce.goodies:
  pkg.group_installed:
    - name: xfce4-goodies

xfce.x:
  pkg.latest:
    - pkgs:
      - xorg-server
      - xorg-server-utils
      - xorg-xinit

xfce.xorg-apps:
  pkg.group_installed:
    - name: xorg-apps

xfce.light-locker:
  pkg.latest:
    - name: light-locker

  file.managed:
    - name: /usr/local/bin/xflock4
    - source: salt://appearance/files/xflock4
    - mode: 755

xfce.lightdm:
  pkg.latest:
    - pkgs:
      - lightdm
      - lightdm-gtk-greeter
      - xorg-server-xephyr
      - accountsservice

  service.enabled:
    - name: lightdm

  file.symlink:
    - name: /etc/systemd/system/display-manager.service
    - target: /usr/lib/systemd/system/lightdm.service
    - force: True

desktop.backgrounds:
  file.recurse:
    - source: salt://appearance/files/backgrounds
    - name: /home/{{ pillar['username'] }}/.backgrounds
    - makedirs: True

include:
  - .numix
  - .xfce
