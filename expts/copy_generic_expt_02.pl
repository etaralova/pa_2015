#!/usr/bin/perl
#use strict; 
#use warnings;
#if($#ARGV < 10){
#    print "specify \n";
#    exit;
#}

$EXPT_NAME = "steph_"; #$ARGV[];
$PKS_T = "3";
$HI_ACT = "0"; #$ARGV[]; #string!!!
@EE = ("spon", "gratings", "syn01a", "syn01b", "imagenet01a", "imagenet01b");
#("001", "002", "003", "004", "005", "006", "007", "009", "011");
$FILE_STRING = "NTC_REG_to002m_gcamp6s_c1v1_m_k1_d2-";
#"LSPK_REG_to002m_gcamp6s_c1v1_m_k1_d2-";
#@MT = ("loopy", "tree");
$MODEL_TYPE = "loopy";

for( $i = 0; $i <= $#EE; $i++){
    $EXPT_NUM = $EE[$i];
    $D = $EXPT_NAME."_".$EXPT_NUM;
    $DATA_DIR = "~/data/mouse/".$EXPT_NAME."/";
    if($PKS_T ne ""){
	$DATA_DIR = $DATA_DIR."/ge".$PKS_T."/";
    }
    mkdir($D);
    $scommand = sprintf("cp generic_expt/* %s/", $D);
    print "Running: ".$scommand."\n";
    ($status, $result) = system($scommand);
    #`$scommand`;
    #print $status;
    #print $result;
    #write get_real_data.m
    #if( chdir($D) == 0){
    #print "error changing dir!!!\n";
    #}
    #`touch test_kate`;



    print "file: get_real_data.m\n";
    open(my $FID, ">", "$D/get_real_data.m") 
	or die "cannot open < $!";
    print $FID "function [data,variable_names] = get_real_data()\n";
    print $FID "load(['".$DATA_DIR."' ...\n";
    print $FID "          '".$FILE_STRING.$EXPT_NUM.".mat']);\n";
    print $FID "%data is time_frames by number_of_neurons; it is logical andsparse\n";
    print $FID "%Kate\n";
    print $FID "if(~isempty(who('Spikes')))\n";
    print $FID "data = Spikes;\n";
    print $FID "elseif(~isempty(who('spmat')))\n";
    print $FID "    data = spmat;\n";
    print $FID "end\n";
    print $FID "if(size(data,1) < size(data,2))\n";
    print $FID "    data = data';\n";
    print $FID "end\n";
    print $FID "%now data is num_frames by num_neurons\n";
    print $FID "if(~isempty(who('labels')))\n";
    print $FID "    ii = find(labels ~= 0);\n";
    print $FID "    data = data(ii, :);\n";
    print $FID "end\n";
    print $FID "data = full(data);\n";
    print $FID "N = size(data,2);\n";
    print $FID "variable_names = {};\n";
    print $FID "for i = 1:N\n";
    print $FID "    variable_names(end+1) = {int2str(i)};\n";
    print $FID "end\n";
    print $FID "end\n";
    close($FID);
    
    print "done writing get_real_data.m\n";

    if(0){
    open(my $FID, ">", "$D/merge_all_models.m") 
	or die "cannot open < $!";
    print $FID "    exptPath = pwd;\n";
    print $FID "    cd('../../');\n";
    print $FID "    startup;\n";
    print $FID "% iterate through all result files merging the model collections\n";
    print $FID "    result_files = dir(sprintf('%s/results/result*.mat', exptPath));\n";
    print $FID "for i = 1:length(result_files)\n";
    print $FID "    split_result = load(sprintf('%s/results/%s', exptPath, result_files(i).name), 'model_collection');\n";
    print $FID "    if i == 1\n";
    print $FID "        merged_model_collection = split_result.model_collection;\n";
    print $FID "    else\n";
    print $FID "        merged_model_collection = merged_model_collection.merge_model_collections(split_result.model_collection);\n";
    print $FID "    end\n";
    print $FID "end\n";
    print $FID "model_collection = merged_model_collection;\n";
    print $FID "    save(sprintf('%s/results/model_collection.mat', exptPath), 'model_collection', '-v7.3');\n";
    print $FID "    fsave = exptPath(strfind(exptPath, 'expt/')+length('expt/'):end);\n";
    print $FID "    fsave = [fsave '_".$MODEL_TYPE."' ];\n";
    print $FID "    save(sprintf('".$DATA_DIR."/model_collection_%s.mat', fsave), 'model_collection', '-v7.3');\n";
    print $FID "    cd(exptPath);\n";
    close($FID);
    print "done writing merge_all_models.m\n";

    open(my $FID, ">", "$D/write_configs_for_loopy.m") 
	or die "cannot open < $!";    
    print $FID "create_config_files( ...\n";
    print $FID "    'experiment_name', '".$D."', ...\n";
    print $FID "    'email_for_notifications', '1live.life.queen.size1\@gmail.com', ...\n";
    print $FID "    'yeti_user', 'et2495', ...\n";
    print $FID "    'compute_true_logZ', true, ...\n";
    print $FID "    'reweight_denominator', 'mean_degree', ...\n";
    print $FID "    's_lambda_splits', 6, ...\n";
    print $FID "    's_lambdas_per_split', 1, ...\n";
    print $FID "    's_lambda_min', 2e-03, ...\n";
    print $FID "    's_lambda_max', 5e-01, ...\n";
    print $FID "    'density_splits', 1, ...\n";
    print $FID "    'densities_per_split', 4, ...\n";
    print $FID "    'density_min', 0.01, ...\n";
    print $FID "    'density_max', 0.04, ...\n";
    print $FID "    'p_lambda_splits', 5, ...\n";
    print $FID "    'p_lambdas_per_split', 1, ...\n";
    print $FID "    'p_lambda_min', 1e+01, ...\n";
    print $FID "			 'p_lambda_max', 1e+04);\n";
    close($FID); 
    print "done writing write_configs_for_loopy.m\n";

    open(my $FID, ">", "$D/write_configs_for_tree.m") 
	or die "cannot open < $!";    
    print $FID "create_config_files( ...\n";
    print $FID "    'experiment_name', 'UNNAMED_EXPT', ...\n";
    print $FID "    'email_for_notifications', '1live.life.queen.size1\@gmail.com', ...\n";
    print $FID "    'yeti_user', 'et2495', ...\n";
    print $FID "    'structure_type', 'tree', ...\n";
    print $FID "    'p_lambda_splits', 20, ...\n";
    print $FID "    'p_lambdas_per_split', 1, ...\n";
    print $FID "    'p_lambda_min', 1e+01, ...\n";
    print $FID "			 'p_lambda_max', 1e+07);\n";
    close($FID);

    print "done writing write_configs_for_tree.m\n";
    }
}
