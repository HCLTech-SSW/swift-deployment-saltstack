roles: 
  - "controller"
  - "objectstorage1"
  - "objectstorage2"
  - "objectstorage3"
controller: 
  - "controller.mitaka"
objectstorage1:
  - "objectstorage1.mitaka"
objectstorage3:
  - "objectstorage3.mitaka"
sls:
  controller:
    - "project.install_service"
    - "project.create_services"
    - "project.create_users"
    - "project.ring_cluster"
  objectstorage1:
    - "project.update_repo"
    - "project.install_service_on_objectstore1"
  objectstorage2:
    - "project.update_repo"
    - "project.install_service_on_objectstore2"
  objectstorage3:
    - "project.update_repo"
    - "project.install_service_on_objectstore3"