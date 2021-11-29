function [fitresult, gof] = createFit_fondo(xx, yy, II)
%CREATEFIT1(XX,YY,II)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : xx
%      Y Input : yy
%      Z Output: II
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.


[xData, yData, zData] = prepareSurfaceData( xx, yy, II );

% Set up fittype and options.
ft = fittype( 'poly22' );
opts = fitoptions( ft );
opts.Lower = [-Inf -Inf -Inf -Inf -Inf -Inf];
opts.Robust = 'Bisquare';
opts.Upper = [Inf Inf Inf Inf Inf Inf];

% Fit model to data.
[fitresult, gof] = fit( [xData, yData], zData, ft, opts );




