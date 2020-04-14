process_name=$1
ret=${nxf_main_ret:=0}
if [ ${ret} -ne 0 ]
then
    stderr_msg=$(cat .command.stderr | sed 's/\\n/\\\\n/g')
    stdout_msg=$(cat .command.stderr | sed 's/\\n/\\\\n/g')
    echo "{'process_name': '${process_name}', 'exitcode': '${ret}', 'stderr':'${stderr_msg:=none}', 'stdout': '${stdout_msg:=none}', 'pwd': '${PWD}'} " | sed "s/'/\"/g" > error.json
fi
nxf_main_ret=0
