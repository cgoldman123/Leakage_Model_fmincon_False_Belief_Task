%Giles Story London 2023

%Script to plot simple summary of model fits - plots model comparison and
%results from the first subject

Figure1=figure;
if ispc
    root = 'L:/';
else
    root = '/media/labs/';
end

%%%Model comparison

%Get model evidence
lambda=[0 1 2];
for model=1:3
    load([root 'rsmith/lab-members/cgoldman/Wellbeing/theory_of_mind/prolific_model_results/test_leakage_params/5-3-2024-1_1_1_' num2str(lambda(model)) '_MAP.mat'])
    LME(model)=sum(R.bf.iL);
end


bf_all=LME(2:3)-LME(1);
bic=2*bf_all';

%Green colour
grass=[0.65490 0.83529 0.4196];

%Plot model evidence
h1=subplot(2,2,1,'Parent',Figure1);
cla(h1)
b=bar(h1,bic); hold on
b(1).FaceColor=grass;
[ngroups,nbars] = size(bic);
xlabel(h1,'\fontsize{14} Model')
set(h1,'xticklabel',{'\lambda_S_e_l_f=\lambda_O_t_h_e_r','\lambda_S_e_l_f, \lambda_O_t_h_e_r'});
ylabel(h1,'\fontsize{14} 2*Log Bayes Factor (Relative to \lambda=0)')
title(h1,'\fontsize{18} Model Comparison')

%%% Data from one subject

sj=3;
%Load model parameters
%load('912024-1  1  1  2_MAP.mat')
load([root 'rsmith/lab-members/cgoldman/Wellbeing/theory_of_mind/prolific_model_results/test_leakage_params/5-3-2024-1_1_1_2_MAP.mat']);

r=R.r;
L_other =  sigmtr(R.E(4,:),-1,1,50)';
L_self =  sigmtr(R.E(5,:),-1,1,50)';

%Extract reported probabilities on probe trials
X=r.subjects(sj);
probe=[X().probe];
RPs=X.RP(probe==1);
RPo=X.RP(probe==2);

%Extract fitted beliefs
eval(['[~,Bs,Bo]=' r.objfun '(r.p,r,sj,0,0,0);']);
Bs=Bs(probe==1);
Bo=Bo(probe==2);

%Index of self and other probe trials
probetrs=probe(probe==1|probe==2);
s_tr=find(probetrs==1);
o_tr=find(probetrs==2);

%Plot
h2=subplot(2,2,[3 4],'Parent',Figure1);
cla(h2)
plot(h2,s_tr,Bs,'--','Color',[0.909 0.364709 0.5450],'LineWidth',1); hold on
plot(h2,s_tr,RPs,'Color',[0.909 0.364709 0.5450],'LineWidth',2); hold on
plot(h2,o_tr,Bo,'--','Color',[0.30196 0.745 0.933],'LineWidth',1); hold on
plot(h2,o_tr,RPo,'Color',[0.30196 0.745 0.933],'LineWidth',2); hold on
xlabel(h2,'\fontsize{12} Probe Trial')
ylabel(h2,'\fontsize{12} Estimated P')
title(h2,['\fontsize{18} \fontsize{14} \rm Subject ' num2str(sj) ' \lambda_S_e_l_f=' sprintf('%.2g',L_self(sj)) ' \lambda_O_t_h_e_r=' sprintf('%.2g',L_other(sj))])
legend('Model Self','Self','Model Other','Other')









