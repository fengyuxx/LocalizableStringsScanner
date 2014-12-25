LocalizableStringsScanner
=========================

Scan a objective-c project dir, find out localizable strings used in code but not defined in Localizable file.

Useage:

	$ LocalizableStringsScanner [-p=<dir>] [-m=<method>] [-l=<path>] [-v]

	-p=<dir>      scan dir
	-m=<method>   localizable string method used in code,
	              default is "NSLocalizedString".
	-l=<path>     localizable string file path,
	              default to search Localizable.strings file in scan dir.
	-v            verbose mode.
	
