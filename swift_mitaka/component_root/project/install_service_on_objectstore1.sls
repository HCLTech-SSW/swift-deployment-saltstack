{% from "initial/systemInfo/system_resources.jinja" import get_candidate with context %}
{% set filepath = "/etc/rsyncd.conf" %}
xfsprog_pkg_install:
  pkg:
    - installed
    - name: {{ salt['pillar.get']('packages:xfsprogs', default='xfsprogs') }}

rsync_pkg_install:
  pkg:
    - installed
    - name: {{ salt['pillar.get']('packages:rsync', default='rsync') }}
    - require:
        - pkg: xfsprog_pkg_install

format_xfs_cmd: 
  cmd:
    - run
    - name: 'mkfs.xfs -f "{{ pillar['objectstorage1_drive'] }}"'
    - require: 
        - pkg: xfsprog_pkg_install
        - pkg: rsync_pkg_install

create_mount_directory: 
  cmd: 
    - run
    - name: 'mkdir -p /srv/node/{{ pillar['objectstorage1_drive']|replace("/dev/","") }}'
    - require: 
        - cmd: format_xfs_cmd

update_fstab_conf_settings:
  file:
    - append
    - name: "{{ salt['pillar.get']('conf_files:fstab', default='/etc/fstab') }}"
    - text: {{ pillar['objectstorage1_drive'] }} /srv/node/{{ pillar['objectstorage1_drive']|replace("/dev/","") }} xfs noatime,nodiratime,nobarrier,logbufs=8 0 2
    - require:
        - cmd: create_mount_directory

node_mount_command:
  cmd:
    - run
    - name: 'mount /srv/node/{{ pillar['objectstorage1_drive']|replace("/dev/","") }}'
    - require: 
        - file: update_fstab_conf_settings

rsync_file_conf:
  file.managed:
    - name: {{ filepath }}
    - create: true
    - contents:
        - uid = swift
        - gid = swift
        - log file = /var/log/rsyncd.log
        - pid file = /var/run/rsyncd.pid
        - address = {{ grains.ip4_interfaces.eth0|replace('[','')|replace(']','')|replace("'"," ") }}
    - require:
        - cmd: node_mount_command

ini_create_if_missing:
  cmd.run:
    - name: "echo [general] > {{ filepath }}"
    - unless: "grep -q -e'[general]' {{ filepath }}"

ini:
  ini.options_present:
    - name: {{ filepath }}
    - sections:
        account:
          max connections: 2
          path: "/srv/node/"
          "read only": False
          "lock file": "/var/lock/account.lock"
        container:
          max connections: 2
          path: "/srv/node/"
          "read only": False
          "lock file": "/var/lock/container.lock"
        object:
          max connections: 2
          path: "/srv/node/"
          "read only": False
          "lock file": "/var/lock/object.lock"
    - require:
        - cmd: ini_create_if_missing

rsync_conf_update:
  file:
    - replace
    - name: "{{ salt['pillar.get']('conf_files:rsync_default', default='/etc/default/rsync') }}"
    - backup: False
    - pattern: 'RSYNC_ENABLE=false'
    - repl: 'RSYNC_ENABLE=true'
    - require: 
        - file: rsync_file_conf

rsync_service_reload:
  service: 
    - running
    - name: {{ salt['pillar.get']('services:rsync', default='rsync') }}
    - watch: 
        - file: rsync_file_conf
        - file: rsync_conf_update

swift_pkg_install:
  pkg:
    - installed
    - name: {{ salt['pillar.get']('packages:swift', default='swift') }}
    - require:
        - service: rsync_service_reload

swift_account_pkg_install:
  pkg:
    - installed
    - name: {{ salt['pillar.get']('packages:swift-account', default='swift-account') }}
    - require:
        - pkg: swift_pkg_install

swift_container_pkg_install:
  pkg:
    - installed
    - name: {{ salt['pillar.get']('packages:swift-container', default='swift-container') }}
    - require:
        - pkg: swift_account_pkg_install

swift_object_pkg_install:
  pkg:
    - installed
    - name: {{ salt['pillar.get']('packages:swift-object', default='swift-object') }}
    - require:
        - pkg: swift_container_pkg_install

obtain_account_server_conf:
  cmd: 
    - run
    - name: 'curl -o "{{ salt['pillar.get']('conf_files:account-server', default="/etc/swift/account-server.conf") }}" https://git.openstack.org/cgit/openstack/swift/plain/etc/account-server.conf-sample?h=stable/mitaka'
    - require: 
        - pkg: swift_object_pkg_install

