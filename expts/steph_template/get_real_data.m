function [data,variable_names] = get_real_data()
load('~/data/steph_225/all_data_90_02.mat');

%data is time_frames by number_of_neurons; it is logical andsparse
%Kate
%data = ALL_DATA' > 0.3;
data = full(data);
N = size(data,2);
variable_names = {};
for i = 1:N
    variable_names(end+1) = {int2str(i)};
end
fprintf('data is : %d, %d\n', size(data,1), size(data,2));
end
