    NI = 20;%Numero de imagenes a ser 	promediadas.Etiquetadas consecutivamente
	sum_I = 0;
	SumaTotal = 0;
 
	

for i=1:NI
 
        %f=['J:\DATOS\TECNOLOGICA\datos_paper_pattern\Exp 2\ahorario\p' num2str(k-1) '\ima' num2str(i) '.bmp'];
        %f=['I:\datos_paper_pattern\Exp 2\ahorario\p' num2str(k-1) '\ima' num2str(i) '.bmp'];
        %f=['I:\datos_paper_pattern\Exp 2\horario\p6\ima' num2str(i) '.bmp'];
        f=['I:\EXP6\antihorario\p0\ima' num2str(i) '.bmp']; 
        rgb_img = imread(f);
 
    	I = .2989*rgb_img(:,:,1)+.5870*rgb_img(:,:,2) +.1140*rgb_img(:,:,3);
 
        sum_I = sum_I+(double(I)+1);
 
	end
 
	I_new = sum_I/(NI);
	I_new_neg = 1-(I_new./255);
    
    wx = 203;
    wy = 617;
	y = 1:wy;
	x = 1:wx;
    Isf=zeros(1234,1624);
    
    k=1;
    for i = 0:1
        ymin= i*617+1;
        for j=0:7
            k=k+1;
            xmin= j*203+1;
            I = imcrop(I_new_neg,[xmin ymin 202 616]);%[xmin ymin width height]%
        
        
            [fitresult, gof] = Fit_fondo_cruz_H(x, y, I);
            %figure; surf(x, y, I);
            [t1,t2] = meshgrid(x,y);
            promfit = fitresult( t1, t2);
            %figure; surf(t1, t2, promfit);
        
            J = abs(promfit-I);
            Isf((1+i*617):(617*(i+1)),(1+j*203):(203*(j+1)))=J;
            %figure; imagesc(J); colormap(gray)
            %figure; surf(xx, yy, J2);
        end
        xmin=0;
    end
    
    figure; imshow(Isf);

    i = 0;
    acbh = 0;
     
    for j = 1:1624
        i=i+1;
        cv = squeeze(Isf(:,j));%cortes verticales       
 
        [M,Inh] = max(cv);%M= valor, I=índices.      
        
        bh(i) = Inh; %valor central detectado para cada corte             
    end
    
        bhu = median(bh)  %posición línea horizontal 
      
     
     acbv = 0;
     i = 0;
     for j = 1:1234
        i=i+1;
        ch = squeeze(Isf(j,:));%cortes horizontales
      
        [M,Inv] = max(ch);%M= valor, I=índices.
       
        bv(i) = Inv; %valor central detectado de la gaussiana para cada corte                
     end
     
      bvu = median(bv)  %posición línea vertical
      
