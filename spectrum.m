%% Spectral density
% Compute and plot spectral density from MA.
% in the near future you may want to compute the spectrum, i.e. consider
% the multivariate case.
function[spect] = spectrum(IRF) 
H      = length(IRF);
Sigma  = 1; % normalization -- CHECK
step   = .05;  % check relation with Canova frequencies 
omega = 0 : step: pi;

for x = 1: size(omega,2)
    for j = 1 : H
        one(:,j) = (IRF(j,:)*exp(-i*(j-1)*omega(1,x)));
        two(:,j) = (IRF(j,:)'*exp(i*(j-1)*omega(1,x))); %transpose is positive
    end
    spect(:,x)= (sum(one,3))*Sigma*(sum(two,3));
    %cross_spectrum1(x,1) = spectrum(2,1,x);
    %cross_spectrum1(x,2) = spectrum(1,2,x);%correggi: va bene perche quando ne fai il trasposto lo transforma in positivo!!%
end
