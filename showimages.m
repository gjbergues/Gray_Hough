function showimages( Gf,n )
%Gf=3D matrix
%n=how many images do you want to see?
for i = 1:n
    
    Im= mat2gray(Gf(:,:,i),[0,255]);
    imshow(Im);
    k=waitforbuttonpress;
end

end

