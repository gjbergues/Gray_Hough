I = rgb2gray(cutcross);
%I = 1 - (I ./ 255);

Id = double(I);


x= 1:31;
y= 1:96;

surf(Id)


A = (Id > 170);
B = (170 >Id & Id >= 145);
C = (145 > Id & Id > 105);
D= (105 > Id & Id > 70);
T = A+B+C+D;

[H,theta,rho] = hough(T,'RhoResolution',1,'Theta',-90:1:89.5);
[Hfil, Hcol]= find(H >= (0.9*max(max(H))));

 x1 = theta(Hcol(:,1));
 y1 = rho(Hfil(:,1));
 figure; plot(x1,y1,'s','color','black');

%  for i= 1:30 
%     if(y1(i) < 0)
%         v_1(i)=y1(i);
%     end
%     if (y1(i) > 0)
%       v_2(i)=y1(i);
%     end
% end



figure; surf(H)