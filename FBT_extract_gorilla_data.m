%%%%%%%%%%%%%%%%%
%Giles Story London 2023

%Custom function to extract data from Gorilla and save in subject specific
%structures 'FBT_data'

function []=FBT_extract_gorilla_data
if ispc
    root = 'L:/';
else
    root = '/media/labs/';
end

%Set as needed
rawdatadir=[root 'NPC/DataSink/StimTool_Online/WB_Theory_Of_Mind']; %Directory of raw Gorilla data
%rawdatadir=[root 'rsmith/lab-members/cgoldman/Wellbeing/theory_of_mind/FBT_scripts_giles/RawData']; %Directory of raw Gorilla data

datadir=[root 'rsmith/lab-members/cgoldman/Wellbeing/theory_of_mind/prolific_data_processed'];   %Directory to save formatted data to

%Load data about the ground truth (generative probability) for each trial
%sequence - to store together with other data
load FBT_INPUTS.mat; %Set dir as needed

%Extract image names and store in cell array called imagenames
load names.mat
for set=1:2
    switch set
        case 1             %Neg images
            names=namesneg;
        case 2              %Positive images
            names=namespos;
    end
    for tr=1:size(names,1)
        fnames{tr}=names(tr).name;
    end

    isimage=contains(fnames,'.jpg')|contains(fnames,'.JPG');
    fnames=fnames(isimage);

    imagenames{:,set}=fnames;
end

%Strings for each task in the Gorilla expt - use to identify data files
main_task_ids={'bx2m','te4h','djyu','uo33','zsx3','86l3','2vz2','6xkn','phx7','4lxr'};  

% This to be configured to extract questionnaire data
%quest_ids={'s7wg','1pud','f7i9','1mo3','1nvi','5r9n'}; %BSL95, SR_Zan, IDS, BIS-11, ASRM, debrief/understanding

%Set import options for converting csv to table - which columns to select
%in which format
[opts_main]=setimportopts('main');

%%Extract main task data and save in subject specific struct files
exp=135388; %Experiment id
version=10;
fileid=9072590; %%%%%This number may change depending on the download - please check and adjust as needed

for sequence=1:10
    taskstr=main_task_ids{sequence};
%     try
%        Tmain=readtable([rawdatadir '/data_exp_' num2str(exp) '-v' num2str(version) '_task-' taskstr '-' num2str(fileid)  '.csv'],opts_main);
%        Tmain([1 end],:)=[];  %remove headings
%     catch
%         Tmain=[];
%     end

    directory = dir(rawdatadir);
    index_array = find(arrayfun(@(n) contains(directory(n).name, ['tom_task-' taskstr]),1:numel(directory)));

    for k = 1:length(index_array)
        file_index = index_array(k);
        file = [rawdatadir '/' directory(file_index).name];
        Tmain = readtable(file,opts_main);
        Tmain([1 end],:)=[];  %remove headings
        
        % get prolific ID from file name
        index_start = strfind(file, [taskstr '_'])+length([taskstr '_']);
        trimmed_file = file(index_start:end);
        index_end = regexp(trimmed_file, '_|\.')-1;
        subject = trimmed_file(1:index_end(1));
        
        % skip for subejcts without valid prolific IDs
        if length(subject) ~= 24
            continue;
        end
          
    
    
    

        colnames=["UTC Date","Participant Private ID","Spreadsheet Name","Zone Type","Reaction Time",...
            "Response","Timed Out","display","Cue","scale_left","scale_right","Outcome"];

        if ~isempty(Tmain) %For small numbers of sj some sequences may not have been run

            %Extract main task
            sj_ids_main=rmmissing(Tmain{:,2});
            uniq_sj_ids_main=unique(sj_ids_main);

            for sj_i=1:length(uniq_sj_ids_main)
                FBTdata=[];
                S=[];
                %Identify sj private id
                sj=uniq_sj_ids_main(sj_i);
                sj_j=sj_i;

                if ~isempty(sj_j)  %not excluded
                    %Index of which rows pertain to this subject
                    sj_ind=find(Tmain{:,2}==sj);

                    %Check that sequence numbers match from implied order and
                    %recorded data
                    checksequence=Tmain{2,strcmp(colnames,'Spreadsheet Name')};
                    if ~contains(checksequence,num2str(sequence))
                        error('Sequence numbers do not match for this subject');
                    end

                    %Loop over trials
                    i_struct=0;
                    for i=1:length(sj_ind)
                        tr=sj_ind(i);
                        if contains(Tmain{tr,strcmp(colnames,'display')},'Sampling')
                            %CMG added because rows are for some reason doubled
                            % this prevents adding rows where image is repeated
                            if ~(size(Tmain,1) == tr) % make sure not at last trial
                                if strcmp(Tmain{tr+1,"Outcome"}, Tmain{tr,"Outcome"})
                                    continue;
                                end
                            
                            end
                            
