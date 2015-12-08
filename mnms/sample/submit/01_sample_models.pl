#!/usr/bin/perl
use Env;
use Cwd;

$code_path = cwd();
$ncpus = 1;
$queue = "dsi";

$CPATH = "~/data/steph_225_tree/";
$SUFFIX = "_tree";
@ORIENTS = (0,45,90,135,180,225);
#@ORIENTS = (90,135);
@DEPTHS = (1,2);

for($o = 0; $o <= $#ORIENTS; $o++){
    for($d = 0; $d <= $#DEPTHS; $d++){
	$EXPT = sprintf("steph_%d_%02d%s", $ORIENTS[$o], $DEPTHS[$d], $SUFFIX);

	$filename = "q_smpl_".$EXPT.".qsub";
	open(FID, ">".$filename) or die("Error $!\n");
	print FID "#!/bin/sh\n#PBS -l nodes=1:ppn=".$ncpus.",walltime=7:00:00,mem=7999mb\n";
	print FID "#PBS -W group_list=yeti".$queue."\n";
	print FID "#PBS -m abe\n".
	    "#PBS -M 1live.life.queen.size1@gmail.com\n".
	    "#PBS -V\n";
	print FID "#PBS -o localhost:/vega/brain/users/et2495/src/crf/fwMatch/mnms/sample/submit/\n";
	print FID "#PBS -e localhost:/vega/brain/users/et2495/src/crf/fwMatch/mnms/sample/submit/\n";
	print FID "pbsdsh -c 1 -v -u \n";
        print FID "./02_sample_models.pl ".$EXPT." ".$CPATH.
	    " ".$DEPTHS[$d]." ".$ORIENTS[$o].
            " &> out_smpl_".$EXPT.".out"."\n";
	close(FID);
	chmod 0755, $filename;

	print "Running: $filename\n";
	$scommand = sprintf("qsub %s", $filename);
	($outp, $result) = system($scommand);# == 0
	chomp($result);
	print $result."\n";
	sleep(2);
    }
}
