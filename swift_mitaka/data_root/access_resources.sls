common_keys: 
  admin_token: "24811ee3d9a09915bef0"
  endpoint_host_sls: "controller.mitaka"
  os_identity_version: "3"
  domain: "default"
  os_url: "http://{0}:35357/v3"
  os_username: "admin"
  os_password: "Admin_pass"
  os_image_version: "2"

swift:
  services:
    swift:
      service_type: "object-store"
      endpoint:
        adminurl: "http://{0}:8080/v1"
        internalurl: "http://{0}:8080/v1/AUTH_%\\(tenant_id\\)s"
        publicurl: "http://{0}:8080/v1/AUTH_%\\(tenant_id\\)s"
        region: "RegionOne"
      description: "OpenStack Object Storage"
      users: 
        swift:
          password: "Swift_pass"
          role: "admin"