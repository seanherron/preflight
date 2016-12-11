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

core.ssh:
  pkg.latest:
    - name: openssh

  file.directory:
    - name: /home/{{ pillar['username'] }}/.ssh
    - runas: {{ pillar['username'] }}
    - user: {{ pillar['username'] }}

core.ssh.authorized_keys:
  file.touch:
    - name: /home/{{ pillar['username'] }}/.ssh/authorized_keys
    - runas: {{ pillar['username'] }}
