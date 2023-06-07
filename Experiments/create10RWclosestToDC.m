function [speedTestStim_vector, true_diffusionConstants, rwpaths_given_trueDCs, xColumn, yColumn] = ...
    create10RWclosestToDC(aosloFPS, stimulus_duration, endFrame, rootFolder, fileName, maxDifCon)
%  
% Creates 10 random walk paths closest to the desired DC
%    -- converts the maxDifCon into speedTestStimMax --> makes vector in increments of 0.05 up to speedTestStimMax
%    -- for each speedTestStim, generate 100 RW's  
%    -- then calculate DC for each RW
%    -- then select 10 RW's that are closest to the trueDC (closest to the DC that Quest wants you to use)

%    --To calculate diffusion constant:   
%         1) DiffusionConstant = 2 *aosloFPS* (speedTestSTim)^2
%            everything in terms of the diffusion constant pixels^2 per second (not arcmin, be careful!)
%   -----------------------------------
%   Input
%   ----------------------------------- 
%   aosloFPS                : 30 frames/second default
%   stimulus_duration       : stimulus duration in seconds, (ie 1.5 default)
%   endFrame                : stimulus duration in frames, (ie 46 default)
%   rootFolder              : folder to save the .mat file to
%   fileName                : video folder name
%   maxDifCon               : this is the maximum DifCon, so we will make
%                             the speedTestStims in increments of 0.05 up to the max

%   -----------------------------------
%   Output
%   -----------------------------------
%   speedTestStim_vector    : all speedTestStims
%   true_diffusionConstants : these are calculated based off the speedTestStim_vector
%   rwpaths_given_trueDCs   : all the 10 RWs corresponding to each of the 'true_diffusionConstants', indexed the same


% Josie D'Angelo December 3, 2022
    %always start random walks at index 1 since it'll be inputed to the correct video frames later,
    startFrame = 1;
    xColumn = 1; %for the RW paths
    yColumn = 2; %for the RW paths
    
    %setting up a .mat file to save RW's in
    rwdataFile = [rootFolder filesep fileName '_rw10Paths_for_correspondingDC.mat'];

    %set up speedTestStim
    speedTestStimMax = sqrt((maxDifCon/(2*aosloFPS)));
