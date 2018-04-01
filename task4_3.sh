#!/bin/bash

function show_help {
echo -e "\nUsage:\n$0 </full/path/to/the/target/dir> <number_of_files_to_rotate>\n"
}

r=\\e[41m
cc=\\e[0m

#checks number of args
if ! [[ $# == 2 ]]; then echo -e "${r}Wrong number of args${cc}" >&2; show_help && exit 1; fi

target_dir="$1"
rotate_num="$2"
storage_dir="/tmp/backups"
file_prefix=$(echo ${target_dir} | sed 's@^/@@;s@/$@@;s@/@-@g')

#checks if a file with the name 'backups' exists
if [[ -f ${storage_dir} ]]; then echo -e "${r}A regular file ${storage_dir} exists and should be removed${cc}" >&2 && exit 1; fi

#checks if backups folder exists and creates it otherwise
[[ -d ${storage_dir} ]] || mkdir ${storage_dir}

#checks if the first arg is an existing directory
if ! [[ -d "${target_dir}" ]]; then echo -e "${r}Invalid path to the folder${cc}" >&2; show_help && exit 1; fi

#checks if the second arg is a number
if ! [[ ${rotate_num} =~ ^[[:digit:]]+$ ]]; then echo -e "${r}Second argument is not a number${cc}" >&2; show_help && exit 1; fi

# adds the content of the target dir to a compressed tar archive
tar czf "${storage_dir}/${file_prefix}_$(date +'%Y%m%d_%H-%M-%S-%3N').tar.gz" "${target_dir}"/* > /dev/null 2>&1
[[ $? == 1 ]] && echo -e "${r}Something went wrong when creating an archive${cc}" && exit 1

#counts the number of archives to implement rotation and removes old archives if needed
bkp_count=$(find "${storage_dir}" -type f -regextype posix-extended -regex ".*/${file_prefix}_.{21}\.tar\.gz" | wc -l)
if [[ ${bkp_count} -gt ${rotate_num} ]]; 
then rm_counter=$(( bkp_count - rotate_num ));
find "${storage_dir}" -type f -regextype posix-extended -regex ".*/${file_prefix}_.{21}\.tar\.gz" | sort -n | head -"${rm_counter}" | xargs -d "\n" rm;
fi
