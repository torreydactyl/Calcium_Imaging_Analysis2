%% Combine all cell attached data
%alignment of cells with tadpole #
%1=e12c3
%2=e12c4
%3=e12c6
%4=e13c1
%5=e14c1
%6=e14c2
%7=e14c3
%8=e14c4
%9=e15c1
%10=e15c2
%11=e17c1
%12=e17c2
%13=e18c1
%14=e18c2
%15=e18c4
%16=e25c1
%17=e25c2
%18=e26c1
%19=e26c2
%20=e27t1c1
%21=e27t2c1
%22=e27t2c2
%23=e28c1
%24=e28c2
%25=e28c3
%26=e28c4
%27=e28c5
%28=e28c6
%% combine all data into 1 mat file
myFolder = 'F:/Calcium_Imaging_Analysis/cell_attached_files/Spring2017analysis/bycell_data/'; % May need to correct this.
mkdir([myFolder 'figures']);
if ~isdir(myFolder)
	errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
	uiwait(warndlg(errorMessage));
	return;
end
filePattern = fullfile(myFolder, 'exp*.mat');
matFiles = dir(filePattern)

for k = 1:length(matFiles)
	matFilename = fullfile(myFolder, matFiles(k).name)
	matData = load(matFilename); % Retrieves a structure.
    
	% See if tadpole actually exists in the data structure.
	hasField = isfield(matData, 'tadpole');
	if ~hasField
		% Alert user in popup window.
		warningMessage = sprintf('tadpole is not in %s\n', matFilename);
		uiwait(warndlg(warningMessage));
		% It's not there, so skip the rest of the loop.
		continue; % Go to the next iteration.
	end
	tadpole{1,k} = matData.tadpole % If you get to here, tadpole existed in the file.
end

%% import spike times 
% import from earlier analysis, exps 12-18
% requires AllCells_oldanalysis.mat to be opened first.
for t = 1:15
    tadpole{1,t}.spikeTimes = AllCells(t).spikeTimes
end

% import spike times for exps 25-28
% requires spikeTimesexp25-28.mat to be opened first
tadpole{1,16}.spikeTimes = spikeTimes_e25c1
tadpole{1,17}.spikeTimes = spikeTimes_e25c2
tadpole{1,18}.spikeTimes = spikeTimes_e26c1
tadpole{1,19}.spikeTimes = spikeTimes_e26c2
tadpole{1,20}.spikeTimes = spikeTimes_e27t1c1
tadpole{1,21}.spikeTimes = spikeTimes_e27t2c1
tadpole{1,22}.spikeTimes = spikeTimes_e27t2c1
tadpole{1,23}.spikeTimes = spikeTimes_e28c1
tadpole{1,24}.spikeTimes = spikeTimes_e28c2
tadpole{1,25}.spikeTimes = spikeTimes_e28c3
tadpole{1,26}.spikeTimes = spikeTimes_e28c4
tadpole{1,27}.spikeTimes = spikeTimes_e28c5
tadpole{1,28}.spikeTimes = spikeTimes_e28c6

%% identify each exp in tadpole with matfile name
for t = 1:length(tadpole)
    tadpole{1,t}.matFile = matFiles(t).name
end

%% plot each cell's traces (raw df/f0)

for t = 1:length(tadpole)
    figure;
    hold on
    for i = 1:size(tadpole{1,t}.df_f0,2)
        plot(tadpole{1,t}.df_f0{1,i})
    end
    hold off
    ax=gca;
    xsize = length(tadpole{1,t}.df_f0{1,1});
    ax.XTick = [0, xsize/7, (xsize/7)*2, (xsize/7)*3, (xsize/7)*4, (xsize/7)*5, (xsize/7)*6, (xsize/7)*7];
    ax.XTickLabel = {'0','1', '2', '3', '4', '5', '6', '7'};
    title(sprintf('Patched cell %d all trials', t));
    xlabel('time(s)');
    ylabel('raw \DeltaF/F_{0}');
    fig_filename=sprintf(['F:/Calcium_Imaging_Analysis/cell_attached_files/Spring2017analysis/figures/' 'Alltrials_df_f0_Cell%d.png'], t);
    saveas(gcf,fig_filename,'png');
    close;
    clear('fig_filename')
end

%% Smooth df/f0

for t = 1:length(tadpole)
    for i = 1:size(tadpole{1,t}.df_f0, 1)
        for j = 1:size(tadpole{1,t}.df_f0, 2)
            tadpole{1,t}.filtered{i,j} = smooth(tadpole{1,t}.df_f0{i,j}(:,:), 8, 'moving');
        end
    end
end

