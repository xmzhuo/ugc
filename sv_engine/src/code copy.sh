#!/bin/bash
# coverage_of_key_genes 0.0.1
# Generated by dx-app-wizard.
#
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

    echo "Value of command_option: '$command_option'"
    echo "Value of call_option: '$call_option'"
    echo "Value of genome_build: '$genome_build'"
    echo "Value of ref_genome: '$ref_genome'"
    echo "Value of Sample Bam: '$sample_bam'"
    echo $HOME
    echo "$cmd_sh_name"

    #head $cmd_sh_path

    # The following line(s) use the dx command-line tool to download your file
    # inputs to the local file system using variable names for the filenames. To
    # recover the original filenames, you can use the output of "dx describe
    # "$variable" --name".

    dx-download-all-inputs --parallel
    
    #docker pull wanpinglee/sve &
    #dx-docker pull wanpinglee/sve &
    dx-download-all-inputs --parallel


    mkdir -p /data/
    mkdir -p /data/in/
    mkdir -p /data/out/
    
    #remove all subfolder but keep files
    find in/ -type f -exec mv {} /data/in/ \;
    #write variable to the shell script
    sed -i "1icommand_option='${command_option}'" /data/in/${cmd_sh_name[0]}
    sed -i "1icall_option='${call_option}'" /data/in/${cmd_sh_name[0]}
    sed -i "1igenome_build='${genome_build}'" /data/in/${cmd_sh_name[0]}
    sed -i "1iref_genome='${ref_genome_name[0]}'" /data/in/${cmd_sh_name[0]}
    sed -i "1isample_bam='${sample_bam_name[0]}'" /data/in/${cmd_sh_name[0]}
    
    head /data/in/${cmd_sh_name[0]}

    chmod +x /data/in/${cmd_sh_name[0]}

    # https://github.com/TheJacksonLaboratory/SVE
    
    #docker run -v /data:/data -it wanpinglee/sve bash /data/in/${cmd_sh_name[0]}
    dx-docker run -v /data:/data wanpinglee/sve bash /data/in/${cmd_sh_name[0]}


    echo "# gatk pipeline output"
    ls -LR /data/out/

    mkdir $HOME/out/

    mkdir $HOME/out/output/

    mv /data/out/* $HOME/out/output/

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