%                             if i_struct>360 %360 sampling trials
%                                 continue
%                             end
                            i_struct = i_struct + 1;
                            if i_struct>360 %360 sampling trials
                                fprintf(['This subject has more than 360 trials: ' subject '\n'])
                                continue
                            end


                            S(i_struct).trial=i_struct;

                            j=strcmp(colnames,'Cue');

                            if contains(Tmain{tr,j}, 'priv')
                                S(i_struct).cue = 1;
                            elseif contains(Tmain{tr, j}, 'shared')
                                S(i_struct).cue = 2;
                            elseif contains(Tmain{tr,j}, 'decoy')
                                S(i_struct).cue = 3;
                            end

                            j=strcmp(colnames,'Outcome');
                            if any(ismember(imagenames{1,1},Tmain{tr, j}))
                                S(i_struct).outcome = 0;
                            elseif any(ismember(imagenames{1,2},Tmain{tr, j})) %Positive image
                                S(i_struct).outcome = 1;
                            else
                                error('Neither a positive nor negative image!')
                            end
                            S(i_struct).probe = nan;
                            S(i_struct).ChosenColour = nan;
                            S(i_struct).ReportedProbability = nan;
                            S(i_struct).ChosenSide = nan;
                            S(i_struct).presses = nan;
                            S(i_struct).time = Tmain{tr, 1};

                            
                            S(i_struct).GroundTruth =  FBT_INPUTS.Pself(sequence,i_struct);
                            S(i_struct).GroundTruthOther =  FBT_INPUTS.Pother(sequence,i_struct);
                            S(i_struct).Score = nan;
                            S(i_struct).TestSite = 'Tulsa';
                        end

                        if contains(Tmain{tr, 'display'}, 'probe')
                            if ~contains(Tmain{tr, strcmp(colnames,'Zone Type')}, 'endValue') %end slider value
                                continue;
                            end
                            

                            j=strcmp(colnames,'display');
                            if contains(Tmain{tr, j}, 'Self probe')
                                S(i_struct).probe = 1;
                            elseif contains(Tmain{tr, j}, 'Other probe')
                                S(i_struct).probe = 2;
                            else
                                S(i_struct).probe = nan;
                            end

                            if contains(Tmain{tr,strcmp(colnames,'scale_left')}, 'happy') 

                                tmp = Tmain{tr,strcmp(colnames,'Response')};
                                S(i_struct).ReportedProbability = 1-tmp/100;

                                if  tmp < 50
                                    S(i_struct).ChosenColour = 1;
                                    S(i_struct).ChosenSide = -1;
                                elseif tmp > 49
                                    S(i_struct).ChosenColour = 0; %choose blue (pink/happy=1 yellow/blue=0)
                                    S(i_struct).ChosenSide = 1;
                                end

                            elseif contains(Tmain{tr,strcmp(colnames,'scale_left')}, 'blue')
                                tmp = Tmain{tr,strcmp(colnames,'Response')};
                                S(i_struct).ReportedProbability = tmp/100;

                                if  tmp < 50
                                    S(i_struct).ChosenColour = 0;
                                    S(i_struct).ChosenSide = -1;
                                elseif tmp > 49
                                    S(i_struct).ChosenColour = 1;
                                    S(i_struct).ChosenSide = 1;
                                end

                            end

                            tmp = Tmain(tr, strcmp(colnames,'Reaction Time'));
                            S(i_struct).reaction_time = tmp{1,1};

                            tmp = Tmain(tr, strcmp(colnames,'Timed Out'));
                            % carter added lines below to write over tmp
                            tmp = Tmain(tr+1, strcmp(colnames,'Timed Out'));
                            if ~isnan(tmp{1,1})
                               % fprintf("Timeout for %s at line %s\n", subject, num2str(tr+1));
                            end

                            S(i_struct).timeout = tmp{1,1};

                        end
                    end

                    FBTdata.seqID = sequence;
                    FBTdata.trials = S;
                    FBTdata.privateID=sj;
                    FBTdata.version=version;
                    FBTdata.sequence=sequence;

                    cd(datadir)
                    save(['Sj_' subject '_' num2str(sj_j)], 'FBTdata')
                    fprintf(['Processed Sequence ' char(string((sequence))) ': ' subject '\n'])
                end
            end
        end

    end
end
end





