%% About
% This script was created by Dr. Alexa Ruel for educational purposes in the context of the Project Seminar Course at the University of Hamburg and should not be used without direct authorization from Dr. Ruel
% Last updated on: April 24, 2024
% Email Dr. Ruel at alexa.ruel@uni-hambrug.de with any questions, concerns or to request permission to use this script outside the course.

%% 1. Create Grand Average;

cd 'Z:\EPSY\EPSY-Allgemein\Forschung\Pauls Materialien\project course\eeg data'

subjects = [1, 2, 3, 4, 5, 6];

% Preallocate the GrandAverageEEG array for three versions
GrandAverageEEG = nan(length(subjects), 4, 61, 750); %Grandaverage 4D: subjects, conditions, channels, time 

epochtrans2 = {'oddball_common', 'oddball_rare', 'reversal_common', 'reversal_rare'};

for version = 1:3
    version = string(version);
    disp(version)


    for i = 1:length(subjects)
        EEG = pop_loadset([strcat(num2str(subjects(i)), '_09_ICAdone.set')]);

        %% Determine the epoch names
        EpochNames = cell(1, length(EEG.epoch)); % Preallocate cell array

        for c = 1:length(EEG.epoch)
            if EEG.epoch(c).condition == "oddball" && EEG.epoch(c).surprise == "common"
                EpochNames{c} = 'oddball_common';
            elseif EEG.epoch(c).condition == "oddball" && EEG.epoch(c).surprise == "rare"
                EpochNames{c} = 'oddball_rare';
            elseif EEG.epoch(c).condition == "reversal" && EEG.epoch(c).surprise == "common"
                EpochNames{c} = 'reversal_common';
            elseif EEG.epoch(c).condition == "reversal" && EEG.epoch(c).surprise == "rare"
                EpochNames{c} = 'reversal_rare';
            end
        end

        % Display the proportions of each condition
        disp(['Dataset contains ' num2str(sum(strcmpi(EpochNames, 'oddball_common')) / length(EEG.epoch) * 100) ' % stimuli of type oddball_common']);
        disp(['Dataset contains ' num2str(sum(strcmpi(EpochNames, 'oddball_rare')) / length(EEG.epoch) * 100) ' % stimuli of type oddball_rare']);
        disp(['Dataset contains ' num2str(sum(strcmpi(EpochNames, 'reversal_common')) / length(EEG.epoch) * 100) ' % stimuli of type reversal_common']);
        disp(['Dataset contains ' num2str(sum(strcmpi(EpochNames, 'reversal_rare')) / length(EEG.epoch) * 100) ' % stimuli of type reversal_rare']);

        % Find the indices for each condition
        OB_COMMON = find(strcmpi(EpochNames, 'oddball_common'));
        OB_RARE = find(strcmpi(EpochNames, 'oddball_rare'));
        RL_COMMON = find(strcmpi(EpochNames, 'reversal_common'));
        RL_RARE = find(strcmpi(EpochNames, 'reversal_rare'));

        % Sample common trials to match the number of rare trials
        IndOB_COMMON = randsample(OB_COMMON, length(OB_RARE));
        IndRL_COMMON = randsample(RL_COMMON, length(RL_RARE));

        % Ensure all indices are column vectors before concatenating
        IndOB_COMMON = IndOB_COMMON(:);
        IndRL_COMMON = IndRL_COMMON(:);
        OB_RARE = OB_RARE(:);
        RL_RARE = RL_RARE(:);

        % Combine all indices to keep
        indices_to_keep = [IndOB_COMMON; IndRL_COMMON; OB_RARE; RL_RARE];

        % Sort indices (optional)
        indices_to_keep = sort(indices_to_keep);

        % Filter the EEG structure based on the selected indices
        EEG.data = EEG.data(:, :, indices_to_keep);
        EEG.epoch = EEG.epoch(indices_to_keep);
        EEG.event = EEG.event(indices_to_keep);

        % Retag the epochs after filtering
        EpochNames = EpochNames(indices_to_keep);

        for c = 1:length(EEG.epoch)
            if EEG.epoch(c).condition == "oddball" && EEG.epoch(c).surprise == "common"
                EpochNames{c} = 'oddball_common';
            elseif EEG.epoch(c).condition == "oddball" && EEG.epoch(c).surprise == "rare"
                EpochNames{c} = 'oddball_rare';
            elseif EEG.epoch(c).condition == "reversal" && EEG.epoch(c).surprise == "common"
                EpochNames{c} = 'reversal_common';
            elseif EEG.epoch(c).condition == "reversal" && EEG.epoch(c).surprise == "rare"
                EpochNames{c} = 'reversal_rare';
            end
        end

        % Recheck the proportions of each condition
        disp(['Filtered dataset contains ' num2str(sum(strcmpi(EpochNames, 'oddball_common')) / length(EEG.epoch) * 100) ' % stimuli of type oddball_common']);
        disp(['Filtered dataset contains ' num2str(sum(strcmpi(EpochNames, 'oddball_rare')) / length(EEG.epoch) * 100) ' % stimuli of type oddball_rare']);
        disp(['Filtered dataset contains ' num2str(sum(strcmpi(EpochNames, 'reversal_common')) / length(EEG.epoch) * 100) ' % stimuli of type reversal_common']);
        disp(['Filtered dataset contains ' num2str(sum(strcmpi(EpochNames, 'reversal_rare')) / length(EEG.epoch) * 100) ' % stimuli of type reversal_rare']);
       
        for nc = 1:length(epochtrans2)
            n_trials(i, nc) = sum(strcmpi(EpochNames, epochtrans2{nc})); 

            % Save the current subject's data to GrandAverageEEG for the current version
            GrandAverageEEG(i, nc, :, :) = mean(EEG.data(:, :, strcmpi(EpochNames, epochtrans2{nc})), 3);
        end
        path = strcat('Z:\EPSY\EPSY-Allgemein\Forschung\Pauls Materialien\project course\eeg data\GrandaverageVersion', version, '.mat')
        save(path, "GrandAverageEEG");
    end
