#!usr/bin/bash
echo ''
echo ''
echo "Starting Job on "
stampStart=`date`
echo $stampStart 


   for j in $( ls | grep .fastq$ );	do

   		echo ''
   		echo "==========Running Sickle for"
		echo $j
		echo ""
		sickle se -f $j -t sanger -o $j.trimmed.fastq
		
		echo ''
   		echo "==========Running FastQC for trimmed "
		echo $j.trimmed.fastq
		echo ""
		/data/Projects/cis_trans_regulation/FastQC/fastqc SRR203242.fastq.trimmed.fastq
		
		echo ''
		echo "==========Running GSNAP for"
		echo $j.trimmed.fastq
		echo ""
		#index 4.0 for diploids, and 4.1 for AD1, 4.2 for AD2
		gsnap -n 1 -N 1 -Q -t 8 --use-sarray=0 -D /data/databases/gmapdb/snpindex4.1 -d D5genome -v D13.snp4.1 -A sam $j.trimmed.fastq > $j.trimmed.sam 

        echo ''
		echo "==========Running SAMtools for" 
		echo $j.trimmed.sam
		echo ""
		samtools view -Sb $j.trimmed.sam > $j.trimmed.bam
		samtools sort $j.trimmed.bam $j.trimmed.sort
		samtools index $j.trimmed.sort.bam
		
        echo ''
		polyCat -x 1 -p 1 -s /data/databases/gmapdb/snpindex4.1/D13.snp4.1  $j.trimmed.sort.bam

        echo "Now compress fastq files
        echo $j.trimmed.fastq
        gzip -9 $j.trimmed.fastq

        echo "Now delete intermediate files
		echo $j.trimmed_fastqc.zip
		echo $j.trimmed.sam
		echo $j.trimmed.bam
        rm $j.trimmed_fastqc.zip
		rm $j.trimmed.sam
#		rm $j.trimmed.bam
   	done
   	
echo ''
echo ''
echo "Ending  Job on "
stampEnd=`date`
echo $stampEnd 
