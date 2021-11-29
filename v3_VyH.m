
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
    [H,theta,rho] = hough(BW);
%Otra forma es
%[H,T,R] = hough(BW,'RhoResolution',0.5,'Theta',-90:0.5:89.5);

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
%-------------------------------------------------------------------------
   
%Modelo de regresión e incerteza
%-------------------------------------------------------------------------
    mdlV = LinearModel.fit(1:8, y); 
    figure; plot(mdlV)
 
%Regregresió
    X = [ones(1,8)' (1:8)'];
    [bv, bintv, rv, rintv] = regress(y', X);
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

[BW2,thr2] = edge(J2,'canny',[0.009 0.04],1.4);
    figure; imshow(BW);
%------------------------------------------------------------------------

%Hough transform
%------------------------------------------------------------------------
% BW tiene que ser una imagen binaria, la cuál es por supuesto debido a que antes
% hicimos un canny
    [H2,theta2,rho2] = hough(BW2);
%Otra forma es
%[H,T,R] = hough(BW,'RhoResolution',0.5,'Theta',-90:0.5:89.5);

%Grafico Resultado de la transformada

    figure, imshow(imadjust(mat2gray(H2)),[],'XData',theta2,'YData',rho2,...
            'InitialMagnification','fit');
    xlabel('\theta (degrees)'), ylabel('\rho');
    axis on, axis normal, hold on;
    colormap(hot)
%------------------------------------------------------------------------

%Encontrar los picos en la transormada anterior
%-------------------------------------------------------------------------
    P2 = houghpeaks(H2,8,'threshold',ceil(0.3*max(H2(:))));

%Mostrar picos

    x2 = theta2(P2(:,2));
    y2 = rho2(P2(:,1));
    figure; plot(x2,y2,'s','color','black');
%-------------------------------------------------------------------------

%Distancia entre líneas
%-------------------------------------------------------------------------
    dpacum2 = 0;
    for i = 1:7
        dp2(i) = y2(i) - y2(i+1);
        dpacum2 = dpacum2 + dp2(i);
    end
    
    dispeaks2 = dpacum2/7;
    
    -dispeaks2
%-------------------------------------------------------------------------
   
%Modelo de regresión e incerteza
%-------------------------------------------------------------------------
    mdlV2 = LinearModel.fit(1:8, y2); 
    figure; plot(mdlV2)
 
%Regregresió
    X = [ones(1,8)' (1:8)'];
    [bv2, bintv2, rv2, rintv2] = regress(y2', X);
%Grafico los residuos
    figure; rcoplot(rv2, rintv2)

    incerteza2 = (bintv2(2,2) - bintv2(2,1)) / 2;
    
    incerteza2

%Detección de líneas mediante Houghlines

    lines = houghlines(BW,theta,rho,P,'FillGap',5,'MinLength',7);

%Superponer líneas en imagen original

    figure, imshow(I), hold on
    max_len = 0;
    
    for k = 1:length(lines)
       xy = [lines(k).point1; lines(k).point2];
       plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

       % Plot beginnings and ends of lines
       plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
       plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

       % Determine the endpoints of the longest line segment
       len = norm(lines(k).point1 - lines(k).point2);
       if ( len > max_len)
          max_len = len;
          xy_long = xy;
       end
    end

    % highlight the longest line segment
    figure; plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','red');

