---
Title: swift-deployment-saltstack
Description: This project is owned by HCL Tech System Software team to support the automated installation of OpenStack Object Storage (Swift using SaltStack).
Owner of the Project: HCL Tech System Software Team
Contributor: HCL Tech System Software Team
Mail To: hcl_ss_oss@hcl.com
Tags: Automation of OpenStack Swift, OpenStack Swift automation using SaltStack, HCL in OpenStack Swift automation, Installation support for OpenStack Swift, Automation of Object storage Swift
Created:  2017 Jul 02
Modified: 2017 Jul 02
---

swift-deployment-saltstack
==========================

Overview of the Project
=======================
This open source project is to support the automated installation of OpenStack Object Storage(Swift) for Mitaka release using SaltStack. This project is an extension of openstack-automation-saltstack.

Pre-requisites
==============
Before using/execution of this project, it is required to have a pre-configured OpenStack Mitaka Environment with following mandatory services as Keystone, Glance, Neutron, Nova and Horizon.

This environment can be setup either using "openstack-automation-saltstack" project from (https://github.com/HCLTech-SSW/openstack-automation-saltstack) or manually by referring the OpenStack installation guide.

OpenStack Object Storage Components which are installed and configured
======================================================================
This project will setup the OpenStack Swift in five node architecture environment by installing and configuring the following components:
<pre>
On Controller node:
1)  Modification of hosts file with the new entries of Object Storage Nodes.
2)  Installation and configuration of object storage service (i.e. Swift).

On Compute node:
1)  Modification of hosts file with the new entries of Object Storage Nodes.

On Object storage node 1:
1)  Mounting of a virtual/physical drive as a XFS file system.
2)  Installation and configuration of object storage service (i.e. Swift).

On Object storage node 2:
1)  Mounting of a virtual/physical drive as a XFS file system.
2)  Installation and configuration of object storage service (i.e. Swift).

On Object storage node 3:
1)  Mounting of a virtual/physical drive as a XFS file system.
2)  Installation and configuration of object storage service (i.e. Swift).
</pre>

Environment / Hardware requirement 
==================================

In order to install OpenStack Object Storage, the following environment / hardware requirement should be met:
<pre>
1)	Six Physical / Virtual machines having Ubuntu 14.04 LTS x86-64 operating system installed.

	a)	Salt-Master Machine: This is the First Machine (i.e. Machine-1) which will be used as Salt-Master machine and will invoke / perform the installation of OpenStack Object Storage on the other 5 machines (listed in next step).
	b)	Salt-Minion Machine(s) - The other five machines (i.e. Machine-2, 3, 4, 5 and 6) will be used as Salt-Minion machine on which OpenStack Object Storage would be configured using this project.
        
	* Two Salt-Minion machines are the machines which is pre-configured as OpenStack Controller Node and OpenStack Compute Node either by using https://github.com/HCLTech-SSW/openstack-automation-saltstack or manually by referring the OpenStack installation guide.  

2)	In order to allow download of the packages in OpenStack Object Storage installation, internet access should be available on all the machines.

3)	For smooth installation, minimum 4 GB of RAM is preferable.
</pre>

Steps to Configure this Project 
===============================
The following steps will be required by end users to their workstations to configure/use this project:

1) Configure the Machine-1 (Salt-Master machine) and which is responsible to invoke the installation of OpenStack Object Storage on other five machines (Salt-Minion machines), follow the steps as mentioned below:
<pre>
a)	Install the version 2016.3.6 of salt-master.

	•	Run the following command to import the SaltStack repository key:
		wget -O - https://repo.saltstack.com/apt/ubuntu/14.04/amd64/2016.3/SALTSTACK-GPG-KEY.pub | sudo apt-key add -

	•	Save the following line 
		deb http://repo.saltstack.com/apt/ubuntu/14.04/amd64/2016.3 trusty main
		to /etc/apt/sources.list.d/saltstack.list

	•	Run the following command:
		sudo apt-get update

	•	Run the following command to install salt-master
      	        sudo apt-get install salt-master

b)	Clone the project from git to local machine.

c)	Update the salt-master configuration file in Salt-Master machine located at "/etc/salt/master" which would hold the below contents:

	file_recv: True
	pillar_roots:
	  mitaka:
	    - /swift_mitaka/data_root
	file_roots:
	  mitaka:
	    - /swift_mitaka/component_root
</pre>
2) Configure the Salt-Minion machines on which the OpenStack Object Storage would be installed, follow the steps as mentioned below:
<pre>
a)	Install the version 2016.3.6 of salt-minion on all five Machines/Nodes.

	•	Run the following command to import the SaltStack repository key:
		wget -O - https://repo.saltstack.com/apt/ubuntu/14.04/amd64/2016.3/SALTSTACK-GPG-KEY.pub | sudo apt-key add -

	•	Save the following line 
		deb http://repo.saltstack.com/apt/ubuntu/14.04/amd64/2016.3 trusty main
		to /etc/apt/sources.list.d/saltstack.list
		
	•	Run the following command:
		sudo apt-get update

	•	Run the following command to install salt-minion
      	        sudo apt-get install salt-minion

b)	On every Salt-Minion machine, update the “/etc/hosts” file on every minion by adding the IP address of Salt-Master machine.

