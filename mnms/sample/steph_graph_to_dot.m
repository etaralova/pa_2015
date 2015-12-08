if(isempty(which('LoopyModelCollection')))
  addpath(genpath('~/src/crf/fwMatch'));
  exptPath = pwd;
  cd('~/src/crf/fwMatch');
  startup;
  cd(exptPath);
end
dbclear all;


if(isempty(who('PATH')))
  %warning('SET PATH!!!!!');
  PATH = '~/data/steph_225_tree/';
end

if(isempty(who('DEPTH_ID')))
  warning('SET DEPTH_ID!!!!!');
  DEPTH_ID = input('DEPTH_ID = ');
end

if(isempty(who('ORIENT')))
  warning('SET ORIENT!!!!!');
  ORIENT = input('ORIENT = ');
end

if(DEPTH_ID > 0)
  EXPT = ['steph_' num2str(ORIENT) '_' num2str(DEPTH_ID,'%02d') '_tree'];
else
  EXPT = ['steph_' num2str(ORIENT) '_tree'];  
end

%for E = {'002_h', '002_v', '002_l', '002_r', '002_i'}
%EXPT = E{1};

load([PATH '/model_collection_' EXPT '.mat']);

best_model = model_collection.get_best_model;
model = best_model.inference_model;
vars_N = size(model.x_train,2);
clear model_collection best_model;

load('~/data/CAM/steph_all_rois.mat');
load('~/data/CAM/steph_all_rois_img.mat');

E_IMG = cell(1,7);

if(DEPTH_ID < 0)
  DEPTHS = 1:7;
else
  DEPTHS = DEPTH_ID;
end

for d = DEPTHS
  ROIs = ROIS_IMG{d};
  %E_IMG{d} = zeros(size(ROIs));

  vars_in_depth = find(DEPTH_LABELS == d);
  vars_N = length(vars_in_depth);
  positions = [];
  positions(:,1) = ALL_ROIS{d}(1:vars_N,1);
  positions(:,2) = size(ROIs,2)-ALL_ROIS{d}(1:vars_N,2);
  variable_names = {};
  structure = model.structure(vars_in_depth, vars_in_depth);
  for n = 1:vars_N
    %ii = find(ROIs == n);
    %temp = zeros(size(ROIs));
    %temp(ALL_ROIS{d}(n,1), size(ROIs,2)-ALL_ROIS{d}(n,2)) = 1;
    variable_names{n} = sprintf('%03d', n);
    %temp = bwmorph(temp, 'dilate', 12);
    %temp = imdilate(temp, strel('disk',10));
    %ii = find(temp);
    %figure(11); imagesc(temp); pause(0.5);
    %E_IMG{d}(ii) = n;
  end
  
  kt_graph_to_dot(structure, 'filename', [EXPT '.dot'], ...
                  'node_label', variable_names, 'positions', positions');

end

return

%neato -Tps -n  test_002.dot > test_002.ps; open test_002.ps
