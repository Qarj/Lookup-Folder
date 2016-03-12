# LookupFolder 0.06
Search a Windows network folder for files containing multiple strings.

The search strings are assumed to be URL encoded. There is an option to indicate
that the files are encoded as quoted printable and should be decoded.

This script is designed to be as fast as possible over WAN network shares.

Be sure to put final \ if you are referring to folder rather than a file.
That is to say `C:\Windows\` and not `C:\Windows`. 

WARNING - Dates returned by Windows DIR command are assumed to be in European date format.

### Example 1
```
LookupFolder.pl --search print --search user1 --folder .\

Search base path  : .\
Search target for : print
Search target for : user1
Max file age mins : none
Flags             :

Built file list in 0.005 seconds

[1] (age: 14.2 mins) critic.txt
    print ...  not found

[2] (age: 24.2 mins) cust1.eml
    print ...  not found

[3] (age: 184.2 mins) cust.eml
    print ...  not found

[4] (age: 1221.2 mins) 180_qponly.eml
    print ...  not found

[5] (age: 1224.2 mins) 180.eml
    print ...  FOUND
    user1 ...  not found

[6] (age: 4093.2 mins) LICENSE
    print ...  FOUND
    user1 ...  not found

[7] (age: 4093.2 mins) CHANGES.md
    print ...  FOUND
    user1 ...  not found

[8] (age: 4093.2 mins) LookupFolder.pl
    print ...  FOUND
    user1 ...  FOUND
    Success 'LookupFolder.pl' contains all search criteria!

[9] (age: 4093.2 mins) README.md
    print ...  FOUND
    user1 ...  FOUND
    Success 'README.md' contains all search criteria!

Searched files in 0.002 seconds

Found 2 matching files out of 9 files searched

```

### Example 2 - decode quoted printable files

```
LookupFolder.pl --search forgotten --search customer --folder .\*.eml --decode

Search base path  : .\*.eml
Search target for : forgotten
Search target for : customer
Max file age mins : none
Flags             : [decode quoted printable]

Built file list in 0.005 seconds

[1] (age: 25.9 mins) cust1.eml
    forgotten ...  FOUND
    customer ...  FOUND
    Success 'cust1.eml' contains all search criteria!

[2] (age: 185.9 mins) cust.eml
    forgotten ...  not found

[3] (age: 1222.9 mins) 180_qponly.eml
    forgotten ...  FOUND
    customer ...  FOUND
    Success '180_qponly.eml' contains all search criteria!

[4] (age: 1225.9 mins) 180.eml
    forgotten ...  FOUND
    customer ...  FOUND
    Success '180.eml' contains all search criteria!

Searched files in 0.001 seconds

Found 3 matching files out of 4 files searched
```

### Example 3 - search strings are URL encoded

```
LookupFolder.pl --search reset%20your%20password --search customer --folder .\180.eml --decode

Search base path  : .\180.eml
Search target for : reset your password
Search target for : customer
Max file age mins : none
Flags             : [decode quoted printable]

Built file list in 0.005 seconds

[1] (age: 1226.6 mins) 180.eml
    reset your password ...  FOUND
    customer ...  FOUND
    Success '180.eml' contains all search criteria!

Searched files in 0 seconds

Found 1 matching files out of 1 files searched
```

### Example 4 - stop after first matching file found

```
LookupFolder.pl --search reset%20your%20password --search customer --folder .\*.eml --decode --stop

Search base path  : .\*.eml
Search target for : reset your password
Search target for : customer
Max file age mins : none
Flags             : [stop] [decode quoted printable]

Built file list in 0.005 seconds

[1] (age: 27.3 mins) cust1.eml
    reset your password ...  not found

[2] (age: 187.3 mins) cust.eml
    reset your password ...  not found

[3] (age: 1224.3 mins) 180_qponly.eml
    reset your password ...  FOUND
    customer ...  FOUND
    Success '180_qponly.eml' contains all search criteria!

Searched files in 0 seconds

Found 1 matching files out of 3 files searched
```

### Example 5 - stop if files too old

```
LookupFolder.pl --search reset%20your%20password --search customer --folder .\*.eml --decode --stop --max_age 1200

Search base path  : .\*.eml
Search target for : reset your password
Search target for : customer
Max file age mins : 1200
Flags             : [stop] [decode quoted printable]

Built file list in 0.005 seconds

[1] (age: 28.9 mins) cust1.eml
    reset your password ...  not found

[2] (age: 188.9 mins) cust.eml
    reset your password ...  not found

[3] (age: 1225.9 mins) 180_qponly.eml - TOO OLD - REMAINGING FILES THIS OLD OR OLDER, STOPPING...

Searched files in 0 seconds

Found 0 matching files out of 3 files searched
```