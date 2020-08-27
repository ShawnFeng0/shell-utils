#!/usr/bin/expect

set ip [lindex $argv 0]
set username [lindex $argv 1]
set passwd [lindex $argv 2]
set cmd [lindex $argv 3]

spawn ssh -o KexAlgorithms=+diffie-hellman-group1-sha1 -o "StrictHostKeyChecking no" -l $username $ip
# spawn ssh -l $username $ip
expect {
        "yes/no" { send "yes\r";exp_continue }
        "password:" { send "$passwd\r" }
}

expect {
        "~ # " { send "$cmd\r" }
}

# expect eof
interact
