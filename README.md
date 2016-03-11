# LookupFolder 0.02
Search a Windows network folder for files containing multiple strings

### Example 1
```
LookupFolder.pl --search print --search user1 --folder .
```

### Sample Output
```

Search base path  : .
Search target for : print
Search target for : user1
Search mode       : stop
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

### Example 2

```
LookupFolder.pl --search forgotten --search customer --folder .\*.eml --decode

Search base path  : .\*.eml
Search target for : forgotten
Search target for : customer
Search mode       : stop
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

