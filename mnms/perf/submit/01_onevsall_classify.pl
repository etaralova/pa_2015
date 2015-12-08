#!/usr/bin/perl
use Env;
use Cwd;

$code_path = cwd();
$ncpus = 2;

$CPATH = "~/src/crf/fwMatch/expt/";
$SUFFIX = "_loopy";
#@ORIENTS = (0,45,90,135,180,225);
@ORIENTS = (90,135);
@DEPTHS = (1,2);
@EXPTS = ();
$count = 0;
for($o = 0; $o <= $#ORIENTS; $o++){
    for($d = 0; $d <= $#DEPTHS; $d++){
	$EXPT = sprintf("steph_%d_%02d%s", $ORIENTS[$o], $DEPTHS[$d], $SUFFIX);
	#for ($e = 0; $e < $#EXPTS; $e++){
	
	#$EXPT = sprintf("steph_0_%02d%s",$EXPTS[$e],$SUFFIX);

	$filename = "q_".$EXPT.".qsub";
	open(FID, ">".$filename) or die("Error $!\n");
	print FID "#!/bin/sh\n#PBS -l nodes=1:ppn=".$ncpus.",walltime=71:00:00,mem=18000mb\n";
	print FID "#PBS -W group_list=yetibrain\n";
	print FID "#PBS -m abe\n".
	    "#PBS -M 1live.life.queen.size1@gmail.com\n".
	    "#PBS -V\n";
	#"#PBS -t 1\n";
	print FID "#PBS -o localhost:/vega/brain/users/et2495/src/crf/fwMatch/mnms/perf/submit/\n";
	print FID "#PBS -e localhost:/vega/brain/users/et2495/src/crf/fwMatch/mnms/perf/submit/\n";
	#print FID "pbsdsh -c 1 -v -u ".$code_path."/02_onevsall_classify.pl ".$EXPT.
	#    " ".$ORIENTS[$o]." ".$DEPTHS[$d]." ".$SUFFIX." ".$CPATH.
	#    " > out_".$EXPT.".out"."\n";


	print FID "pbsdsh -c 1 -v -u \n";
	print FID "./02_onevsall_classify.pl ".$EXPT.
	    " ".$ORIENTS[$o]." ".$DEPTHS[$d]." ".$SUFFIX." ".$CPATH.
	    " &> out_".$EXPT.".out"."\n";

	close(FID);
	chmod 0755, $filename;
	
	print "Running: $filename?\n";
	
	$scommand = sprintf("qsub %s", $filename);
	($outp, $result) = system($scommand);# == 0
	chomp($result);
	print $result."\n";
	sleep(3);
    }
}
