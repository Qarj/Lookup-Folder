# LookupFolder 0.04
Search a Windows network folder for files containing multiple strings.

The search strings are assumed to be URL encoded. There is an option to indicate
that the files are encoded as quoted printable and should be decoded.

This script is designed to be as fast as possible over WAN network shares.

### Example 1
```
LookupFolder.pl --search print --search user1 --folder .
```

### Sample Output
```

Search base path  : .
Search target for : print
Search target for : user1
Max file age mins : 10
Flags             :

Built file list in 0.005 seconds

[1] LICENSE:
    print ...  FOUND
    user1 ...  not found

[2] CHANGES.md:
    print ...  not found

[3] LookupFolder.pl:
    print ...  FOUND
    user1 ...  FOUND
    Success 'LookupFolder.pl' contains all search criteria!

[4] README.md:
    print ...  not found

Searched files in 0.008 seconds

Found 1 matching files out of 4 files searched

```

### Example 2 - decode quoted printable files

```
LookupFolder.pl --search forgotten --search customer --folder .\*.eml --decode

Search base path  : .\*.eml
Search target for : forgotten
Search target for : customer
Max file age mins : 10
Flags             : [decode quoted printable]

Built file list in 0.005 seconds

[1] 180_qponly.eml:
    forgotten ...  FOUND
    customer ...  FOUND
    Success '180_qponly.eml' contains all search criteria!

[2] 180.eml:
    forgotten ...  FOUND
    customer ...  FOUND
    Success '180.eml' contains all search criteria!

Searched files in 0 seconds

Found 2 matching files out of 2 files searched
```

### Example 3 - search strings are URL encoded

```
LookupFolder.pl --search reset%20your%20password --search customer --folder .\180.eml --decode

Search base path  : .\180.eml
Search target for : reset your password
Search target for : customer
Max file age mins : 10
Flags             : [decode quoted printable]

Built file list in 0.005 seconds

[1] 180.eml:
    reset your password ...  FOUND
    customer ...  FOUND
    Success '180.eml' contains all search criteria!

Searched files in 0.003 seconds

Found 1 matching files out of 1 files searched
```

### Example 4 - stop after first matching file found

```
LookupFolder.pl --search reset%20your%20password --search customer --folder .\*.eml --decode --stop

Search base path  : .\*.eml
Search target for : reset your password
Search target for : customer
Max file age mins : 10
Flags             : [stop] [decode quoted printable]

Built file list in 0.005 seconds

[1] 180_qponly.eml:
    reset your password ...  FOUND
    customer ...  FOUND
    Success '180_qponly.eml' contains all search criteria!

Searched files in 0 seconds

Found 1 matching files out of 1 files searched
```
