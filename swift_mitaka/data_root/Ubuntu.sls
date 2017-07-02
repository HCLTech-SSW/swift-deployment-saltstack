packages:
  swift: swift
  swift-proxy: swift-proxy
  python-swiftclient: python-swiftclient
  python-keystoneclient: python-keystoneclient
  python-keystonemiddleware: python-keystonemiddleware
  memcached: memcached
  xfsprogs: xfsprogs
  rsync: rsync
  swift-account: swift-account
  swift-container: swift-container
  swift-object: swift-object

services:
  memcached: memcached
  swift_proxy: swift-proxy
  rsync: rsync

conf_files:
  proxy-server: "/etc/swift/proxy-server.conf"
  rsync: "/etc/rsyncd.conf"
  account-server: "/etc/swift/account-server.conf"
  container-server: "/etc/swift/container-server.conf"
  object-server: "/etc/swift/object-server.conf"
  swift: "/etc/swift/swift.conf"
  fstab: "/etc/fstab"
  rsync_default: "/etc/default/rsync"