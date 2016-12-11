{% set aur_pkgs = [
  'lastpass',
  'slack-desktop'
] %}

{% for pkg in aur_pkgs %}
{{ pkg }}.install:
  git.latest:
    - name: https://aur.archlinux.org/{{ pkg }}.git
    - target: {{ pillar['preflight_dir'] }}/builds/{{ pkg }}
    - user: {{ pillar['username'] }}

  cmd.wait:
    - name: makepkg -si
    - cwd: {{ pillar['preflight_dir'] }}/builds/{{ pkg }}
    - watch:
      - git: {{ pkg }}.install
    - runas: {{ pillar['username'] }}
{% endfor %}