%% Plot each cell's traces, smoothed df/f0
for t = 1:length(tadpole)
    figure;
    hold on
    for i = 1:size(tadpole{1,t}.filtered,2)
        plot(tadpole{1,t}.filtered{1,i})
    end
    hold off
    ax=gca;
    xsize = length(tadpole{1,t}.filtered{1,1});
    ax.XTick = [0, xsize/7, (xsize/7)*2, (xsize/7)*3, (xsize/7)*4, (xsize/7)*5, (xsize/7)*6, (xsize/7)*7];
    ax.XTickLabel = {'0','1', '2', '3', '4', '5', '6', '7'};
    title(sprintf('Patched cell %d all trials smoothed', t));
    xlabel('time(s)');
    ylabel('raw \DeltaF/F_{0}');
    fig_filename=sprintf(['F:/Calcium_Imaging_Analysis/cell_attached_files/Spring2017analysis/figures/' 'Alltrials_smoothed_df_f0_Cell%d.png'], t);
    saveas(gcf,fig_filename,'png');
    close;
    clear('fig_filename')
end

%% Begin information extraction from smoothed data
% use regular functions, but on filtered
for t = 1:length(tadpole)
    % Extract parameters for each trial
    [ tadpole{1,t}.area_bytrial_filtered ] = calc_area( tadpole{1,t}.filtered, 42 )
    [ tadpole{1,t}.meanpeak_bytrial_filtered, tadpole{1,t}.peakloc_bytrial_filtered, tadpole{1,t}.meanpeak_bytrial_errors_filtered ] = calc_peak( tadpole{1,t}.filtered )
    [ tadpole{1,t}.meanpeak_bytrial_filtered, tadpole{1,t}.peakloc_bytrial_filtered] = calc_peak( tadpole{1,t}.filtered )

    % Define response/no response
    [ tadpole{1,t}.boolean_response_filtered, tadpole{1,t}.sum_responses_filtered ] = get_respondingROIs( tadpole{1,t}.area_bytrial_filtered, tadpole{1,t}.meanpeak_bytrial_filtered, tadpole{1,t}.peakloc_bytrial_filtered )

    % define stim mask by stim type
    [ tadpole{1,t}.stimmask_filtered ] = get_stimmask( tadpole{1,t}.stimorder );
    %tadpole.unique_stims = unique(tadpole.stimorder);

    % Find average area, peak and peakloc for each ROI for each stim type
    [ tadpole{1,t}.area_avg_filtered ] = mean_by_stimtype ( tadpole{1,t}.area_bytrial_filtered, tadpole{1,t}.stimmask_filtered )
    [ tadpole{1,t}.peak_avg_filtered ] = mean_by_stimtype ( tadpole{1,t}.meanpeak_bytrial_filtered, tadpole{1,t}.stimmask_filtered )
    [ tadpole{1,t}.peakloc_avg_filtered ] = mean_by_stimtype ( tadpole{1,t}.peakloc_bytrial_filtered, tadpole{1,t}.stimmask_filtered )
end

%% convert spikeTimes in seconds to frame numbers
% 160 frames in 7 sec

for t = 1:length(tadpole)
    for i = 1:length(tadpole{1,t}.spikeTimes)
        tadpole{1,t}.spikeFrames{1,i} = floor(tadpole{1,t}.spikeTimes{1,i} * (160/7));
    end
end

%% get spike count for each trial
for t = 1:length(tadpole)
    for i = 1:length(tadpole{1,t}.spikeTimes)
        tadpole{1,t}.spikeCount{1,i} = length(tadpole{1,t}.spikeTimes{1,i});
    end
end

%% Plot cell 16
figure;
plot(cell2mat(tadpole{1,16}.spikeCount), cell2mat(tadpole{1,16}.meanpeak_bytrial_filtered(1,:)), '*')

%% Plot peak vs spike count for all data
figure;
hold on
for t = 1:length(tadpole)
    lsp = length(cell2mat(tadpole{1,t}.spikeCount));
    lpk = length(tadpole{1,t}.meanpeak_bytrial_filtered(1,:));
    if lsp ~= lpk 
        spikeCt = [cell2mat(tadpole{1,t}.spikeCount) zeros(1,abs((lsp-lpk)))];
    else
        spikeCt = cell2mat(tadpole{1,t}.spikeCount);
    end
    plot(spikeCt, cell2mat(tadpole{1,t}.meanpeak_bytrial_filtered(1,:)), '*')
end
hold off

%% Find trials with early spikes (during baseline)
% earlySpike (before frame 42/1.8 sec) has 1, no early spike has 0.
for t=1:length(tadpole)
    for i = 1:length(tadpole{1,t}.spikeFrames)
        if tadpole{1,t}.spikeFrames{1,i} > 42
            tadpole{1,t}.earlySpikes(1,i) = 0;
        elseif isempty(tadpole{1,t}.spikeFrames{1,i})
            tadpole{1,t}.earlySpikes(1,i) = 0;
        else
            tadpole{1,t}.earlySpikes(1,i) = 1;
        end
    end
end

