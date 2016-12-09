{% set pid = salt['cmd.run']('pgrep xfce4-session') %}
{% set dbus = salt['cmd.run']('grep -z DBUS_SESSION_BUS_ADDRESS /proc/' ~ pid ~ '/environ|cut -d= -f2-') %}

numix.theme:
  pkg.latest:
    - name: numix-themes

numix-holo.theme:
  git.latest:
    - name: https://github.com/seanherron/Numix-Holo.git
    - target: /usr/share/themes/Numix-Holo
    - force_clone: True

