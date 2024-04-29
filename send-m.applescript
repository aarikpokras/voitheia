tell application "Messages"
	set rec to "RECIP"
	set serv to id of 1st account whose service type = iMessage
	set mes to "MESSA"
	send mes to participant rec of account id serv
end tell
