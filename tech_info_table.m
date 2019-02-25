fprintf('\n')
fprintf('\n')
disp('------------------------------------------------')
disp('           Technical Parameters LP              ')
disp('------------------------------------------------')
fprintf('\n')
if strcmp(which_Z,'1') == 1
      disp('Survey                     SPF Real GDP Growth')
elseif strcmp(which_Z,'2') == 1
      disp('Survey                     SPF Nominal GDP Growth')
elseif strcmp(which_Z,'3') == 1
      disp('Survey                     SPF Real Consumption Growth')
elseif strcmp(which_Z,'4') == 1
      disp('Survey                     SPF Industrial Production Growth')
elseif strcmp(which_Z,'5') == 1
      disp('Survey                     SPF Real Total Investment Growth')
elseif strcmp(which_Z,'6') == 1
      disp('Survey                     SPF Consumer Price Index')
elseif strcmp(which_Z,'7') == 1
      disp('Survey                     Michigan Index Confidence')
end
disp(['Number of lags 1st Step    ',num2str(lags)])
disp(['Number of leads            ',num2str(leads)])
disp(['Number of lags in LP       ',num2str(lags_LP)])
disp(['Trend                      ',which_trend])
disp(['IRFs horizon               ',num2str(H)])
disp(['Number of PCs 1st Step     ',num2str(nPC_first)])
disp(['Number of PCs in LP        ',num2str(nPC_LP)])
disp(['Number of simulations      ',num2str(nsimul)])
if diff_LP == 1
      disp('Other                      Dependent Variables are differentiated')
else
      disp('Other                      Dependent Variables are in levels')
end
fprintf('\n')
disp('------------------------------------------------')
fprintf('\n')
for ishock = 1:length(which_shock)
      disp([which_shock{ishock}])
      fprintf('\n')
      for ii = 1:length(varlist)
            disp(['  - Degree of freedom for ',varlist{ii},' are on average: ',num2str(floor(mean(DFkk(ii,:,ishock))))])
      end
      fprintf('\n')
end