%% Create a new data structure with every trial separated
% fields t, spikeCt, spikeFrames, earlySpikes, smoothed trace
counter = 1
for t = 1:length(tadpole)
    for i = 1:length(tadpole{1,t}.spikeCount)
        CellsAll(counter).cellnum = t;
        CellsAll(counter).trialnum = i;
        CellsAll(counter).earlySpikes = tadpole{1,t}.earlySpikes(1,i);
        CellsAll(counter).spikeCount = cell2mat(tadpole{1,t}.spikeCount(1,i));
        CellsAll(counter).spikeFrames = cell2mat(tadpole{1,t}.spikeFrames(1,i));
        CellsAll(counter).trace = tadpole{1,t}.filtered{1,i};
        CellsAll(counter).tracker = [tadpole{1,t}.expnum tadpole{1,t}.cellid];
        counter = counter + 1
    end
end

%% Spike triggered average
% What spike counts do I have traces for?
uniquespikecount = unique([CellsAll.spikeCount])

% how many traces do I have for each spike Count?
for i = 1:length(uniquespikecount)
    numTraces(i) = sum([CellsAll.spikeCount] == uniquespikecount(i));
end

% Based on numTraces, only have enough data for grouped traces for 0-8
% spikes. 

% plot all traces for a given spike count (not adjusted for spike time)
for i = 1:9
    figure;
    count = i-1
    idxs = find([CellsAll.spikeCount] == count)
    hold on
    for j = 1:length(idxs)
        plot(CellsAll(idxs(j)).trace)
    end
    hold off
    ax=gca;
    xsize = length(tadpole{1,t}.df_f0{1,1});
    ax.XTick = [0, xsize/7, (xsize/7)*2, (xsize/7)*3, (xsize/7)*4, (xsize/7)*5, (xsize/7)*6, (xsize/7)*7];
    ax.XTickLabel = {'0','1', '2', '3', '4', '5', '6', '7'};
    title(sprintf('All trials All cells with %d spikes', count));
    xlabel('time(s)');
    ylabel('smoothed \DeltaF/F_{0}');
    fig_filename=sprintf(['F:/Calcium_Imaging_Analysis/cell_attached_files/Spring2017analysis/figures/' 'Alltrials_smoothed_df_f0_%dspikes.png'], count);
    saveas(gcf,fig_filename,'png');
    %close;
    clear('fig_filename')
end

% mean and standard deviation for 0 spikes
idxs = find([CellsAll.spikeCount] == 0)
traces_0spikes = []
for i = 1:length(idxs)
    traces_0spikes = [traces_0spikes CellsAll(idxs(i)).trace(1:159,1)]
end
avg_0spikes = mean(traces_0spikes,2)
stdev_0spikes = std(traces_0spikes')

%plot mean with std for 0 spikes
figure;
hold on
plot(avg_0spikes, 'k')
plot((avg_0spikes' + stdev_0spikes), 'b')
plot((avg_0spikes' - stdev_0spikes), 'r')
hold off
ax=gca;
xsize = length(avg_0spikes);
ax.XTick = [0, xsize/7, (xsize/7)*2, (xsize/7)*3, (xsize/7)*4, (xsize/7)*5, (xsize/7)*6, (xsize/7)*7];
ax.XTickLabel = {'0','1', '2', '3', '4', '5', '6', '7'};
title('Mean and SD of all traces with 0 spikes');
xlabel('time(s)');
ylabel('smoothed \DeltaF/F_{0}');
fig_filename=sprintf(['F:/Calcium_Imaging_Analysis/cell_attached_files/Spring2017analysis/figures/' 'Mean_and_SD_smoothed_df_f0_%dspikes.png'], 0);
saveas(gcf,fig_filename,'png');
%close;
clear('fig_filename')

%% Plot based on time of first spike

for i = 2:9
   
    count = i-1
    idxs = find([CellsAll.spikeCount] == count)
    for k = 1:length(idxs)
        if CellsAll(idxs(k)).spikeFrames(1,1) > 95 || CellsAll(idxs(k)).spikeFrames(1,1) < 30
            idxs(k) = 0
        end
    end
            
    figure;
    hold on
    for j = 1:length(idxs)
        if idxs(j) ~= 0 
            start = CellsAll(idxs(j)).spikeFrames(1,1)
            plot(CellsAll(idxs(j)).trace((start-30):(start+60), 1))
        end
    end
    plot(31, 0, 'r*')
    hold off
    title(sprintf('Spike Triggered average of traces with %d spikes', i));
    ax=gca;
    xsize = 90;
    ax.XTick = [0, xsize/3.94, (xsize/3.94)*2, (xsize/3.94)*3, (xsize/3.94)*4] %, (xsize/7)*5, (xsize/7)*6, (xsize/7)*7];
    ax.XTickLabel = {'0','1', '2', '3', '4'}; %, '5', '6', '7'};
    ylabel('smoothed \DeltaF/F_{0}');
    xlabel('time(s)');
    fig_filename=sprintf(['F:/Calcium_Imaging_Analysis/cell_attached_files/Spring2017analysis/figures/' 'Spike_triggered_avg_smoothed_df_f0_%dspikes.png'], i);
    saveas(gcf,fig_filename,'png');
    close;
    clear('fig_filename')
end
% looks ok, but need to find and eliminate problem traces. 
% problem: they all look pretty similar in size.
% useful note: looks like peak of Ca signal coincides with spike time



    