%     pieces = 20*speedTestStimMax; %so that it goes in increments of 0.05
    pieces = 10*speedTestStimMax; %so that it goes in increments of 0.1
    speedTestStim_vector = linspace(0,speedTestStimMax, pieces+ 1);

    %number of goodRW's to keep per DC/speedTestStim
    num_good_rws_per_dc = 10;

    %for each speedTestStim I'll generate 100 RW to choose from
    sessions = 100;

    %setting up struct that will hold all rwPaths for all dcs
    rwpaths_given_trueDCs=struct;

    %these are the true DC's for each corresponding speedTestStim [pixel^2/sec] to compare to each 100 RW's 
    true_diffusionConstants = nan(size(speedTestStim_vector));

    for k = 1 : length(speedTestStim_vector)

        %true difCon for speedTestStim of interest
        [true_dc] = speedteststimToDC(speedTestStim_vector(1,k), aosloFPS);
        true_diffusionConstants(1,k) = true_dc;

        %setting up vector to hold 100 RW's for each speedTestStim
        rw_position_x_y = nan(endFrame,2,sessions);
        rw_position_x_y(1,:,:) = 0;

        for sess = 1: sessions
            for i = 1 : (endFrame-startFrame)
                [shift_x] = createRW(speedTestStim_vector(1,k));
                rw_position_x_y(startFrame + i, 1, sess) = rw_position_x_y(startFrame+i-1, xColumn, sess)+shift_x;
                [shift_y] = createRW(speedTestStim_vector(1,k));
                rw_position_x_y(startFrame + i, 2, sess) = rw_position_x_y(startFrame+i-1, yColumn, sess)+shift_y;
            end
        end

        % Now that we have 100 random walks, calculate the msd/time_interval for each RW

        %setting up vector to hold 100 DC/speedTestStim
        calculatedDC_from_allRW = nan(2,sessions);
        calculatedDC_from_allRW(1,:) = (1:100); %keeps track of RW index number

        numberOfdeltaT = floor(endFrame/4); %# for MSD, dt should be up to 1/4 of number of data points-- from this paper https://www.ncbi.nlm.nih.gov/pmc/articles/PMC1184368/pdf/biophysj00037-0260.pdf
        all_msd = nan(numberOfdeltaT,5,sessions);

        for i = 1:sessions
            data = rw_position_x_y(:,:, i);
            msd = nan(numberOfdeltaT,5); % store [mean, std, n, timelag(frames), timelag(seconds)]

            %# calculate msd for all deltaT's, modified from https://stackoverflow.com/questions/7489048/calculating-mean-squared-displacement-msd-with-matlab

            for dt = 1:numberOfdeltaT
                deltaCoords = data(1+dt:end,1:2) - data(1:end-dt,1:2);
                squaredDisplacement = sum(deltaCoords.^2,2); %# a^2+b^2 .Units are pixels^2

                msd(dt,1) = mean(squaredDisplacement); %# average
                msd(dt,2) = std(squaredDisplacement); %# std
                msd(dt,3) = length(squaredDisplacement); %# n
                msd(dt,4) = dt; %deltaT timelag #frames
                msd(dt,5) = stimulus_duration/endFrame*dt; % detlaT in seconds (converting from frames to seconds) since 1.5 seconds/46 frames
            end

            all_msd(:,:,i) = msd;
            DC = polyfit(all_msd(:,5,i),all_msd(:,1,i),1); %(x,y,n) In general, for n points, you can fit a polynomial of degree n-1 to exactly pass through the points.
            calculatedDC_from_allRW(2,i) = DC(1);

    %         figure;
    %         errorbar(all_msd(:,5,i), all_msd(:,1,i),all_msd(:,2,i), 'o');
    %         xlabel('time interval (s)')
    %         ylabel('mean square displacement (arcmin^2)')
    %         hold on
    %         yline = DC(1)*all_msd(:,5,i)+DC(2);
    %         plot(all_msd(:,5,i),yline,'r-');
    %         title(['SpeedTestStim ', num2str(speedTestStim_vector(1,k)), ' average MSD for ', num2str(sessions), ' RWs'])
    %         set(gca,'xlim',[0 max(all_msd(:,5,i))+min(all_msd(:,5,i))])
    %         %set(gca,'ylim',[0 12])
        end

        % finds RWs with DC's closest to the true DC for that speedtestStim

        %setting up vector to hold 10 good RW's for corresponding DC/speedTestStim
        x_y_RWgood_correspondingDC = nan(endFrame,2,num_good_rws_per_dc);

        data_of_interest = calculatedDC_from_allRW;
        rw_paths_indexes = nan(1,num_good_rws_per_dc);
        for rw = 1 : num_good_rws_per_dc
            [~, index] = min(abs(data_of_interest(2,:) - true_diffusionConstants(1,k)));
            rw_paths_indexes(rw) = index;

            x_y_RWgood_correspondingDC(:,:,rw) = rw_position_x_y(:,:,index);

            data_of_interest(2,index) = 20000000; %removing this index
        end

        %updating the struct
        rwpaths_given_trueDCs.(sprintf('dcIndex%d',k))= x_y_RWgood_correspondingDC;

    end
    save(rwdataFile, 'speedTestStim_vector','true_diffusionConstants','rwpaths_given_trueDCs');

%% Functions 1)get x/y pixel shifts for RW and 2)convert speedTestStim to it's true Diffusion Constant

    function [shift_x_or_y] = createRW(speedTestStim_of_interest)
            shift_x_or_y = speedTestStim_of_interest*randn; %removed round to the nearest pixel (can't have non-integer pixels), will do that in experiment since 60hz has to divide by 1/2 first, then round 2/22/23
    end

    function [dc] = speedteststimToDC(speedTestStim, aosloFPS)
        dc = (2*aosloFPS)*(speedTestStim).^2; %to make linear, not exponential DC = 2*(framert)*x^2 
    end
end