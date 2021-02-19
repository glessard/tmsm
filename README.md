# tmsm
Time Machine Snapshot Mounter

This macOS command-line tool creates an APFS snapshot, mounts it, then runs a subcommand passed as a parameter.
The mountpoint of the snapshot will be an environment variable for the launched subcommand.
After the subcommand returns, the snapshot is unmounted and destroyed.

`tmsm` needs to run in a context that has full disk access.
This may mean giving it full disk access, or launching it from a shell that has full disk access.
If `tmsm` does not have full disk access, then it will return with error code 77 (no permission), and the standard error will receive a message from `mount_apfs`.
Note that the subcommand launched by `tmsm` will effectively have full disk access; be careful if this is a concern.
