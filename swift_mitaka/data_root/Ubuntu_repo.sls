pkgrepo:
  pre_repo_additions:
    - "software-properties-common"
    - "ubuntu-cloud-keyring"
  repos:
    mitaka-Cloud:
      name: "deb http://ubuntu-cloud.archive.canonical.com/ubuntu trusty-updates/mitaka main"
      file: "/etc/apt/sources.list.d/cloudarchive-mitaka.list"
