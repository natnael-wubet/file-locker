This tool is a file locker that use AES(Advanced encryption standard).

This tool will encrypt/decrypt any kinds of files with 16 digit password(you can change it on the source code).

It will save it as a *.locked file which contains a encrypted bytes in it but doesnt replace the old file for some case of backupping, but you can uncomment line 88 if you wanna remove the file after encrypt it.

Bugs:
	-Some times memory fetching exeception thrown if the file is to big to read, so you need to select light files on size if you have old pc with a litle amount of memory.
	-It wont decrypt the file if you try to decrypt the encrypted(.locked) file with the same window that you use to encrypt it so reopen it.

Email: natyw4122@gmail.com
