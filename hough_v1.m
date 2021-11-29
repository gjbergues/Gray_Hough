
NI = 100; 
sum_I = 0;

%Sumo todas la imágenes de la retícula para luego promediarlas
    for i = 1:NI

        f = ['I:\datos_paper_pattern\Exp 2\ret\ima' num2str(i) '.bmp'];
        rgb = imread(f);
        I = rgb2gray(rgb);
        sum_I = sum_I + (double(I) + 1);
    end

%Imagen promedio en I_new
    I = sum_I / NI;
    I = imcomplement(I);
   
%Elijo un sector de imagen que encierre 8 líneas para hacer procesamiento
%------------------------------------------------------------------------
    yy = 1:40;
    xx = 1:750;

    II = I(640+yy, 440+xx); 

%Fitting del fondo y restado del mismo a la imagen original
%------------------------------------------------------------------------
    [xData, yData, zData] = prepareSurfaceData( xx, yy, II );

% Set up fittype and options.
    ft = fittype( 'poly22' );
    opts = fitoptions( ft );
    opts.Lower = [-Inf -Inf -Inf -Inf -Inf -Inf];
    opts.Robust = 'Bisquare';
    opts.Upper = [Inf Inf Inf Inf Inf Inf];

% Fit model to data.
    [fitresult, gof] = fit( [xData, yData], zData, ft, opts );

    [t1,t2] = meshgrid(xx, yy);
    promfit = fitresult(t1, t2);% Si corro fitresult en función de las variables independientes obtengo el fondo

%Resto el fondo y grafico la imagen final. Es necesario usar "abs" para que
%los picos no queden al revés.
    J= abs(promfit - II);
%------------------------------------------------------------------------

%Canny
%------------------------------------------------------------------------
    [BW, thr] = edge(J,'sobel');
    %[BW,thr] = edge(J,'canny',[0.009 0.04],1.4);
    figure; imshow(BW);
%------------------------------------------------------------------------

%Hough transform
%------------------------------------------------------------------------
% BW tiene que ser una imagen binaria, la cuál es por supuesto debido a que antes
% hicimos un canny
    %[H,theta,rho] = hough(BW);
%Otra forma es
[H, theta, rho] = hough(BW, 'RhoResolution', 0.02, 'Theta', -90:0.05:89.5);

%Grafico Resultado de la transformada

    figure, imshow(imadjust(mat2gray(H)),[],'XData',theta,'YData',rho,...
            'InitialMagnification','fit');
    xlabel('\theta (degrees)'), ylabel('\rho');
    axis on, axis normal, hold on;
    colormap(hot)
%------------------------------------------------------------------------

%Encontrar los picos en la transormada anterior
%-------------------------------------------------------------------------
    P = houghpeaks(H,8,'threshold',ceil(0.3*max(H(:))));

%Mostrar picos

    x = theta(P(:,2));
    y = rho(P(:,1));
    figure; plot(x,y,'s','color','black');
%-------------------------------------------------------------------------

%Distancia entre líneas
%-------------------------------------------------------------------------
    dpacum = 0;
    for i = 1:7
        dp(i) = y(i) - y(i+1);
        dpacum = dpacum + dp(i);
    end
    
    dispeaks = dpacum/7;
    
    -dispeaks