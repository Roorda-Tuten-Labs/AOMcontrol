%read in Psyfiles from Quest experiments; extend to do so for any sort of
%threshold experiment

% stand_path = 'D:\Video_Folder\10001R\12_1_2011_10_23';
clear all

[path] = uigetdir;

parent_dir = dir(path);

psyfid = fopen([path '\psy_results.txt'], 'a');
file_nm = 'File Name'; est_thresh = 'Final Estimate of Threshold'; est_thresh_sd = 'Threshold Estimate w/Lowest SD';
fprintf(psyfid, '%s\t %s\t %s\t\r\n', file_nm, est_thresh, est_thresh_sd);
fclose(psyfid);

for n = 3:size(parent_dir,1)
    if parent_dir(n).isdir == 1;
        pname = [path '\' parent_dir(n).name];
        
        
        a= dir([pname '\*.psy']);
        name = [pname '\' a.name]; warning off all
        %     [fname, pname] = uigetfile('*.psy', 'Select psyfile', stand_path);
        
        [psyfilename] = textread(name, '%s', 1);
        
        [vidname resp quest_int trial_int quest_mean quest_sd] = textread(name, '%s %d %f %f %f %f', 'headerlines', 15);
        
        final_quest_mean = quest_mean(end);
        
        min_sd = min(quest_sd); [r c] = find(quest_sd == min_sd);
        min_sd_thresh = quest_mean(r);
        psyfid = fopen([path '\psy_results.txt'], 'a');
        fprintf(psyfid, '%s\t %4.4f\t %4.4f\r\n', char(psyfilename), final_quest_mean, min_sd_thresh);
        fclose(psyfid);
    else
    end
end
