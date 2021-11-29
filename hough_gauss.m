clear all 

NI = 20;%Numero de imagenes a ser 	promediadas.Etiquetadas consecutivamente
	sum_I = 0;
	SumaTotal = 0;
    n = 5; %nº de cortes de gaussianas
	
     
	for i=1:NI
 
       f=['J:\EXP4\ahorario\p39\ima' num2str(i) '.bmp'];
                              
        %bmp ingresa color por canal? o mezcla colores?
 
        rgb_img = imread(f);
 
    	%I = .2989*rgb_img(:,:,1)+.5870*rgb_img(:,:,2) +.1140*rgb_img(:,:,3);
        I = rgb2gray(rgb_img);
        sum_I = sum_I+(double(I)+1);
 
	end
 
	Ip = sum_I/(NI);% Imagen promediadaJ
	%Ipneg = 1-(Ip./255);% imagen negada
    
    [bvu, bhu, Isf]=centercruz_function2(Ip);%obtengo el centro por cada imagen
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% LINEA HORIZONTAL DE LA CRUZ%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 	y = 1:200;
	x = 1:200;
    
    xminh= bvu-230;
    yminh = bhu-100;
    
    Isf_c = imcrop(Isf,[xminh yminh 199 199]);%[xmin ymin width height]% 
    
        	%%%%%%%%%%%%%% Take out BACKGROUND%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [fitfh, goffh] = Fit_fondo_cruz_H(x, y, Isf_c);
%     %figure; surf(xx, yy, II);
%     
    [t1,t2] = meshgrid( x,y);
    promfit = fitfh( t1, t2);
%     %figure; surf(t1, t2, promfit);
% 
    Isf_c = abs(promfit-Isf_c);
%     %figure; imagesc(J2); colormap(gray)
%     %figure; surf(xx, yy, J2);

	      
    for j = 1:n
      cv = squeeze(Isf_c(:,j));
      [fith, gofh] =  Fit_un_paso_Gauss_CRUZ_H(x', cv);
 
      ch = coeffvalues(fith);
      cih = confint(fith, 0.95);
 
      BHH(j) = ch(2); %valor central de la gaussiana para cada corte
      IH(j) = (cih(2,2)-cih(1,2))/2; %incertidumbre para cada corte
    end

    
    %Promedio
    BHHt = sum(BHH)/n + yminh;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%% HOUGH %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    max_h = mean(max(Isf_c));
    
 %     A = (Isf_c > 56);
%     B = (56 >Isf_c & Isf_c >= 52);
%     C = (52 > Isf_c & Isf_c > 42);
%     D = (42 > Isf_c & Isf_c > 30);
%     E = (30 > Isf_c & Isf_c > 16);
%     T = A+B+C+D+E;
   
    
    th1 = 4;
    th2 = 14;
    th3 = 26;
    th4 = 40;
    

    A = (Isf_c > max_h);
    B = (max_h >Isf_c & Isf_c >= max_h-th1);
    C = (max_h-th1 > Isf_c & Isf_c > max_h-th2);
    D = (max_h-th2 > Isf_c & Isf_c > max_h-th3);
    E = (max_h-th3 > Isf_c & Isf_c > max_h-th4);
    T = A+B+C+D+E;
    
%     th1 = 28;
%     th2 = 69;
%     th3 = 110;
%     th4 = 159;
%     th5 = 178;
% 
%     A = (Isf_c > max_h);
%     B = (max_h >Isf_c & Isf_c >= max_h-th1);
%     C = (max_h-th1 > Isf_c & Isf_c > max_h-th2);
%     D = (max_h-th2 > Isf_c & Isf_c > max_h-th3);
%     E = (max_h-th3 > Isf_c & Isf_c > max_h-th4);
%     F = (max_h-th4 > Isf_c & Isf_c > max_h-th5);
%     T = A+B+C+D+E+F;
    
    
    
    %[H,theta,rho] = hough(T,'RhoResolution',1,'Theta',-90:1:89.5);
    [H,theta,rho] = hough(T,'RhoResolution',0.5,'Theta',-90:0.5:89.5);
    [Hfil, Hcol]= find(H >= (0.5*max(max(H))));

    x1 = theta(Hcol(:,1));
    y1 = rho(Hfil(:,1));
    figure; plot(x1,y1,'s','color','blue');

    
    figure, imshow(imadjust(mat2gray(H)),[],'XData',theta,'YData',rho,...
            'InitialMagnification','fit');
    xlabel('\theta (degrees)'), ylabel('\rho');
    axis on, axis normal, hold on;
    colormap(hot)
    
    
    ypos=y1(y1>=0);
    yneg=abs(y1(y1<0));
    
    pos_hough = (mean(ypos)+ mean(yneg))/2 + yminh ;
    
    medh_H= (-(pos_hough))*60/97.3

    
    figure; surf(H)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% LINEA VERTICAL DE LA CRUZ%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

    
    
    xmin= bvu-100;
    ymin = bhu+30;
    II = imcrop(Isf,[xmin ymin 199 199]);%[xmin ymin width height]% 
    %figure; imagesc(III); colormap(gray)% para ver cortes

   
    for j = 1:n
        cv2=squeeze(II(j,:))';
 
        [fitv, gofv] =  Fit_un_paso_Gauss_CRUZ_V(y', cv2);
 
        cV2 = coeffvalues(fitv);
        ciV = confint(fitv, 0.95);
 
        IV(j) = (ciV(2,2)-ciV(1,2))/2;
        BVV(j) = cV2(2);
    end

    BVVt = sum(BVV)/n + xmin;
    
     pos_hough
     BHHt
     dif = BHHt - pos_hough