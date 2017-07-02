{% from "initial/systemInfo/system_resources.jinja" import get_candidate with context %}
swift_pkg_install:
  pkg: 
    - installed
    - name: "{{ salt['pillar.get']('packages:swift', default='swift') }}"

swift_proxy_install:
  pkg: 
    - installed
    - name: "{{ salt['pillar.get']('packages:swift-proxy', default='swift-proxy') }}"
    - require: 
        - pkg: swift_pkg_install

python_swiftclient_install:
  pkg: 
    - installed
    - name: "{{ salt['pillar.get']('packages:python-swiftclient', default='python-swiftclient') }}"
    - require: 
        - pkg: swift_proxy_install

python_keystoneclient_install:
  pkg: 
    - installed
    - name: "{{ salt['pillar.get']('packages:python-keystoneclient', default='python-keystoneclient') }}"
    - require: 
        - pkg: python_swiftclient_install

python_keystonemiddleware_install:
  pkg: 
    - installed
    - name: "{{ salt['pillar.get']('packages:python-keystonemiddleware', default='python-keystonemiddleware') }}"
    - require: 
        - pkg: python_keystoneclient_install

memcached_install:
  pkg: 
    - installed
    - name: "{{ salt['pillar.get']('packages:memcached', default='memcached') }}"
    - require: 
        - pkg: python_keystonemiddleware_install

create_swift_directory: 
  cmd: 
    - run
    - name: 'mkdir -p /etc/swift'
    - require: 
        - pkg: swift_pkg_install
        - pkg: swift_proxy_install
        - pkg: memcached_install

obtain_proxy_server_conf:
  cmd: 
    - run
    - name: 'curl -o "{{ salt['pillar.get']('conf_files:proxy-server', default="/etc/swift/proxy-server.conf") }}" https://git.openstack.org/cgit/openstack/swift/plain/etc/proxy-server.conf-sample?h=stable/mitaka'
    - require: 
        - pkg: swift_pkg_install
        - pkg: swift_proxy_install
        - pkg: memcached_install
        - cmd: create_swift_directory

proxy_server_conf: 
  file: 
    - managed
    - name: "{{ salt['pillar.get']('conf_files:proxy-server', default="/etc/swift/proxy-server.conf") }}"
    - mode: 644
    - user: swift
    - group: swift
    - require: 
        - cmd: obtain_proxy_server_conf
  ini: 
    - options_present
    - name: "{{ salt['pillar.get']('conf_files:proxy-server', default="/etc/swift/proxy-server.conf") }}"
    - sections: 
        DEFAULT: 
          bind_port: "8080"
          user: "swift"
          swift_dir: "/etc/swift"
        "pipeline:main": 
          pipeline: catch_errors gatekeeper healthcheck proxy-logging cache container_sync bulk ratelimit authtoken keystoneauth container-quotas account-quotas slo dlo versioned_writes proxy-logging proxy-server
        "app:proxy-server": 
          use: "egg:swift#proxy"
          account_autocreate: True
        "filter:keystoneauth": 
          use: "egg:swift#keystoneauth"
          operator_roles: "admin,user"
        "filter:authtoken": 
          paste.filter_factory: "keystonemiddleware.auth_token:filter_factory"
          auth_uri: "http://{{ pillar['controller_cluster'] }}:5000"
          auth_url: "http://{{ pillar['controller_cluster'] }}:35357"
          memcache_servers: "{{ pillar['controller_cluster'] }}:11211"
          auth_type: "password"
          project_domain_name: "default"
          user_domain_name: "default"
          project_name: "service"
          username: swift
          password: "{{ pillar['swift']['services']['swift']['users']['swift']['password'] }}"
          delay_auth_decision: True
        "filter:cache": 
          use: "egg:swift#memcache"
          memcache_servers: "{{ pillar['controller_cluster'] }}:11211"
    - require: 
        - file: proxy_server_conf

obtain_swift_conf:
  cmd: 
    - run
    - name: 'curl -o "{{ salt['pillar.get']('conf_files:swift', default="/etc/swift/swift.conf") }}" https://git.openstack.org/cgit/openstack/swift/plain/etc/swift.conf-sample?h=stable/mitaka'
    - require: 
        - file: proxy_server_conf

swift_conf: 
  file: 
    - managed
    - name: "{{ salt['pillar.get']('conf_files:swift', default="/etc/swift/swift.conf") }}"
    - mode: 644
    - user: swift
    - group: swift
    - require: 
        - cmd: obtain_swift_conf
  ini: 
    - options_present
    - name: "{{ salt['pillar.get']('conf_files:swift', default="/etc/swift/swift.conf") }}"
    - sections: 
        "swift-hash": 
          swift_hash_path_suffix : {{ pillar['hash_path_suffix'] }}
          swift_hash_path_prefix : {{ pillar['hash_path_prefix'] }}
        "storage-policy:0": 
          name: "Policy-0"
          default: yes
    - require: 
        - file: swift_conf

swift_ownership_controller:
  cmd: 
    - run
    - name: 'chown -R root:swift /etc/swift'
    - require: 
        - file: swift_conf
