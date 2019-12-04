
### Instructions

Stop the VM, resize the OS disk, start the VM and repartition the disk after resizing:


SHORT WAY
```
$ fdisk /dev/sda <<EOF
u
p
d
2
n
p
2


a
1

w
EOF
$ reboot

[...]

$ xfs_growfs -d /dev/sda2
```

LONG WAY
```
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda2        30G  1.2G   29G   5% /
devtmpfs         28G     0   28G   0% /dev
tmpfs            28G     0   28G   0% /dev/shm
tmpfs            28G  9.0M   28G   1% /run
tmpfs            28G     0   28G   0% /sys/fs/cgroup
/dev/sda1       497M   81M  417M  17% /boot
/dev/sdb1       111G   61M  105G   1% /mnt/resource
tmpfs           5.6G     0  5.6G   0% /run/user/1000
$
$ fdisk /dev/sda

Command (m for help): u
Changing display/entry units to cylinders (DEPRECATED!).

Command (m for help): p

Disk /dev/sda: 107.4 GB, 107374182400 bytes, 209715200 sectors
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disk label type: dos
Disk identifier: 0x000ecbd2

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *           1          64      512000   83  Linux
/dev/sda2              64        3917    30944256   83  Linux

Command (m for help): d
Partition number (1,2, default 2):
Partition 2 is deleted

Command (m for help): n
Partition type:
   p   primary (1 primary, 0 extended, 3 free)
   e   extended
Select (default p): p
Partition number (2-4, default 2):
First cylinder (64-13054, default 64):
Using default value 64
Last cylinder, +cylinders or +size{K,M,G} (64-13054, default 13054):
Using default value 13054
Partition 2 of type Linux and of size 99.5 GiB is set

Command (m for help): a
Partition number (1,2, default 2): 1

Command (m for help): p

Disk /dev/sda: 107.4 GB, 107374182400 bytes, 209715200 sectors
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disk label type: dos
Disk identifier: 0x000ecbd2

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1               1          64      512000   83  Linux
/dev/sda2              64       13054   104343231   83  Linux

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.

WARNING: Re-reading the partition table failed with error 16: Device or resource busy.
The kernel still uses the old table. The new table will be used at
the next reboot or after you run partprobe(8) or kpartx(8)
Syncing disks.
$ reboot

[...]

$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda2        30G  1.2G   29G   5% /
devtmpfs         28G     0   28G   0% /dev
tmpfs            28G     0   28G   0% /dev/shm
tmpfs            28G  9.0M   28G   1% /run
tmpfs            28G     0   28G   0% /sys/fs/cgroup
/dev/sda1       497M   81M  417M  17% /boot
/dev/sdb1       111G   61M  105G   1% /mnt/resource
tmpfs           5.6G     0  5.6G   0% /run/user/1000
$ xfs_growfs -d /dev/sda2
meta-data=/dev/sda2              isize=512    agcount=4, agsize=1934016 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0 spinodes=0
data     =                       bsize=4096   blocks=7736064, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=3777, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 7736064 to 26085807
$
$
$
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda2       100G  1.2G   99G   2% /
devtmpfs         28G     0   28G   0% /dev
tmpfs            28G     0   28G   0% /dev/shm
tmpfs            28G  9.0M   28G   1% /run
tmpfs            28G     0   28G   0% /sys/fs/cgroup
/dev/sda1       497M   81M  417M  17% /boot
/dev/sdb1       111G   61M  105G   1% /mnt/resource
tmpfs           5.6G     0  5.6G   0% /run/user/1000
```

### Reference

https://blogs.msdn.microsoft.com/cloud_solution_architect/2016/05/24/step-by-step-how-to-resize-a-linux-vm-os-disk-in-azure-arm/
