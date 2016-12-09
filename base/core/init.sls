core.user:
  user.present:
    - name: {{ pillar['username'] }} 
    - fullname: {{ pillar['user_fullname'] }}
    - shell: /bin/bash
    - home: /home/{{ pillar['username'] }}
    - createhome: True
    - gid: users
    - optional_groups:
      - video
      - audio
      - network
      - optical
      - storage
      - disk
      - wheel

  file.append:
    - name: /etc/sudoers.d/sean
    - text: "{{ pillar['username'] }} ALL=(ALL) ALL"
    - makedirs: True

core.wheel:
  file.append:
    - name: /etc/sudoers.d/wheel
    - text: "%wheel ALL=(ALL) ALL"
    - makedirs: True

core.aur:
  pkg.group_installed:
    - name: base-devel

include:
  - .pulseaudio
  - .common
