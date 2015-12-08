#!/usr/bin/perl
use Env;
chdir("/u/4/e/et2495/src/crf/fwMatch/mnms/sample");
$this_hostname = `hostname`;
chomp($this_hostname);
$key = $ENV{'PBS_JOBID'};
#################################

($job_id, $junk) = split(/\./, $key);
print "Job ID is: ".$job_id." from: ".$key." :) \n";
print "Running on ".$this_hostname."\n";

$filename = "s_smpl_".$ARGV[0]."_".$job_id;

print "File is: ".$filename."\n";

open(FID, ">".$filename.".m") or die("Error HERE $!\n");
print FID "EXPT = '".$ARGV[0]."';\n";
print FID "PATH = '".$ARGV[1]."';\n";
print FID "DEPTH_ID = ".$ARGV[2].";\n";
print FID "ORIENT = ".$ARGV[3].";\n";
print FID "SCRIPT = 1;\n";
print FID "run('steph_sample_from_models.m');\n";
print FID "exit(0)\n";
close(FID);

print "about to run matlab:\n";
system("/usr/local/bin/matlab -nodisplay -nojvm -nosplash -r \"$filename; exit;\" \n");
print "\ndone with system call\n";

