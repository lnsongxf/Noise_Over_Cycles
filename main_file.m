%*************************************************************************%
% Main                                                                    %
%                                                                         %
% NOTE describe variables in dataset        %
%                                                                         %
% last change 6/6/2018                                                    %
%*************************************************************************%

clear
close all

%Data Info
% x_t|t     = first column of variables
% x_t+4|t   = fifth column of variables
% x_t|t-1   = second column of variables previous period
% x_t+4|t-1 = sixth column of variables previous period

filename = 'main_file';
sheet = 'Sheet1';
range = 'B1:CC300';
do_truncation = 0; %Do not truncate data. You will have many NaN 
[dataset, var_names] = read_data2(filename, sheet, range, do_truncation);
dataset = real(dataset);

for i = 1:size(dataset,2)
      eval([var_names{i} '= dataset(:,i);']);
end

%Building Zt
%Step 1 - Getting the forecasted growth rates
Delta_RGDP_t   = log(RGDP5_SPF) - log(RGDP1_SPF);
Delta_RDGP_t1  = log(RGDP6_SPF) - log(RGDP2_SPF);
%Delta_INDPROD_t = log(dataset(:,22)) - log(dataset(:,20));
%Delta_INDPROD_t1 = log(dataset(:,23)) - log(dataset(:,21));
%Investment is the sum between residential and non residential investment
%Delta_RINV_t = log(dataset(:,14) + dataset(:,18)) ...
%     - log(dataset(:,12) + dataset(:,16));
%Delta_RINV_t1 = log(dataset(:,15) + dataset(:,19)) ...
%      - log(dataset(:,13) + dataset(:,17));
%Step 2 - Revision in forecast growth rates
Z1 = Delta_RGDP_t(2:end) - Delta_RDGP_t1(1:end-1);
%Z2 = Delta_INDPROD_t(2:end) - Delta_INDPROD_t1(1:end-1);
%Z3 = Delta_RINV_t(2:end) - Delta_RINV_t1(1:end-1);
threshold = -1/eps;
loc_start = find(Z1 > threshold, 1);
loc_end = find(isnan(MUNI1Y(loc_start+1:end)),1);
loc_end = loc_start + loc_end - 1;
Z1 = Z1(loc_start:loc_end-1);
%Runniong OLS to obtain Ztilde
T              = size(Z1,1);
lag            = 8;
const          = ones(T,1);
X              = zeros(T,6 + 2*lag + 1);
X(:,1)         = const;
X(:,2)         = MUNI1Y(loc_start+1:loc_end); 
X(:,3)         = PDVMILY(loc_start+1:loc_end);
X(:,4)         = HAMILTON3YP(loc_start+1:loc_end);
X(:,5)         = RESID08(loc_start+1:loc_end);
X(:,6)         = TAXNARRATIVE(loc_start+1:loc_end);
for i = 1:2*lag+1
      X(:,6+i) = DTFP_UTIL(loc_start-lag+i:loc_end-lag+i-1);
end

Y                 = Z1;
[B, zhat, Ztilde] = quick_ols(Y,X);

Ztilde_graph = Ztilde + .05;
figure('Position',[100 100 1000 600])
figure(1)
area(Time(loc_start+1:loc_end),NBERDates(loc_start+1:loc_end),'FaceColor',[0.75 0.75 0.75],'EdgeColor','none')
hold on
grid on
plot(Time(loc_start+1:loc_end),Ztilde_graph,'black-','Linewidth',3)
hold off
%xlim([12 252])
ylim([.03 .061])
%legend('NBER recessions','Weight on recession regime F(z)','Location','SouthOutside','Orientation','horizontal')
%legend('boxoff')


%*************************************************************************%
% 2nd stage - Smooth Transition Local Projections                         %
%                                                                         %
%*************************************************************************%
varlist = {'TFP','Real GDP', 'Real Consumption', 'Unemployment Rate'};

lags =6;
H = 20; %irfs horizon

%standardize Ztilde to get one std dev shock
Ztilde = Ztilde/std(Ztilde);
%stlp(y,x,u,fz(-1),lags,H); where y is the dep var, u is the shock, x are the controls

[IR_E_C, IR_R_C, IR_L_C] = stlp(100*RealCons(loc_start+1:loc_end-2),0,Ztilde(1:end-2), ...
       ProbRecession(loc_start:loc_end-1-2),lags,H);

[IR_E_G, IR_R_G, IR_L_G] = stlp(100*RealGDP(loc_start+1:loc_end-2),0,Ztilde(1:end-2), ...
       ProbRecession(loc_start:loc_end-1-2),lags,H);
   
[IR_E_T, IR_R_T, IR_L_T] = stlp(100*DTFP_UTIL(loc_start+1:loc_end-2),0,Ztilde(1:end-2), ...
        ProbRecession(loc_start:loc_end-1-2),lags,H);

[IR_E_U, IR_R_U, IR_L_U] = stlp(UnempRate(loc_start+1:loc_end-2),0,Ztilde(1:end-2), ...
        ProbRecession(loc_start:loc_end-1-2),lags,H);

IR_E = {IR_E_T, IR_E_G,IR_E_C, IR_E_U};
IR_R = {IR_R_T, IR_R_G,IR_R_C, IR_R_U};
IR_L = {IR_L_T, IR_L_G,IR_L_C, IR_L_U};

nvar = length(varlist);
n_row = 2;
n_col = ceil(nvar/n_row);
figure(2)
for j = 1: length(varlist)
    s = subplot(n_row,n_col,j);
    hold on
    if j == 4
        q = plot([1:H]',IR_E{j}, '-r', 'linewidth', 3);
        h = plot([1:H]',IR_R{j}, '--b','linewidth', 3);
        l = plot([1:H]',IR_L{j}, '-ok','linewidth', 3);
        plot([1:H]', 0*[1:H]', ':k');
        set(gca,'TickLabelInterpreter','latex')
        title(varlist{j},'interpreter', 'latex', 'fontsize', 12);
    else
        q = plot([1:H]',cumsum(IR_E{j}), '-r', 'linewidth', 3);
        h = plot([1:H]',cumsum(IR_R{j}), '--b','linewidth', 3);
        l = plot([1:H]',cumsum(IR_L{j}), '-ok','linewidth', 3);
        plot([1:H]', 0*[1:H]', ':k');
        set(gca,'TickLabelInterpreter','latex')
        title(varlist{j},'interpreter', 'latex', 'fontsize', 14);
    end
    if j == 1
        xlabel('Quarter','interpreter','latex','fontsize',12);
        ylabel('\% deviation from s.s.','interpreter','latex','fontsize',12);
    end
    set(s, 'xlim', [1,H], 'ylim', ylim );
end
l=legend([q h l],{'Expansion','Recession','Linear'},'interpreter','latex');
set(l, 'box','on', 'FontSize',13,'Orientation','horizontal','Position',[0.3 0.015 0.40 0.01]);

















