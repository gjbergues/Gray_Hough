%horario=0;
%antihorio=1;

function  [BVVt,BHHt,IV,IH]=analisis_cruz_for_automatic(k,h)

    NI = 20;%Numero de imagenes a ser 	promediadas.Etiquetadas consecutivamente
	sum_I = 0;
	SumaTotal = 0;
    n = 5; %nº de cortes de gaussianas
	
    d = 51-k; %Para cuando es el sentido horario, empiezo del directorio 50
    
	for i=1:NI
 
       
        if h==1
            %f=['I:\EXP6\antihorario\p' num2str(k-1) '\ima' num2str(i) '.bmp'];
            f=['F:\Fotos autocolimador\EXP9\antihorario\p' num2str(k-1) '\ima' num2str(i) '.bmp'];
            %f=['J:\DATOS\TECNOLOGICA\datos_paper_pattern\Exp 2\ahorario\p' num2str(k-1) '\ima' num2str(i) '.bmp'];
        end
        
        if h==0
            f=['I:\EXP4\horario\p' num2str(d) '\ima' num2str(i) '.bmp'];
            %f=['J:\DATOS\TECNOLOGICA\datos_paper_pattern\Exp 2\horario\p' num2str(d) '\ima' num2str(i) '.bmp'];
        end
        
        %bmp ingresa color por canal? o mezcla colores?
 
        rgb_img = imread(f);
 
    	I = .2989*rgb_img(:,:,1)+.5870*rgb_img(:,:,2) +.1140*rgb_img(:,:,3);
 
        sum_I = sum_I+(double(I)+1);
 
	end
 
	Ip = sum_I/(NI);% Imagen promediada
	Ipneg = 1-(Ip./255);% imagen negada
    
    [bvu, bhu]=centercruz_function(Ipneg);%obtengo el centro por cada imagen
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% LINEA HORIZONTAL DE LA CRUZ%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 	y = 1:200;
	x = 1:200;
    
    xminh= bvu-230;
    yminh = bhu-100;
    
    I = imcrop(Ipneg,[xminh yminh 199 199]);%[xmin ymin width height]% 
    
	%figure; imagesc(II); colormap(gray)% para ver cada corte
    
    %Creo con cftool el fitting del fondo
	[fitfh, goffh] = Fit_fondo_cruz_H(x, y, I);
    %figure; surf(xx, yy, II);
    
    [t1,t2] = meshgrid( x,y);
    promfit = fitfh( t1, t2);
    %figure; surf(t1, t2, promfit);

    Jh = abs(promfit-I);
    %figure; imagesc(J2); colormap(gray)
    %figure; surf(xx, yy, J2);
    
        
    for j = 1:n
      cv = squeeze(Jh(:,j));
      [fith, gofh] =  Fit_un_paso_Gauss_CRUZ_H(x', cv);
 
      ch = coeffvalues(fith);
      cih = confint(fith, 0.95);
 
      BHH(j) = ch(2); %valor central de la gaussiana para cada corte
      IH(j) = (cih(2,2)-cih(1,2))/2; %incertidumbre para cada corte
    end

    %mdlV = LinearModel.fit(1:5, BHH); 
    %figure; plot(mdlV)
 
    %Regregresión
    %X = [ones(1,5)' (1:5)'];
    %[bv, bintv, rv, rintv] = regress(BHH', X);
    %BHHt=bv(1)+635-(k-1)*6;

    %Promedio
    BHHt = sum(BHH)/n + yminh;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% LINEA VERTICAL DE LA CRUZ%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

    
    
    xmin= bvu-100;
    ymin = bhu+30;
    II = imcrop(Ipneg,[xmin ymin 199 199]);%[xmin ymin width height]% 
    %figure; imagesc(III); colormap(gray)% para ver cortes

    [fitfv, goffv] = Fit_fondo_cruz_V(x, y, II);
    [t1,t2] = meshgrid( x,y);
    promfit2 = fitfv( t1, t2);
    Jv = abs(promfit2-II);
    %figure; surf(xx, yy, J); 

    for j = 1:n
        cv2=squeeze(Jv(j,:))';
 
        [fitv, gofv] =  Fit_un_paso_Gauss_CRUZ_V(y', cv2);
 
        cV2 = coeffvalues(fitv);
        ciV = confint(fitv, 0.95);
 
        IV(j) = (ciV(2,2)-ciV(1,2))/2;
        BVV(j) = cV2(2);
    end

    BVVt = sum(BVV)/n + xmin;
end