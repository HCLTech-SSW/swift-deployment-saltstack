#!/bin/bash
if [ $# -eq 4 ]; then
    echo 'Ring distribution execution is started.'
    echo ''
    echo 'Copying account.ring.gz, container.ring.gz, object.ring.gz and swift.conf files from openstack controller node to salt master node.'
    salt $1 cp.push /etc/swift/account.ring.gz
    salt $1 cp.push /etc/swift/container.ring.gz
    salt $1 cp.push /etc/swift/object.ring.gz
    salt $1 cp.push /etc/swift/swift.conf
    echo ''
    echo 'Distribution of account.ring.gz, container.ring.gz, object.ring.gz and swift.conf files from salt master node to object storage node1.'
    salt-cp $2 /var/cache/salt/master/minions/controller.mitaka/files/etc/swift/account.ring.gz /etc/swift/
    salt-cp $2 /var/cache/salt/master/minions/controller.mitaka/files/etc/swift/container.ring.gz /etc/swift/
    salt-cp $2 /var/cache/salt/master/minions/controller.mitaka/files/etc/swift/object.ring.gz /etc/swift/
    salt-cp $2 /var/cache/salt/master/minions/controller.mitaka/files/etc/swift/swift.conf /etc/swift/
    echo ''
    echo 'Distribution of account.ring.gz, container.ring.gz, object.ring.gz and swift.conf files from salt master node to object storage node2.'
    salt-cp $3 /var/cache/salt/master/minions/controller.mitaka/files/etc/swift/account.ring.gz /etc/swift/
    salt-cp $3 /var/cache/salt/master/minions/controller.mitaka/files/etc/swift/container.ring.gz /etc/swift/
    salt-cp $3 /var/cache/salt/master/minions/controller.mitaka/files/etc/swift/object.ring.gz /etc/swift/
    salt-cp $3 /var/cache/salt/master/minions/controller.mitaka/files/etc/swift/swift.conf /etc/swift/
    echo ''
    echo 'Distribution of account.ring.gz, container.ring.gz, object.ring.gz and swift.conf files from salt master node to object storage node3.'
    salt-cp $4 /var/cache/salt/master/minions/controller.mitaka/files/etc/swift/account.ring.gz /etc/swift/
    salt-cp $4 /var/cache/salt/master/minions/controller.mitaka/files/etc/swift/container.ring.gz /etc/swift/
    salt-cp $4 /var/cache/salt/master/minions/controller.mitaka/files/etc/swift/object.ring.gz /etc/swift/
    salt-cp $4 /var/cache/salt/master/minions/controller.mitaka/files/etc/swift/swift.conf /etc/swift/
    echo ''
	echo 'Final commands to be executed on openstack controller node and object storage nodes to grant Swift ownership and start the Swift services.'
    salt $1 cmd.run 'chown -R root:swift /etc/swift && service memcached restart && service swift-proxy restart'
    salt $2 cmd.run 'chown -R swift:swift /srv/node && chown -R root:swift /var/cache/swift && chmod -R 775 /var/cache/swift && chown -R root:swift /etc/swift && service rsync restart && swift-init all start'
    salt $3 cmd.run 'chown -R swift:swift /srv/node && chown -R root:swift /var/cache/swift && chmod -R 775 /var/cache/swift && chown -R root:swift /etc/swift && service rsync restart && swift-init all start'
    salt $4 cmd.run 'chown -R swift:swift /srv/node && chown -R root:swift /var/cache/swift && chmod -R 775 /var/cache/swift && chown -R root:swift /etc/swift && service rsync restart && swift-init all start'
    echo ''
    echo 'Ring distribution execution is completed.'
elif [[ $1 == "-help" ]]; then
    echo  "usage: ./ring_distribution.sh <name-of-controller-minion> <name-of-objectstoragenode1-minion> <name-of-objectstoragenode2-minion> <name-of-objectstoragenode3-minion>"
else
    echo "The arguments supplied are either 0 or greater than the expected arguments.
Please specify arguments as:

	<agr1>: Name of the controller node minion.
	<agr2>: Name of the objectstorage node 1 minion.
	<arg3>: Name of the objectstorage node 2 minion.
	<arg4>: Name of the objectstorage node 3 minion.
	
For help type: ./ring_distribution.sh --help"
fi
