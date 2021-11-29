
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
    [BW,thr] = edge(J,'canny',[0.009 0.04],1.4);
    figure; imshow(BW);
%------------------------------------------------------------------------

%Hough transform
%------------------------------------------------------------------------
% BW tiene que ser una imagen binaria, la cuál es por supuesto debido a que antes
% hicimos un canny
    %[H,theta,rho] = hough(BW);
%Otra forma es
   [H,theta,rho] = hough(BW,'RhoResolution',0.1,'Theta',-90:0.5:89.5);

%Grafico Resultado de la transformada

    figure, imshow(imadjust(mat2gray(H)),[],'XData',theta,'YData',rho,...
            'InitialMagnification','fit');
    xlabel('\theta (degrees)'), ylabel('\rho');
    axis on, axis normal, hold on;
    colormap(hot)
%------------------------------------------------------------------------

%Encontrar los picos en la transformada anterior
%-------------------------------------------------------------------------
    [Hfil, Hcol]= find(H >= (0.8*max(max(H))));
    %P = houghpeaks(H,16,'threshold',ceil(0.3*max(H(:))));

%Mostrar picos

    x = theta(Hcol(:,1));
    y = rho(Hfil(:,1));
    figure; plot(x,y,'s','color','black');
%-------------------------------------------------------------------------

%Distancia entre líneas
%-------------------------------------------------------------------------
    dpacum = 0;
    k=0;
    for i = 1:8
        pc(i) = ((y(i+k) + y(i+1+k))/2);
        k= k + 1;
        
    end
    
    for i = 1:7
        dp(i) = pc(i) - pc(i+1);
        dpacum = dpacum + dp(i);
    end
    
    dispeaks = dpacum/7;
    
    -dispeaks
%-------------------------------------------------------------------------
   
%Modelo de regresión e incerteza
%-------------------------------------------------------------------------
    mdlV = LinearModel.fit(1:8, pc); 
    figure; plot(mdlV)
 
%Regregresió
    X = [ones(1,8)' (1:8)'];
    [bv, bintv, rv, rintv] = regress(pc', X);
%Grafico los residuos
    figure; rcoplot(rv, rintv)

    incerteza = (bintv(2,2) - bintv(2,1)) / 2;
    
    incerteza

%-------------------------------------------------------------------------
yy2= 1:750;
xx2= 1:40;

III= I(303+yy2, 690+xx2);
figure; imagesc(III); colormap(gray)

%Fución del fondo.
[fitresult2, gof2] = Fit_fondo_V(xx2, yy2, III);

%Para ver superficie completa con fondo y con los picos gaussianos
figure; surf(xx2, yy2, III);

%Función del fondo
[t_1, t_2]= meshgrid(xx2, yy2);
promfit2= fitresult2(t_1, t_2);
figure; surf(t_1,t_2, promfit2);

%Resto el fondo
J2= abs(promfit2 - III);
figure; imagesc(J2); colormap(gray)

%Figura en 3D sin fondo
figure; surf(t_1, t_2, J2);

%Tomamos una sección de la 3D
cv_2= squeeze( J2(:, 20));

figure; plot(yy2, cv_2, 'b', 'LineWidth', 2); hold on
legend('cv_2')

%Se busca un fiteo en la zona
%--------------------------------------------------------------------------------
%fitresult entrega los coeficientes que arman la función de fiteo para el fondo.
%La función siguiente es creada mediante "cftool" la herramienta de fitting
%de matlab.
%Fitting del corte
[fitv, gofv] = Fit_8gauss_V(yy2', cv_2);%Nuevo

% Plot fit with data.
[xDatav, yDatav] = prepareCurveData( yy2', cv_2 );
figure; plot(fitv,xDatav, yDatav)
legend('vertical fit', 'least square fit full parameters', 'Location', 'NorthEast' );
% Label axes
xlabel( 'yy2' );
ylabel( 'cv_2' );
grid on
%-------------------------------------------------------------------------------------

[BW2,thr2] = edge(J2,'sobel');

    figure; imshow(BW2);
%------------------------------------------------------------------------

%Hough transform
%------------------------------------------------------------------------
% BW tiene que ser una imagen binaria, la cuál es por supuesto debido a que antes
% hicimos un canny
    
    [H2,theta2,rho2] = hough(BW2,'RhoResolution',0.1,'Theta',-90:0.5:89.5);


%Grafico Resultado de la transformada

    figure, imshow(imadjust(mat2gray(H2)),[],'XData',theta2,'YData',rho2,...
            'InitialMagnification','fit');
    xlabel('\theta (degrees)'), ylabel('\rho');
    axis on, axis normal, hold on;
    colormap(hot)
%------------------------------------------------------------------------

%Encontrar los picos en la transormada anterior
%-------------------------------------------------------------------------
[Hfilv, Hcolv]= find(H2 >= (0.8*max(max(H2))));
    
%Mostrar picos

    x2 = theta2(Hcolv(:,1));
    y2 = rho2(Hfilv(:,1));
    figure; plot(x2,y2,'s','color','black');
%-------------------------------------------------------------------------

%Distancia entre líneas
%-------------------------------------------------------------------------
    dpacum2 = 0;
    k=0;
    for i = 1:8
        pcv(i) = -((y2(i+k) + y2(i+1+k))/2);
        k= k + 1;
        
    end
    
    pcv=sort(pcv);
    
    for i = 1:7
        dpv(i) = pcv(i) - pcv(i+1);
        dpacum2 = dpacum2 + dpv(i);
    end
    
    dispeaksv = dpacum2/7;
    
    -dispeaksv
    
   
%Modelo de regresión e incerteza
%-------------------------------------------------------------------------
    mdlV2 = LinearModel.fit(1:8, pcv); 
    figure; plot(mdlV2)
 
%Regregresió
    X = [ones(1,8)' (1:8)'];
    [bv2, bintv2, rv2, rintv2] = regress(pcv', X);
%Grafico los residuos
    figure; rcoplot(rv2, rintv2)

    incerteza2 = (bintv2(2,2) - bintv2(2,1)) / 2;
    
    incerteza2


