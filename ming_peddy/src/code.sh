#!/bin/bash
# peddy
# Generated by dx-app-wizard.
# Modify from peddy by Xinming Zhuo

# Basic execution pattern: Your app will run on a single machine from
# beginning to end.
#
# Your job's input variables (if any) will be loaded as environment
# variables before this script runs.  Any array inputs will be loaded
# as bash arrays.
#
# Any code outside of main() (or any entry point you may add) is
# ALWAYS executed, followed by running the entry point itself.
#
# See https://wiki.dnanexus.com/Developer-Portal for tutorials on how
# to modify this file.

main() {

    echo $HOME
    
    # The following line(s) use the dx command-line tool to download your file
    # inputs to the local file system using variable names for the filenames. To
    # recover the original filenames, you can use the output of "dx describe
    # "$variable" --name".
    #dx-docker pull xmzhuo/peddy &
    #sudo docker pull xmzhuo/peddy &
    dx-download-all-inputs --parallel
          
    mkdir -p /data/
    mkdir -p /data/in/
    
    mkdir -p /data/out/
    mkdir -p /data/out/output/
    mkdir -p /data/out/ped
    mkdir -p /data/out/call
    #remove all subfolder but keep files
    find in/ -type f -exec mv {} /data/in/ \;
    
    cd /data/in/
    ls *.vcf.gz > vcf_list
    
    wait 
    ls -LR /data/in/

    while read p;
        do 
        echo $p
        p_name=$(echo $p| sed "s/\.vcf\.gz//")
        touch $p.tbi
        sample_name=$(zcat $p | grep -m1 "^#CHROM" |awk '{print $10}')
        echo -e "$p_name\t$sample_name\t0\t0\t2\t0" > $p_name.ped

        echo "cd /data/in" > cmd.sh
        echo "/root/miniconda3/bin/peddy --plot -p 4 --prefix $p_name $p $p_name.ped" >> /data/in/cmd.sh

        sudo docker run -v /data:/data xmzhuo/peddy bash /data/in/cmd.sh
        # /root/miniconda3/bin/peddy --plot --prefix $p_name /data/in/$p /data/in/$p_name.ped
        cat $p_name.het_check.csv | awk -v FS=',' '{print $1,$16,$17}' > het
        cat $p_name.sex_check.csv | awk -v FS=',' '{print $7,$3}' > sex
        paste -d' ' het sex | sed 's/ /,/g'> $p_name.call.csv

        mkdir /data/out/output/$p_name
        mv *.call.csv /data/out/call/
        mv *.peddy.ped /data/out/ped/
        mv *.json /data/out/output/$p_name/
        mv *.csv /data/out/output/$p_name/
        mv *.png /data/out/output/$p_name/
        mv *.html /data/out/output/$p_name/
               
        rm het sex

    done < vcf_list

    echo " pipeline output"
    ls -LR /data/out/

    mkdir $HOME/out/

    #mkdir $HOME/out/output/

    mv /data/out/* $HOME/out/
 
    echo "# files in output folder"

    ls -LR $HOME/out/
    dx-upload-all-outputs --parallel
    
    # The following line(s) use the utility dx-jobutil-add-output to format and
    # add output variables to your job's output as appropriate for the output
    # class.  Run "dx-jobutil-add-output -h" for more information on what it
    # does.

    #for i in "${!output[@]}"; do
     #   dx-jobutil-add-output output "${output[$i]}" --class=array:file
    #done
    #dx-jobutil-add-output plot "$plot" --class=file
}
