%Giles Story London 2023
dbstop if error

%Script to fit a set of models to probabilistic false belief task data, with
%options for ML, MAP or mixed effects optimisation

%Set up options as described in FBT_fit.m


doparallel = 0;
options.fit='data';
options.doem=0;
options.doprior_init=1;
options.fitsjs='all';
options.experiment = 'local'; %indicate if local or prolific
if ispc
    root = 'L:/';
    if strcmp(options.experiment,'prolific')
        result_dir = [root 'rsmith/lab-members/cgoldman/Wellbeing/theory_of_mind/prolific_model_results/'];
    else
        result_dir = [root 'rsmith/lab-members/cgoldman/Wellbeing/theory_of_mind/local_model_results/'];
    end

    if strcmp(options.experiment,'prolific')
        subject = 'Sj_66945ed6eccf6e78ece68276'; % Sj_66945ed6eccf6e78ece68276 Sj_53b98f20fdf99b472f4700e4
    else
        subject = 'Sj_12072004';
    end
elseif isunix
    root = '/media/labs/';
    result_dir = getenv('RESULTS');
    subject = getenv('SUBJECT');
end



cd( [root 'rsmith/lab-members/cgoldman/Wellbeing/theory_of_mind/FBT_scripts_CMG/'] );
%Run models with various combinations of parameters
for alpha=[1]
    for beta=1
        for delta=1
            for lambda=[0 1 2]
                model=[alpha beta delta lambda];
                [R] = FBT_fit(model, options,subject,doparallel);
                
                model_parts = strsplit(strtrim(num2str(model)));
                model_string = strjoin(model_parts, '_');
                
                switch options.fit
                    case 'optimum'
                        save([result_dir '/' subject '_' R.r.fittype '-opt'],'R');
                    case 'recovery'
                        save([result_dir '/' subject '_' R.r.fittype '-rec'],'R');
                    case 'data'
                        save([result_dir '/' subject '_' model_string '_' R.r.fittype],'R');
                        saveas(gcf, [result_dir '/' subject '_' model_string '_' R.r.fittype '.png']);
                end
                
                results.subject = subject;
                results.bic = R.bf.bic;
                results.il = R.bf.iL;
                results.fittype = R.r.fittype;
                for a = 1:alpha
                    var = sprintf('posterior_alpha_%d',a);
                    results.(var) = R.E(a);
                end
                for b = 1:beta
                    var = sprintf('posterior_beta_%d',b);
                    results.(var) = R.E(a+b);
                end
                for d = 1:delta
                    var = sprintf('posterior_delta_%d',d);
                    results.(var) = R.E(a+b+d);
                end
                for l = 1:lambda
                    var = sprintf('posterior_lambda_%d',l);
                    results.(var) = R.E(a+b+d+l);
                end
                
                results.corr_true_and_subj_self_prob = R.stats.corr_true_and_subj_self_prob; % correlation between subjective self ratings and true self probability of good outcome since last probe
                results.corr_true_and_subj_other_prob = R.stats.corr_true_and_subj_other_prob; % correlation between subjective other ratings and true other probability of good outcome since last probe
                results.corr_true_other_and_subj_self = R.stats.corr_true_other_and_subj_self; % correlation between the changes in subjective self ratings and the changes in true other probability of good outcome since last probe
                results.corr_true_self_and_subj_other = R.stats.corr_true_self_and_subj_other; % correlation between the changes in subjective other ratings and the changes in true self probability of good outcome since last probe
                results.corr_true_all_and_subj_self = R.stats.corr_true_all_and_subj_self; % correlation between the changes in subjective self ratings and the changes in probability of good outcome since last probe
                results.corr_true_all_and_subj_other = R.stats.corr_true_all_and_subj_other; % correlation between the changes in subjective other ratings and the changes in probability of good outcome since last probe
                writetable(struct2table(results), [result_dir '/' subject '_' model_string  '_fit.csv']);
                close(gcf);
                break;

            end
        end
    end
end


FBT_plotmodelfit


saveas(gcf,[result_dir '/' subject '_fit_plot.png']);

