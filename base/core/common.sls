core.common:
  pkg.latest:
    - pkgs:
      - wget

core.remmina:
  pkg.latest:
    - name: remmina

core.remmina.rdp:
  pkg.latest:
    - name: freerdp

core.slack:
  git.latest:
    - name: https://aur.archlinux.org/slack-desktop.git
    - target: {{ pillar['preflight_dir'] }}/builds/slack-desktop
    - user: {{ pillar['username'] }}

  cmd.wait:
    - name: makepkg -si
    - cwd: {{ pillar['preflight_dir'] }}/builds/slack-desktop
    - watch:
      - git: core.slack
    - runas: {{ pillar['username'] }}

core.ssh:
  pkg.latest:
    - name: openssh

  file.directory:
    - name: /home/{{ pillar['username'] }}/.ssh
    - runas: {{ pillar['username'] }}

core.ssh.authorized_keys:
  file.touch:
    - name: /home/{{ pillar['username'] }}/.ssh/authorized_keys
    - runas: {{ pillar['username'] }}
