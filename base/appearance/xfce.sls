xfce4.panel.whiskermenu:
  pkg.latest:
    - name: xfce4-whiskermenu-plugin

xfce4.panel.config:
  file.managed:
    - name: /home/{{ pillar['username'] }}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
    - source: salt://appearance/files/xfce4-panel.xml

xfce4.xfwm4:
  file.managed:
    - name: /home/{{ pillar['username'] }}/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
    - source: salt://appearance/files/xfwm4.xml


