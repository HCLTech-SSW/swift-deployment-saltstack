#Uncomment below line if there is a valid package proxy
#pkg_proxy_url: "http://mars:3142"
#Data to identify cluster
cluster_type: mitaka

#Name of Openstack controller cluster
#The grains id of openstack controller cluster be added on the below variable.        
controller_cluster: "controller.mitaka"

#Name of the Physical drive for objectstorage.
objectstorage1_drive: "/dev/sdb"
objectstorage2_drive: "/dev/sdb"
objectstorage3_drive: "/dev/sdb"

#Swift Secured Hash Path Suffix and Predfix.
hash_path_suffix: "12345"
hash_path_prefix: "12346"

#Hosts and their ip addresses
#The order below should be followed by adding openstack controller cluster, compute cluster and then 
#other remaining clusters. Add the grains id here (i.e. name of minion registered as grains on minion by using 
#the command echo 'controller.mitaka' > /etc/salt/minion_id)
#The grains id of openstack controller cluster should also be added on the variable "" in access_resources.sls.        
hosts: 
  controller.mitaka: 10.112.118.150
  compute.mitaka: 10.112.118.141
  objectstorage1.mitaka: 10.112.118.148
  objectstorage2.mitaka: 10.112.118.152
  objectstorage3.mitaka: 10.112.118.153

