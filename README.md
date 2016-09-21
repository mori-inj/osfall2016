# Project 1

#### OS Fall 2016

##### DUE: 2016.10.5 Wednesday at 8:59pm KST

###### We strongly recommend you to use ubuntu 12.04 or 14.04 for all projects!!

The programming project is to be done in your group. The Git repository your entire group will use to submit the programming project should be set in Github. The name of repository will be set as the name of your team. (e.g. `osfall2016-team1`). This repository will be accessible to all members of your team, and all team members are expected to commit (local) and push (update the server) changes / contributions to the repository equally. You should become familiar with team-based shared repository Git commands such as [git-pull](http://www.kernel.org/pub/software/scm/git/docs/git-pull.html), [git-push](http://www.kernel.org/pub/software/scm/git/docs/git-push.html), [git-merge](http://www.kernel.org/pub/software/scm/git/docs/git-merge.html), [git-fetch](http://www.kernel.org/pub/software/scm/git/docs/git-fetch.html).

You should create a base branch named _proj1_ for Project 1\. All team members should make at least _five_ commits to the team's Git repository. The point is to make incremental changes and use an iterative development cycle. Your final codes and README file have to be committed into the _proj1_ branch for submission. 

Your README file should include:

1. How to build/run to test your code

2. High-level design and implemenation

3. Lessons learned

Follow the [Linux kernel coding style](http://www.kernel.org/doc/Documentation/CodingStyle) and check your commits with the [<font color="red">checkpatch.pl</font>](https://github.com/torvalds/linux/blob/master/scripts/checkpatch.pl) script. Errors from the script in your submission will cause a deduction of points.

The kernel programming for this assignment will be done using a Tizen-flashed TM1 device. Your Tizen device uses the ARM cpu family. Because the target CPU is (most likely) different from the CPU running in your personal computer, you will have to _cross-compile_ any software, including the linux kernel, to run on the different platform. We recommend using Ubuntu 12.04 LTS (64-bit), which we have tested all projects on. We do not guarantee that our guidelines work in other environments.



1.  **(5 pts.) Set your development environment and install a custom Tizen kernel on your Z3 device**
	1.  Download and Install Tizen SDK 2.4. 
	
		This SDK includes Smart Development Bridge (sdb) utility. We use the sdb in step 8 or problem 3 where you should push your built image or test program to your device/emulator. A brief description of sdb is in step 8.
		1. Download the installer from [this website](https://developer.tizen.org/development/tools/download)
		2. Before starting the installation, check the [Install guide](https://developer.tizen.org/development/tools/download/installing-sdk) and [prerequisite](https://developer.tizen.org/development/tools/download/installing-sdk/prerequisites).
		3. Execute the install manager and follow GUI instructions.

			```
			$ chmod +x ./tizen-sdk-<\version>-ubuntu-<\bits>.bin
			
			$ ./tizen-sdk-<\version>-ubuntu-<\bits>.bin
			```
		
		4.  When the installation is done, 'tizen-sdk' and 'tizen-sdk-data' folder will be created.
		
	2. Install lthor([Instruction for lthor](https://source.tizen.org/ko/documentation/reference/flash-device?langredirect=1)) & Download prerequisites.
		
		```
		$ sudo apt-get install ccache
		
		$ sudo apt-get install ia32-libs (for Ubuntu 12.04)
		
		or
		
		$ sudo apt-get install lib32z1 lib32ncurses5 lib32bz2-1.0 (for later than Ubuntu 12.04)
		```
		
	3.  Download the kernel source of Tizen kernel for the device.
	
		```
		$ git clone git://git.tizen.org/kernel/linux-3.10-sc7730.git
		```
	
	4. Change the branch to tizen_2.4.

		```
		$ cd linux-3.10-sc7730
		
		$ git checkout tizen_2.4
		```

	5. 32bits toolchain (Cross Compiler)
		1. Download 32bits ARM toolchain package
			- http://download.tizen.org/live/devel:/arm_toolchain:/Mobile:/toolchain/ia32-wayland/i686/tizen-toolchain-arm-0.1-4.23.i686.rpm
			
		2. Extract files from RPM package

			```		
			$ rpm2cpio tizen-toolchain-arm-0.1-4.23.i686.rpm | cpio -idmv
			```
		3. Export path of cross compiler

			```
			$ export PATH="$PATH:<extraction path>/opt/tizen-toolchain-4.9~git-i686_armv7l-tizen-linux-gnueabi-20151113/bin/"
			```

	6. dtbtool and mkdzimage binary
		1. Download system-tools package
			- http://download.tizen.org/releases/2.4/2.4-mobile/tizen-2.4-mobile_20151030.1/repos/emulator/packages/i586/system-tools-0.0.1-1.1.i586.rpm

		2. Extract files from RPM package and copy

			```
			$ rpm2cpio system-tools-0.0.1-1.1.i586.rpm | cpio -idmv
			
			$ cp -a usr/bin/* /usr/bin (Instead of /usr/bin, you can use any other directory in your $PATH environment variable.)
			```
	
	7. Download [build.sh](https://github.com/ossnu/osfall2016/blob/master/src/build.sh) and build the kernel
	
		```
		# build.sh should be in root of your kernel codes
		# (e.g., /home/os/linux-3.10-sc7730/build.sh)
		# Rebuild the kernel with build.sh whenever you modify the kernel source
		
		$ cd <your kernel path>
		$ ./build.sh tizen_tm1 USR
		
		# Build and make kernel module image (module.img) as well. (You can skip this after your first compilation)
		
		$ sudo ls
		$ export CROSS_COMPILE="<extraction path>/opt/tizen-toolchain-4.9~git-i686_armv7l-tizen-linux-gnueabi-20151113/bin/armv7l-tizen-linux-gnueabi-"
		$ scripts/mkmodimg.sh
		
		# Make a .tar archive from dzImage and modules.img
		
		$ tar cf IMAGE.tar -C arch/arm/boot dzImage -C ../../../usr/tmp-mod modules.img
		
		```

	8.  Connect the phone to the Linux PC with a USB cable.  
    **Note: For virtual machine users, make sure that the Tizen USB device connects to guest OS and your virtualization software supports USB 3.0 port connection. (VirtualBox recently starts to support it since version 5.x)**
    
	9. Flash your image
	
		As I mentioned step 8, you should make the device enter the download mode first.
		```
		Turn off the device and then push power + volume down + home button.
		```
		While the device is in download mode,
		```
		# Send the .tar image to the target using lthor
		
		$ sudo lthor IMAGE.tar
		```
		Then, the device will be rebooted and you can get the device with YOUR KERNEL!
		
	10. Copy the file to/from the device
		
		In order to push some files to your device, you will have to the Smart Development Bridge ([sdb](https://developer.tizen.org/community/tip-tech/smart-development-bridge)) utility. sdb is a command line tool that makes you able to easily manage your device/emulator through your development system (desktop or laptop). You may usually use it to check the connection with the device/emulator (`sdb devices`), push or pull files (`sdb push` or `sdb pull`), and get a shell of the device/emulator (`sdb shell`). For details, you can see [this link](https://developer.tizen.org/community/tip-tech/smart-development-bridge)
     	
		Some useful commands are below.
		
    	After connecting the Tizen device with USB, you can check your connection by issuing: 
		```
		$ sdb devices
		``` 
		If you see the TM1 listed there, your device is connected well.

    	To move a file to the emulator: 
		```
		$ sdb push /path/to/local/file /home/developer/
		``` 
		To execute, you can either enter a shell on the device, or call the program directly from sdb:
		```
		$ sdb shell  
    	tizen$ /home/developer/exe_name
		``` 
		or

		```
		$ sdb shell /home/developer/exe_name
		```   
    	To pull a file out of the emulator:
		```
		$ sdb pull /home/developer/file /local/path
		```
		
		
	
2.  **(45 pts.) Write a new system call in Linux**  
    The system call you write should take two arguments and return the process tree information in a depth-first-search (DFS) pre-ordering order. Note that you will be modifying the Tizen kernel source which you previously built, and cross-compiling it to run on your Tizen device using the techniques described in problem 1.  

    The prototype for your system call will be:  

	```
    int ptree(struct prinfo *buf, int *nr);
    ```

    You should define _struct prinfo_ as:

    ```
    struct prinfo {
		long state;			/* current state of process */
		pid_t pid;			/* process id */
		pid_t parent_pid;		/* process id of parent */
		pid_t first_child_pid;		/* pid of oldest child */
		pid_t next_sibling_pid;		/* pid of younger sibling */
		long uid;			/* user id of process owner */
		char comm[64];			/* name of program executed */
    };
    ```

    in `include/linux/prinfo.h` as part of your solution.   

    The argument `buf` points to a buffer for the process data, and `nr` points to the size of this buffer (number of entries). The system call copies at most that many entries of the process tree data to the buffer and stores the number of entries actually copied in `nr`.   

    If a value to be set in `prinfo` is accessible through a pointer which is null, set the value in `prinfo` to 0\. For example, the `first_child_pid` should be set to 0 if the process does not have a child.   

    Your system call should return the total number of entries on success (this may be bigger than the actual number of entries copied). Your code should handle errors that can occur but not handle any errors that cannot occur. At a minimum, your system call should detect and report the following error conditions:
    *   `-EINVAL`: if `buf` or `nr` are null, or if the number of entries is less than 1
    *   `-EFAULT`: if `buf` or `nr` are outside the accessible address space.  
    The referenced error codes are defined in include/uapi/asm-generic/errno-base.h

    Each system call must be assigned a number. Your system call should be assigned number **384** (this is a magic number; you should change it appropriately).   

    **NOTE:** Linux maintains a list of all processes in a doubly linked list. Each entry in this list is a `task_struct` structure, which is defined in include/linux/sched.h. When traversing the process tree data structures, it is necessary to prevent the data structures from changing in order to ensure consistency. For this purpose the kernel relies on a special lock, the `tasklist_lock`. You should grab this lock before you begin the traversal, and only release the lock when the traversal is completed. While holding the lock, your code may not perform any operations that may result in a sleep, such as memory allocation, copying of data into and out from the kernel etc. Use the following code to grab and then release the lock:

    ```
	read_lock(&tasklist_lock);
    ...
    ...
    read_unlock(&tasklist_lock);
	```

     **HINT**: In order to learn about system calls, you may find it helpful to search the linux kernel for other system calls and see how they are defined. You can use the Linux Cross-Reference (LXR) to investigate different system calls already defined. The files kernel/sched.c and kernel/timer.c should provide good reference points for defining your system call.
     
3.  **(10 pts.) Test your new system call**

	Write a simple C program which calls `ptree`. Your program should print the entire process tree (in DFS pre-ordering order) using tabs to indent children with respect to their parents. For each process, it should use the following format for program output:
	```
	printf(/* correct number of \t */);
	printf("%s,%d,%ld,%d,%d,%d,%d\n", p.comm, p.pid, p.state,
	p.parent_pid, p.first_child_pid, p.next_sibling_pid, p.uid);
	```
	Example program output:
	```
	systemd,1,1,0,156,2,0
		systemd-journal,156,1,1,0,185,0
		systemd-udevd,185,1,1,0,484,0
		syslogd,484,1,1,0,495,0
    	...
    	deviced,802,1,1,1612,857,0
			systemctl,1612,64,802,0,1613,0
			systemctl,1613,64,802,0,1614,0
			systemctl,1614,64,802,0,31175,0
	 		...
	kthreadd,2,1,0,3,0,0
		ksoftirqd/0,3,1,2,0,5,0
		kworker/0:0H,5,1,2,0,6,0
		kworker/u8:0,6,1,2,0,7,0
	```
	**Compiling a test program for Tizen.**
	
	To compile a test program, you can use the following minimal Makefile:
	```
	INCLUDE=-I<your kernel path>/include
	GCCROOT=<your toolchain path>/tizen-toolchain-4.9~git-i686_armv7l-tizen-linux-gnueabi-20151113/bin
	CFLAGS=$(INCLUDE)
	CC=$(GCCROOT)/armv7l-tizen-linux-gnueabi-gcc
	
	all: test
	
	test: test.c
		@echo [Arm-cc] $<...
		@$(CC) $(CFLAGS) $< -o $@
	
	clean:
		@rm test
	```
	
	**Installing / Running on the Tizen device:**
	You already have learned about sdb in 1.8. Push the program with sdb and run it.
	```
	# We recommend you to use "/home/developer" directory.
	$ sdb push test_program /home/developer/
	
	# and run
	$ sdb shell /home/developer/test_program
	# or in the device shell
	$ sdb shell
	tizen$ /home/developer/test_program
	```
	
4. **(10 pts.) Investigate the Tizen process tree**
	1.  Run your test program several times. Which fields in the `prinfo` structure change? Which ones do not? Discuss why different fields might change with different frequency.
	
	2.  Start the mobile camera (or any other apps are fine) in the emulator, and re-run your test program. How many processes are started? What is/are the parent process(es) of the new process(es)? Close the browser (press the "Home" button). How many processes were destroyed? Discuss your findings.
	
		**NOTE**: Before this step or 4.3, you should check that the application does not run even in background. You can check it and force quit the app by pressing "Home" button for couple of seconds
		
	3. In 4.2, you may notice that there are _launchpad_ and _launchpad-loader_. Investigate these processes.
		1. Focusing on pids of _launchpad_, _launchpad-loader_, and applications, try 4.2 again. Explain changes of the process names or pids.		
		2. Explain what _launchpad_ and _launchpad-loader_ do. And Discuss the reason Tizen use them.
