zsh.install:
  pkg.latest:
    - name: zsh

zsh.prezto.install:
  git.latest:
    - name: https://github.com/seanherron/prezto.git
    - target: /home/{{ pillar['username'] }}/.prezto
    - force_clone: True
    - force_checkout: True
    - user: {{ pillar['username'] }}