obtain_container_server_conf:
  cmd: 
    - run
    - name: 'curl -o "{{ salt['pillar.get']('conf_files:container-server', default="/etc/swift/container-server.conf") }}" https://git.openstack.org/cgit/openstack/swift/plain/etc/container-server.conf-sample?h=stable/mitaka'
    - require: 
        - cmd: obtain_account_server_conf

obtain_object_server_conf:
  cmd: 
    - run
    - name: 'curl -o "{{ salt['pillar.get']('conf_files:object-server', default="/etc/swift/object-server.conf") }}" https://git.openstack.org/cgit/openstack/swift/plain/etc/object-server.conf-sample?h=stable/mitaka'
    - require: 
        - cmd: obtain_container_server_conf

account_server_conf:
  file:
    - managed
    - name: "{{ salt['pillar.get']('conf_files:account-server', default="/etc/swift/account-server.conf") }}"
    - mode: 644
    - user: swift
    - group: swift
    - require: 
        - cmd: obtain_object_server_conf
  ini: 
    - options_present
    - name: "{{ salt['pillar.get']('conf_files:account-server', default="/etc/swift/account-server.conf") }}"
    - sections: 
        DEFAULT: 
          bind_ip: {{ grains.ip4_interfaces.eth0|replace('[','')|replace(']','')|replace("'"," ") }}
          bind_port: "6002" 
          user: "swift"
          swift_dir: "/etc/swift"
          devices: "/srv/node"
          mount_check: True
        "pipeline:main": 
          pipeline: healthcheck recon account-server
        "filter:recon": 
          use: "egg:swift#recon"
          recon_cache_path : "/var/cache/swift"
    - require: 
        - file: account_server_conf

container_server_conf: 
  file: 
    - managed
    - name: "{{ salt['pillar.get']('conf_files:container-server', default="/etc/swift/container-server.conf") }}"
    - mode: 644
    - user: swift
    - group: swift
    - require:
        - file: account_server_conf
  ini: 
    - options_present
    - name: "{{ salt['pillar.get']('conf_files:container-server', default="/etc/swift/container-server.conf") }}"
    - sections: 
        DEFAULT: 
          bind_ip: {{ grains.ip4_interfaces.eth0|replace('[','')|replace(']','')|replace("'"," ") }}
          bind_port: "6001" 
          user: "swift"
          swift_dir: "/etc/swift"
          devices: "/srv/node"
          mount_check: True
        "pipeline:main": 
          pipeline: healthcheck recon container-server
        "filter:recon": 
          use: "egg:swift#recon"
          recon_cache_path : "/var/cache/swift"
    - require: 
        - file: container_server_conf

object_server_conf: 
  file: 
    - managed
    - name: "{{ salt['pillar.get']('conf_files:object-server', default="/etc/swift/object-server.conf") }}"
    - mode: 644
    - user: swift
    - group: swift
    - require: 
        - file: container_server_conf
  ini: 
    - options_present
    - name: "{{ salt['pillar.get']('conf_files:object-server', default="/etc/swift/object-server.conf") }}"
    - sections: 
        DEFAULT: 
          bind_ip: {{ grains.ip4_interfaces.eth0|replace('[','')|replace(']','')|replace("'"," ") }}
          bind_port: "6000" 
          user: "swift"
          swift_dir: "/etc/swift"
          devices: "/srv/node"
          mount_check: True
        "pipeline:main": 
          pipeline: healthcheck recon object-server
        "filter:recon": 
          use: "egg:swift#recon"
          recon_cache_path : "/var/cache/swift"
          recon_lock_path: "/var/lock"
    - require: 
        - file: object_server_conf

owernship_mount_directory:
  cmd: 
    - run
    - name: 'chown -R swift:swift /srv/node'
    - require: 
        - file: object_server_conf

create_recon_directory:
  cmd: 
    - run
    - name: 'mkdir -p /var/cache/swift'
    - require: 
        - cmd: owernship_mount_directory

owernship_recon_directory:
  cmd: 
    - run
    - name: 'chown -R root:swift /var/cache/swift'
    - require: 
        - cmd: create_recon_directory

recon_mode_directory:
  cmd: 
    - run
    - name: 'chmod -R 775 /var/cache/swift'
    - require: 
        - cmd: owernship_recon_directory
