#!/bin/bash

# -e = exit on error; -x = output each line that is executed to log; -o pipefail = throw an error if there's an error in pipeline
set -e -x -o pipefail

main() {

    echo "Value of query_vcfs: '${query_vcfs[@]}'"
    echo "Value of truth_vcf: '$truth_vcf'"
    echo "Value of panel_bed: '$panel_bed'"
    echo "Value of high_conf_bed: '$high_conf_bed'"
    echo "Value of na12878: '$na12878'"
    echo "Value of happy_applet_id: '$happy_applet_id'"

    # Get file ids to pass as app input
    truth_vcf_id=$(echo $truth_vcf | awk -F ": " '{print $NF}' | awk -F "}" '{print $1}' | sed s/"\""/""/g)
    panel_bed_id=$(echo $panel_bed | awk -F ": " '{print $NF}' | awk -F "}" '{print $1}' | sed s/"\""/""/g)
    high_conf_bed_id=$(echo $high_conf_bed   | awk -F ": " '{print $NF}' | awk -F "}" '{print $1}' | sed s/"\""/""/g)
    echo "Truth: $truth_vcf_id"
    echo "Panel: $panel_bed_id"
    echo "Bed $high_conf_bed_id"

    parent_job_destination=$(dx describe $DX_JOB_ID | grep "^Output folder " | awk -F " " '{print $NF}')
    echo "Parent job dest: $parent_job_destination"

    # Run app for each query vcf
    for query_vcf in ${query_vcfs[@]}
    do
    	echo $query_vcf
    	if [[ $query_vcf != '{"$dnanexus_link":' ]]; then
    		query_vcf_id=$(echo $query_vcf | awk -F "}" '{print $1}' | sed s/"\""/""/g)
        	dx describe $query_vcf_id
        	command="dx run $happy_applet_id -iquery_vcf=$query_vcf_id -itruth_vcf=$truth_vcf_id -ipanel_bed=$panel_bed_id -ihigh_conf_bed=$high_conf_bed_id -iprefix="test" -ina12878=$na12878 --destination=$parent_job_destination"
        	echo $command
        	eval $command
        fi
    done

}