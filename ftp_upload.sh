#!/bin/env sh

cd "$(dirname "$0")" || exit

if [ $# -lt 3 ]; then
  echo "usage: $0 <destination_ip> <local_file/folder> <origin_folder>"
  echo "sample: "
  echo "$0 192.168.xxx.xxx . /test"
  echo ""
  echo "Parameter:"
  echo "<destination_ip> is an ipv4 address that can be verified by the ping command."
  echo "<local_file/folder> is a local file/folder"
  echo "<origin_folder> is an existing absolute path with the ftp mount directory as the root directory."
  exit 1
fi

# Determine whether the IP address can be reached
ip="$1"
if ! ping -c 1 "$ip"; then
  echo "The IP address $ip cannot be accessed."
  exit 1
fi

# Set the directory according to the parameters
source="$2"
origin_dir="$3"

if [ -d "$source" ]; then
  # The following operation will delete the folder and rebuild
  FTP_CMD_MKDIR=$(find "$source" -type d -printf "$origin_dir"/'%P\n' | awk '{if ($0 == '\""$origin_dir"/\"') next ;print "cd " $0 "\n" "mdelete " $0 "\n" "rmdir " $0 "\n" "mkdir " $0 "\n"}')
  FTP_CMD_CREATE_FILE=$(find "$source" -type f -printf 'put %p '"$origin_dir"/'%P\nls '"$origin_dir"/'%P\n')
else
  FTP_CMD_MKDIR=""
  FTP_CMD_CREATE_FILE="put $source $origin_dir/${source##*/}"
fi

ftp -n "$ip" <<EOF
type binary
prompt
$FTP_CMD_MKDIR
$FTP_CMD_CREATE_FILE
quit
EOF
