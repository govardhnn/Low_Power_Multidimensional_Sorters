#!/bin/bash 

LICENSE="verilog/LICENSE"

# change this to *.sv for the systemverilog testbenches license update
# finds the verilog files and reads them into verilog
find . -name "*.v" | while read -r verilog ; do
    # check the directory of the verilog file found in this iteration
    dir=$(dirname $verilog) 
    {  
        echo "/*" ; echo "$(cat "$LICENSE")" ;  echo "*/" ; cat $verilog ;
    } >  $dir/v_temp && mv $dir/v_temp $verilog
    echo "Updated $verilog with License"
done
echo "LICENSE added to all files"
