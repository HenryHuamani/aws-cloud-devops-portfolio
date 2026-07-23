# User Data Script

The EC2 instances were configured using a reusable User Data script.

Location:

```text
scripts/userdata.sh
```

Before launching each EC2 instance, the following variables were updated according to the target Availability Zone:

```bash
SERVER_NAME="Server 01"
AVAILABILITY_ZONE="us-east-2a"
```

or

```bash
SERVER_NAME="Server 02"
AVAILABILITY_ZONE="us-east-2b"
```

The remainder of the script remains identical for both instances, following the DRY (Don't Repeat Yourself) principle.