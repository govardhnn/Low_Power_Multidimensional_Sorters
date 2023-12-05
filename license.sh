#!/bin/bash 

# LICENSE="verilog/LICENSE"
LICENSE="tb/LICENSE"

# change this to *.sv for the systemverilog testbenches license update
# finds the verilog/sysverilog files and reads them into verilog/sysverilog

find . -name "*.sv" | while read -r sysverilog ; do
    # check the directory of the verilog file found in this iteration
    dir=$(dirname $sysverilog) 
    {  
        echo "/*" ; echo "$(cat "$LICENSE")" ;  echo "*/" ; cat $sysverilog ;
    } >  $dir/sv_temp && mv $dir/sv_temp $sysverilog
    echo "Updated $sysverilog with License"
done
echo "LICENSE added to all files"
