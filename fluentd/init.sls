{% set settings = salt['pillar.get']('fluentd:lookup:settings', {}) %}

sources_list_fluentd:
  pkgrepo.managed:
    - humanname: fluentd packages
    - name: deb http://packages.treasuredata.com/2/debian/{{ settings.get('dist', 'jessie') }}/ {{ settings.get('dist', 'jessie') }} contrib
    - file: /etc/apt/sources.list.d/fluentd.list
    - key_url: https://packages.treasuredata.com/GPG-KEY-td-agent
    - require_in:
      - pkg: fluentd_package

fluentd_package:
  pkg.installed:
    - pkgs:
      - td-agent

fluentd_systemd:
  cmd.run: 
    - name: td-agent-gem install fluent-plugin-systemd 
    - require:
      - pkg: fluentd_package

fluentd_elasticsearch:
  cmd.run: 
    - name: td-agent-gem install fluent-plugin-elasticsearch
    - require:
      - pkg: fluentd_package

fluentd_service:
  service.running:
    - name: docker
    - enable: True
    - require:
      - pkg: fluentd_package
      - cmd: fluentd_systemd
    - watch:
      - pkg: fluentd_package
      - cmd: fluentd_systemd
