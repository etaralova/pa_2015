#!/usr/bin/perl
use Env;
use Cwd;

$code_path = cwd();
$ncpus = 1;
$queue = "brain";

$CPATH = "~/src/crf/fwMatch/expt/";
$SUFFIX = "_tree";
#@ORIENTS = (0,45,90,135,180,225);
@ORIENTS = (0,45,90);
#@ORIENTS = (135,180,225);
@DEPTHS = (1,2);

for($o = 0; $o <= $#ORIENTS; $o++){
    for($d = 0; $d <= $#DEPTHS; $d++){
	$EXPT = sprintf("steph_%d_%02d%s", $ORIENTS[$o], $DEPTHS[$d], $SUFFIX);
	$filename = "q_infs_".$EXPT.".qsub";
	open(FID, ">".$filename) or die("Error $!\n");
	print FID "#!/bin/sh\n#PBS -l nodes=1:ppn=".$ncpus.",walltime=23:59:00,mem=7999mb\n";
	print FID "#PBS -W group_list=yeti".$queue."\n";
	print FID "#PBS -m abe\n".
	    "#PBS -M 1live.life.queen.size1@gmail.com\n".
	    "#PBS -V\n";
	print FID "#PBS -o localhost:/vega/brain/users/et2495/src/crf/fwMatch/mnms/perf/submit/\n";
	print FID "#PBS -e localhost:/vega/brain/users/et2495/src/crf/fwMatch/mnms/perf/submit/\n";
	print FID "pbsdsh -c 1 -v -u \n";
	print FID "./02_infer_single.pl ".$EXPT.
	    " ".$ORIENTS[$o]." ".$DEPTHS[$d]." ".$SUFFIX." ".$CPATH.
	    " &> out_infs_".$EXPT.".out"."\n";

	close(FID);
	chmod 0755, $filename;
	
	print "Running: $filename?\n";
	
	$scommand = sprintf("qsub %s", $filename);
	($outp, $result) = system($scommand);# == 0
	chomp($result);
	print $result."\n";
	sleep(2);
    }
}
