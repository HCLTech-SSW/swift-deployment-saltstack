{% from "initial/systemInfo/system_resources.jinja" import get_candidate with context %}
create_account_distribution_ring: 
  cmd: 
    - run
    - name: 'cd /etc/swift && swift-ring-builder account.builder create 10 3 1 && swift-ring-builder account.builder add --region 1 --zone 1 --ip {{ pillar['hosts']['objectstorage1.mitaka'] }} --port 6002 --device {{ pillar['objectstorage1_drive']|replace("/dev/","") }} --weight 100 && swift-ring-builder account.builder add --region 1 --zone 1 --ip {{ pillar['hosts']['objectstorage2.mitaka'] }} --port 6002 --device {{ pillar['objectstorage2_drive']|replace("/dev/","") }} --weight 100 && swift-ring-builder account.builder add --region 1 --zone 1 --ip {{ pillar['hosts']['objectstorage3.mitaka'] }} --port 6002 --device {{ pillar['objectstorage3_drive']|replace("/dev/","") }} --weight 100 && swift-ring-builder account.builder && swift-ring-builder account.builder rebalance'

create_container_distribution_ring: 
  cmd:
    - run
    - name: 'cd /etc/swift && swift-ring-builder container.builder create 10 3 1 && swift-ring-builder container.builder add --region 1 --zone 1 --ip {{ pillar['hosts']['objectstorage1.mitaka'] }} --port 6001 --device {{ pillar['objectstorage1_drive']|replace("/dev/","") }} --weight 100 && swift-ring-builder container.builder add --region 1 --zone 1 --ip {{ pillar['hosts']['objectstorage2.mitaka'] }} --port 6001 --device {{ pillar['objectstorage2_drive']|replace("/dev/","") }} --weight 100 && swift-ring-builder container.builder add --region 1 --zone 1 --ip {{ pillar['hosts']['objectstorage3.mitaka'] }} --port 6001 --device {{ pillar['objectstorage3_drive']|replace("/dev/","") }} --weight 100 && swift-ring-builder container.builder && swift-ring-builder container.builder rebalance'
    - require: 
        - cmd: create_account_distribution_ring

create_object_distribution_ring: 
  cmd: 
    - run
    - name: 'cd /etc/swift && swift-ring-builder object.builder create 10 3 1 && swift-ring-builder object.builder add --region 1 --zone 1 --ip {{ pillar['hosts']['objectstorage1.mitaka'] }} --port 6000 --device {{ pillar['objectstorage1_drive']|replace("/dev/","") }} --weight 100 && swift-ring-builder object.builder add --region 1 --zone 1 --ip {{ pillar['hosts']['objectstorage2.mitaka'] }} --port 6000 --device {{ pillar['objectstorage2_drive']|replace("/dev/","") }} --weight 100 && swift-ring-builder object.builder add --region 1 --zone 1 --ip {{ pillar['hosts']['objectstorage3.mitaka'] }} --port 6000 --device {{ pillar['objectstorage3_drive']|replace("/dev/","") }} --weight 100 && swift-ring-builder object.builder && swift-ring-builder object.builder rebalance'
    - require: 
        - cmd: create_container_distribution_ring
