    
   Isf_c = rgb2gray(cutcross);    

    A = (Isf_c > 56);
    B = (56 >Isf_c & Isf_c >= 52);
    C = (52 > Isf_c & Isf_c > 42);
    D = (42 > Isf_c & Isf_c > 30);
    E = (30 > Isf_c & Isf_c > 16);
    T = A+B+C+D+E;

    [H,theta,rho] = hough(T,'RhoResolution',1,'Theta',-90:1:89.5);
    [Hfil, Hcol]= find(H >= (0.5*max(max(H))));

    x1 = theta(Hcol(:,1));
    y1 = rho(Hfil(:,1));
    figure; plot(x1,y1,'s','color','black');

    
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