end

% Now you have GrandAverageEEG with three different versions stored.

%% export trialwise EEG data for behavior - EEG relation analysis





%% 2. Plot Grand Average - with both conditions, and trial types shown

% Run for differnt versions
%GrandAverageEEG = load('Z:\EPSY\EPSY-Allgemein\Forschung\Pauls Materialien\project course\eeg data\GrandaverageVersion1.mat', 'GrandAverageEEG');
%GrandAverageEEG = load('Z:\EPSY\EPSY-Allgemein\Forschung\Pauls Materialien\project course\eeg data\GrandaverageVersion2.mat', 'GrandAverageEEG');
GrandAverageEEG = load('Z:\EPSY\EPSY-Allgemein\Forschung\Pauls Materialien\project course\eeg data\GrandaverageVersion3.mat', 'GrandAverageEEG');

GrandAverageEEG = GrandAverageEEG.GrandAverageEEG  

plot (EEG.times, OB_COMMON,'b', EEG.times, OB_RARE, '--b', EEG.times, RL_COMMON, 'r', EEG.times, RL_RARE, '--r')
title(['EEG at ' EEG.chanlocs(elec).labels])
set(gca, 'YDir')
legend('OB_common', 'OB_rare', 'RL_common', 'RL_rare')
xlabel('time'); ylabel('uV')
xlim([-200 1000]);

saveas(gcf, 'grandaverage_v3.png'); % Save as PNG file



%% Difference Value Plots.
ob_diff = OB_RARE - OB_COMMON ; 
%ob_diff = squeeze(mean(ob_diff,1)); 

rev_diff = REV_RARE - REV_COMMON ; 
%rev_diff = squeeze(mean(rev_diff,1));

common_diff = REV_COMMON - OB_COMMON;
%common_diff = squeeze(mean(common_diff,1));

rare_diff = REV_RARE - OB_RARE; 
%rare_diff = squeeze(mean(rare_diff,1));

% condition difference values
plot (EEG.times, ob_diff, EEG.times, rev_diff)
title(['EEG at ' EEG.chanlocs(elec).labels]) 
set(gca, 'YDir')
legend
xlabel('time'); ylabel('EEG')


% trial type difference values

plot (EEG.times, common_diff, EEG.times, rare_diff)
title(['EEG at ' EEG.chanlocs(elec).labels])
set(gca, 'YDir')
legend
xlabel('time'); ylabel('EEG')


%% 3. Topographies

% ODDBALL COMMON
OB_COMMON_TOPO = GrandAverageEEG(:,1,:,:); 
OB_COMMON_TOPO = squeeze(mean(OB_COMMON_TOPO,1)); % squeezes the 4D matrix into a channels by timepoints matrix. So squeezes across all subjects (means)
OB_COMMON_TOPO = OB_COMMON_TOPO(1:61, 401:451); % 401:451 reflects 300 to 400ms % selects only the time range we are interested in for the topography (window of analysis)

%average the voltages across the channels
OB_COMMON_TOPO = mean(OB_COMMON_TOPO,2);

% change the size of the matrix
OB_COMMON_TOPO = OB_COMMON_TOPO';




% REVERSAL COMMON
REV_COMMON_TOPO = GrandAverageEEG(:,3,:,:);
REV_COMMON_TOPO = squeeze(mean(REV_COMMON_TOPO,1));
REV_COMMON_TOPO = REV_COMMON_TOPO(1:61, 401:451);

