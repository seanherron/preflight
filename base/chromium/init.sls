chromium.install:
  pkg.latest:
    - name: chromium

chromium.widevine.install:
  git.latest:
    - name: https://aur.archlinux.org/chromium-widevine.git
    - target: {{ pillar['preflight_dir'] }}/builds/chromium-widevine
    - user: {{ pillar['username'] }}

  cmd.wait:
    - name: makepkg -si
    - cwd: {{ pillar['preflight_dir'] }}/builds/chromium-widevine
    - watch:
      - git: chromium.widevine.install
    - runas: {{ pillar['username'] }}
