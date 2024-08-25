#!/bin/bash 

LICENSE="bsv/LICENSE"

# change this to *.sv for the systemverilog testbenches license update
# finds the verilog/bsv_file files and reads them into verilog/bsv_file

find . -name "*.bsv" | while read -r bsv_file ; do
    # check the directory of the verilog file found in this iteration
    dir=$(dirname $bsv_file) 
    {  
        echo "/*" ; echo "$(cat "$LICENSE")" ;  echo "*/" ; cat $bsv_file ;
    } >  $dir/sv_temp && mv $dir/sv_temp $bsv_file
    echo "Updated $bsv_file with License"
done
echo "LICENSE added to all files"
