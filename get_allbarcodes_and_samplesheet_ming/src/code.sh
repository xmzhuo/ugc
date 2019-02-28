#!/bin/bash
# get_allbarcodes_file 0.0.1
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

    set -e -x -o pipefail

    echo "Value of fastq: '$fastq'"

    # The following line(s) use the dx command-line tool to download your file
    # inputs to the local file system using variable names for the filenames. To
    # recover the original filenames, you can use the output of "dx describe
    # "$variable" --name".

    #dx-download-all-inputs

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

    #Get run ID
    run_id=$(dx describe $(dx find data --name $fastq_name --brief) --json | jq '.properties.run_id' -r)
    echo $run_id
    project_id=$(dx describe $(dx find data --name $fastq_name --brief) --json | jq '.project' -r)
    echo 1:$project_id
    #sample_name=$(dx describe $(dx find data --name $fastq_name --brief) --json | jq '.properties.run_id' -r | sed 's/\..*$//')
    sample_name=$(echo $fastq_name | sed 's/\..*$//')
    #Get sample sheet
    mkdir out/all_barcodes -p
    mkdir out/sample_sheet -p

    dx download Upload:/${run_id}/analyses/${run_id}/summary/all_barcodes* -o ~/out/all_barcodes/${run_id}__${sample_name}__all_barcodes.html
    #dx download Upload:/${run_id}/analyses/${run_id}/summary/all_barcodes* -o ~/out/all_barcodes/${run_id}__${sample_name}__all_barcodes.html
    dx download Upload:/${run_id}/runs/SampleSheet.csv -o ~/out/sample_sheet/${run_id}__${sample_name}__SampleSheet.csv

    # The following line(s) use the dx command-line tool to upload your file
    # outputs after you have created them on the local file system.  It assumes
    # that you have used the output field name for the filename for each output,
    # but you can change that behavior to suit your needs.  Run "dx upload -h"
    # to see more options to set metadata.

    #all_barcodes=$(dx upload all_barcodes --brief)

    # The following line(s) use the utility dx-jobutil-add-output to format and
    # add output variables to your job's output as appropriate for the output
    # class.  Run "dx-jobutil-add-output -h" for more information on what it
    # does.

    #dx-jobutil-add-output all_barcodes "$all_barcodes" --class=file

    dx-upload-all-outputs
}
