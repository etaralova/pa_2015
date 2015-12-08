addpath(genpath('~/src/crf/fwMatch'));
exptPath = pwd;
cd('../../');
startup;
cd(exptPath);

EE = {'482923718', '482924833', '483020038', ...
      '483020476', '483056972', '483059231', ...
      '483061828'};

%data_PRE = 'data_';
%data_SUF = '';
%orient_PRE = 'olabels_';
%orient_SUF = '';
%freq_PRE = 'flabels';
%freq_SUF = '';

data_PRE = 'dff_data_'; data_SUF = '_mean_preStim_responses';
orient_PRE = 'dff_orient_'; orient_SUF = '_mean_preStim_responses';
freq_PRE = 'dff_freq_'; freq_SUF = '_mean_preStim_responses';
SAVE_PRE = 'dff_mprs';

ALL_ROIS = {};
e_i = 1;
ALL_DATA = {};
ALL_FLABELS = {};
ORIENT_USE = 225;
for e = EE
  expt = e{1};
  fprintf('reading: %s\n', ...
          ['~/data/steph_225/' data_PRE expt data_SUF '.csv']);
  %data is number of neurons times frames
  data = dlmread(['~/data/steph_225/' data_PRE expt data_SUF '.csv']);
  olabels = dlmread(['~/data/steph_225/' orient_PRE expt orient_SUF '.csv']);
  %column vectors:
  flabels = dlmread(['~/data/steph_225/' freq_PRE expt freq_SUF '.csv']);

  olabels = int32(olabels);
  flabels = int32(flabels);

  data_temp = [];
  orient_U = unique(olabels);
  freq_U = unique(flabels);

  orient_ii = find(olabels == ORIENT_USE);
  ALL_DATA{e_i} = data(:, orient_ii);
  ALL_FLABELS{e_i} = flabels(orient_ii);
  clear data flabels olabels;
  e_i = e_i + 1;
  fprintf('done reading in csv files for %s\n',expt );
end

EXPTS_N = length(EE);
%% save data per layer:

for e = 1:EXPTS_N  

  data = ALL_DATA{e};
  labels = ALL_FLABELS{e};
  data = sparse(data > 0.3);
  %making data num frames by number of neurons:
  data = data';
  fsave = sprintf(['~/data/steph_225/all_' SAVE_PRE ...
                   '_%d_%02d.mat'], ORIENT_USE, ...
                  e);
  expt_name = EE{e};
  save(fsave, 'data', 'labels', 'expt_name');
  fprintf('SAVED: %s\n', fsave);
end

%%


freq_U = unique(ALL_FLABELS{1});
freq_U = reshape(freq_U, 1, length(freq_U));

DATA = [];
FLABELS = [];
for f = freq_U
  temp_data = {};
  min_len = Inf;
  for e = 1:EXPTS_N
    ii = find(ALL_FLABELS{e} == f);
    temp_data{e} = ALL_DATA{e}(:,ii);
    if(length(ii) < min_len)
      min_len = length(ii) ;
    end
  end
  data1 = [];
  for e = 1:EXPTS_N
    data1 = [data1; temp_data{e}(:,1:min_len)];
  end
  FLABELS = [FLABELS, ones(1, size(data1,2), 'uint8')*uint8(f)];
  DATA = [DATA, data1];
  fprintf('done e = %d\n', e);
end

data = DATA;
clear DATA;
labels = FLABELS;
clear FLABELS;

data = sparse(data > 0.3);
%making data num frames by number of neurons:
data = data';
fsave = sprintf('~/data/steph_225/all_%s_%d.mat', SAVE_PRE, ORIENT_USE);
save(fsave, 'data', 'labels');
fprintf('SAVED: %s\n', fsave);

return


load('~/data/steph_225/all_data.mat');
load('~/data/steph_225_tree/model_collection_steph_225_tree.mat');

best_model = model_collection.get_best_model;
inferred_model = best_model.inference_model;
vars_N = size(inferred_model.x_train,2);

positions = zeros(vars_N,2);
my_colors= {'deepskyblue', 'lightskyblue1', ...
           'darkseagreen', 'darkolivegreen4', ...
           'darkorange1', 'gold1', 'lemonchiffon'};
colors = {};
for v = 1:vars_N
  variable_names{v} = sprintf('L%dN%d',EXPT_IDS(v), CELL_IDS(v));
  positions(v,:) = ALL_ROIS{EXPT_IDS(v)}(CELL_IDS(v),:);
  colors{v} = my_colors{EXPT_IDS(v)};
end

positions(:,2) = 512 - positions(:,2);


kt_graph_to_dot(inferred_model.structure, 'filename', 'steph_225_tree.dot', ...
             'node_label', variable_names, 'positions', positions'.*2, ...
                'subgraphs', EXPT_IDS, 'colors', colors);

%neato -Tps -n  test_002.dot > test_002.ps; open test_002.ps

for l  =1:7
ii = find(EXPT_IDS==l);
M = inferred_model.structure(ii, ii);
kt_graph_to_dot(M, 'filename', ['steph_225_tree_' num2str(l, '%02d') '.dot'], ...
             'node_label', variable_names(ii), 'positions', positions(ii,:)'.*1, ...
                'subgraphs', EXPT_IDS(ii), 'colors', colors(ii));
end