%average the voltages across electrodes
REV_COMMON_TOPO = mean(REV_COMMON_TOPO,2);

% change the size of the matrix 
REV_COMMON_TOPO = REV_COMMON_TOPO'; 




% ODDBALL RARE 
OB_RARE_TOPO = GrandAverageEEG(:,2,:,:);
OB_RARE_TOPO = squeeze(mean(OB_RARE_TOPO,1));
OB_RARE_TOPO = OB_RARE_TOPO(1:61, 401:451 );

%average the voltages across channels
OB_RARE_TOPO = mean(OB_RARE_TOPO,2);

% change the size of the matrix 
OB_RARE_TOPO = OB_RARE_TOPO'; 
 



% REVERSAL RARE
REV_RARE_TOPO = GrandAverageEEG(:,4,:,:); 
REV_RARE_TOPO = squeeze(mean(REV_RARE_TOPO,1));
REV_RARE_TOPO = REV_RARE_TOPO(1:61,401:451 );

%average the voltages across channels
REV_RARE_TOPO = mean(REV_RARE_TOPO,2);

% change the size of the matrix
REV_RARE_TOPO = REV_RARE_TOPO'; 


%% Figures for condition differences (oddball vs. reversal)

% differnece between oddball common and oddball rare
ob_diff_topo = OB_RARE_TOPO - OB_COMMON_TOPO; 
% differnece between reversal common and reversal rare
rev_diff_topo = REV_RARE_TOPO - REV_COMMON_TOPO; % p= chp switch ; g = chp steady

figure;
subplot(1,2,1)
elec = EEG.chanlocs(1:61); 
topoplot(ob_diff_topo, elec);
caxis([-3, 3]) 
title('OB rare - OB common')
subplot(1,2,2)
topoplot(rev_diff_topo,elec);
caxis([-3, 3])
title('REV rare - REV common')
sgtitle('Condition differences')

%% Figures for trial type differences (common vs. rare)

% rev common - odd common
common_diff_topo = REV_COMMON_TOPO - OB_COMMON_TOPO;
% rev rare - odd rare
rare_diff_topo = REV_RARE_TOPO - OB_RARE_TOPO;

figure;
subplot(1,2,1)
elec = EEG.chanlocs(1:61); 
topoplot(common_diff_topo, elec);
caxis([-1.5, 1.5])
title('REV common - OB common')
subplot(1,2,2)
topoplot(rare_diff_topo,elec);
caxis([-1.5, 1.5])
title('REV rare - OB rare')
sgtitle('Trial type differences')

%% Figures for condition & trial types (4 individual plots)

% Create a figure
figure;

% Define the electrodes
elec = EEG.chanlocs(1:61);

% Define maximum value for color scaling
max_val = max([abs(OB_COMMON_TOPO(:)); abs(OB_RARE_TOPO(:)); abs(REV_COMMON_TOPO(:)); abs(REV_RARE_TOPO(:))]);

% Subplot 1: Oddball Common
subplot(2, 2, 1);
topoplot(OB_COMMON_TOPO, elec);
title('Oddball Common', 'FontSize', 12);
cbar_handle1 = colorbar('Position', [0.46, 0.58, 0.02, 0.3], 'Limits', [-1, 1] * max_val);
ylabel(cbar_handle1, 'µV', 'FontSize', 10);

% Subplot 2: Oddball Rare
subplot(2, 2, 2);
topoplot(OB_RARE_TOPO, elec);
title('Oddball Rare', 'FontSize', 12);
cbar_handle2 = colorbar('Position', [0.93, 0.58, 0.02, 0.3], 'Limits', [-1, 1] * max_val);
ylabel(cbar_handle2, 'µV', 'FontSize', 10);

% Subplot 3: Reversal Common
subplot(2, 2, 3);
topoplot(REV_COMMON_TOPO, elec);
title('Reversal Common', 'FontSize', 12);
cbar_handle3 = colorbar('Position', [0.46, 0.1, 0.02, 0.3], 'Limits', [-1, 1] * max_val);
ylabel(cbar_handle3, 'µV', 'FontSize', 10);

% Subplot 4: Reversal Rare
subplot(2, 2, 4);
topoplot(REV_RARE_TOPO, elec);
title('Reversal Rare', 'FontSize', 12);
cbar_handle4 = colorbar('Position', [0.93, 0.1, 0.02, 0.3], 'Limits', [-1, 1] * max_val);
ylabel(cbar_handle4, 'µV', 'FontSize', 10);

% Adjust overall figure layout
set(gcf, 'Position', [100, 100, 1000, 800]); % Adjust figure size for better visualization

% Save the figure as a PNG file
saveas(gcf, 'topoplots_v3.png');




