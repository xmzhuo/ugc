#!/bin/bash
# combined_cnv 0.0.1
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

    echo "Value of cnv_result: '${Input_array[@]}'"

    # Make a data directory to mount into the Docker container
    mkdir -p /data/
    mkdir -p /data/in/
    mkdir -p /data/out/
           
    sudo apt-get -y install parallel &
    BIN_VERSION="0.7.0"
    sudo docker pull gcr.io/deepvariant-docker/deepvariant:"${BIN_VERSION}" &

    dx-download-all-inputs --parallel 
    
    #remove all subfolder but keep files and move from /in to /data/in
    find in/ -type f -exec mv {} /data/in/ \;
    
    echo "# input files"   
    echo "region = $region"
    echo "N_SHARDS = $N_SHARDS"       
    ls -LR /data/in/
    ls /data/out/

    #sed -i "1icmdstr='${cmd_string}'" /data/in/${cmd_sh_name[0]}
    #head /data/in/${cmd_sh_name[0]}
    #chmod +x /data/in/${cmd_sh_name[0]}
    
    LOGDIR=/data/out/logs
    #N_SHARDS=3
    OUTPUT_DIR=/data/out
    
    #unzip the selected model tar.gz
    cd /data/in/
    model_tar=$(ls *.tar.gz)
    tar -xzf $model_tar
    model_folder=`tar -tzf $model_tar | head -1 | cut -f1 -d"/"` 
    echo $model_folder
    MODEL=/data/in/${model_folder}/model.ckpt
    rm $model_tar
  
    REF=/data/in/$(ls *.fasta)
    BAM=/data/in/$(ls *.bam)

    CALL_VARIANTS_OUTPUT="${OUTPUT_DIR}/call_variants_output.tfrecord.gz"
    FINAL_OUTPUT_VCF="${OUTPUT_DIR}/output.vcf.gz"

    echo "Make_example"

    mkdir -p "${LOGDIR}"

    wait
    time seq 0 $((N_SHARDS-1)) | \
        sudo parallel --eta --halt 2 --joblog "${LOGDIR}/log" --res "${LOGDIR}" \
        sudo docker run \
            -v /data:/data \
            gcr.io/deepvariant-docker/deepvariant:"${BIN_VERSION}" \
            /opt/deepvariant/bin/make_examples \
            --mode calling \
            --ref "${REF}" \
            --reads "${BAM}" \
            --examples "${OUTPUT_DIR}/examples.tfrecord@${N_SHARDS}.gz" \
            --task {} \
            --regions "'${region}'" 
            #

    echo "#call_variants"

    sudo docker run \
      -v /data:/data \
      gcr.io/deepvariant-docker/deepvariant:"${BIN_VERSION}" \
      /opt/deepvariant/bin/call_variants \
       --outfile "${CALL_VARIANTS_OUTPUT}" \
       --examples "${OUTPUT_DIR}/examples.tfrecord@${N_SHARDS}.gz" \
       --checkpoint "${MODEL}"

    echo "#postprocess_variants"

     sudo docker run \
      -v /data:/data \
      gcr.io/deepvariant-docker/deepvariant:"${BIN_VERSION}" \
      /opt/deepvariant/bin/postprocess_variants \
      --ref "${REF}" \
      --infile "${CALL_VARIANTS_OUTPUT}" \
      --outfile "${FINAL_OUTPUT_VCF}"

    #Evaluating the results

    #sudo docker pull pkrusche/hap.py
    #sudo docker run -it -v /data:/data \
    #  pkrusche/hap.py /opt/hap.py/bin/hap.py \
    #  /data/docker_data/quickstart-testdata/test_nist.b37_chr20_100kbp_at_10mb.vcf.gz \
    #  "${FINAL_OUTPUT_VCF}" \
    # -f /data/quickstart-testdata/test_nist.b37_chr20_100kbp_at_10mb.bed \
    # -r "${REF}" \
    #  -o "${OUTPUT_DIR}/happy.output" \
    # --engine=vcfeval \
    #  -l chr20:10000000-10010000
    
    #dx-docker run -v /data/:/gatk/data xmzhuo/genomic:4.0.9.1 /gatk/data/in/${cmd_sh_name[0]}  

    echo "# gatk pipeline output"
    ls -LR /data/out/

    mkdir $HOME/out/

    mkdir $HOME/out/output/

    mv /data/out/* $HOME/out/output/

    echo "# files in output folder"

    ls -LR $HOME/out/
    dx-upload-all-outputs --parallel

    # The following line(s) use the dx command-line tool to download your file
    # inputs to the local file system using variable names for the filenames. To
    # recover the original filenames, you can use the output of "dx describe
    # "$variable" --name".

    #for i in ${!cnv_result[@]}
    #do
    #    dx download "${cnv_result[$i]}" -o cnv_result-$i
    #done

    # Fill in your application code here.
    #
    # To report any recognized errors in the correct format in
    # $HOME/job_error.json and exit this script, you can use the
    # dx-jobutil-report-error utility as follows:
    #
    #   dx-jobutil-report-error "My error message"
    #
    # Note however that this entire bash script is executed with -e
    # when running in the cloud, so any line which returns a nonzero
    # exit code will prematurely exit the script; if no error was
    # reported in the job_error.json file, then the failure reason
    # will be AppInternalError with a generic error message.

    # The following line(s) use the utility dx-jobutil-add-output to format and
    # add output variables to your job's output as appropriate for the output
    # class.  Run "dx-jobutil-add-output -h" for more information on what it
    # does.

    #for i in "${!output[@]}"; do
    #    dx-jobutil-add-output output "${output[$i]}" --class=array:file
    #done
}