c)	On every Salt-Minion machine, update the “/etc/salt/minion” file with the IP address of Salt-Master machine against “master:” field.
</pre>
3) In order to start salt-master, execute the following command in terminal on Salt-Master machine 
<pre>
salt-master –l debug
</pre>

4) Update the name of all five new Salt-Minion machines by executing the following commands on respective Salt-Minion machine:
<pre>
a)	On Salt-Minion machine for Controller Node1:
	echo “controller.mitaka” > /etc/salt/minion_id

b)	On Salt-Minion machine for Compute Node2:
	echo “compute.mitaka” > /etc/salt/minion_id

c)	On Salt-Minion machine for Object Storage Node3:
	echo “objectstorage1.mitaka” > /etc/salt/minion_id
	
d)	On Salt-Minion machine for Object Storage Node4:
	echo “objectstorage2.mitaka” > /etc/salt/minion_id

e)	On Salt-Minion machine for Object Storage Node5:
	echo “objectstorage3.mitaka” > /etc/salt/minion_id

f)	For each Salt-Minion machine (OpenStack nodes), the same name should be updated into the “/etc/hostname”.

g)	Reboot all five new Salt-Minion machines.
</pre>
### Please note:
The names like “controller.mitaka”, “compute.mitaka”, "objectstorage1.mitaka”, "objectstorage2.mitaka” and "objectstorage3.mitaka” as mentioned above could be anything as per the user(s) choice, as we have considered the above mentioned name to easily visualize/identify the OpenStack nodes.

5) In order to start salt-minion, execute the following command in terminal on each Salt-Minion machine (OpenStack nodes):
<pre>
salt-minion –l debug
</pre>

6) Every Salt-Minion machine should be registered on Salt-Master machine, in order to register the minion, execute the following command on Salt-Master machine:
<pre>
salt-key –a “controller.mitaka”
salt-key –a “compute.mitaka”
salt-key –a “objectstorage1.mitaka”
salt-key –a “objectstorage2.mitaka”
salt-key –a “objectstorage3.mitaka”
</pre>

7) In order to verify the status of Salt-Minion machine registration with master, execute the following command on Salt-Master machine:
<pre>
salt ‘*.mitaka’ test.ping (which displays all 5 Salt-Minion will be shown in green color.)
</pre>

8) Updated the file “data_root/cluster.sls” located in Salt-Master machine. The fields which are highlighted in the below image should be provided by the user:

![Image1](https://github.com/hcltech-ssw/swift-deployment-saltstack/raw/mitaka/images/image1.png)

9) Verify the following values in “data_root/cluster_resources.sls” the file is located in Salt-Master machine.

![Image2](https://github.com/hcltech-ssw/swift-deployment-saltstack/raw/mitaka/images/image2.png)

10) The following file as displayed in below image contains the value for the parameters which would be specified while executing the commands for every service to create users, services and endpoints etc. Before proceeding to the installation, please review and update the values as per your preferences, the file “data_root/access_resources.sls” located in Salt-Master machine.

![Image3](https://github.com/hcltech-ssw/swift-deployment-saltstack/raw/mitaka/images/image3.png)

Now Let’s Start the OpenStack Swift Installation 
================================================
We are done with configuring salt-master and salt-minion machines, now let’s start the OpenStack Object storage installation. 
In order to start the installation, execute the following command from terminal on Salt-Master machine:
<pre>
salt ‘*.mitaka’ state.highstate
</pre>

### After execution of the above command, the following additional command required to be executed on Salt-Master Machine1:
<pre>
a) 	Change to swift_mitaka directory
	
	cd /swift_mitaka
		
b) 	Change the ownership of ring_distribution.sh file
	
	chmod a+x ring_distribution.sh
		
c)	Execute the ring_distribution.sh file by passing the first argument as name of Salt-Minion for controller node (i.e. 		controller.mitaka), second argument as name of Salt-Minion for objectstorage node1 (i.e. objectstorage1.mitaka), third 		argument as name of Salt-Minion for objectstorage node2 (i.e. objectstorage2.mitaka) and fourth argument as name of 		Salt-Minion for objectstorage node3 (i.e. objectstorage3.mitaka).
	
	./ring_distribution.sh [controller.mitaka] [objectstorage1.mitaka] [objectstorage2.mitaka] [objectstorage3.mitaka]
</pre>

After successful installation, all five Salt-Minion machines has been configured with OpenStack Object Storage (Swift) with the following components installed: 

<pre>
On Salt-Minion for Controller node: 
1)	Installation and configuration of object storage service (i.e. Swift)

On Salt-Minion for Object Storage node:
1)	Installation and configuration of object storage service (i.e. Swift)

Additionally, the installation would make the following common changes on all the three OpenStack nodes:
1)	Update the host file. (On Controller, Compute and Object Storage machines).
</pre>

Version Information
===================
This project is based and tested on the following versions:

1. SaltStack Master and Minion version 2016.3.6 (Boron)
2. OpenStack Swift Mitaka Release
3. Ubuntu 14.04 LTS x86-64 operating system

References
==========
<pre>
1. https://docs.openstack.org/mitaka/install-guide-ubuntu/swift.html
2. https://saltstack.com/
</pre>
