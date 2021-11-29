Isf= Ip;

i = 0;
    acbh = 0;
     
    for j = 1:1624
        i=i+1;
        cv = squeeze(Isf(:,j));%cortes verticales       
 
        [M,Inh] = max(cv);%M= valor, I=índices.      
        
        bh(i) = Inh; %valor central detectado para cada corte             
    end
    
        bhu = median(bh) %posición línea horizontal 
      
     
     acbv = 0;
     i = 0;
     for j = 1:1234
        i=i+1;
        ch = squeeze(Isf(j,:));%cortes horizontales
      
        [M,Inv] = max(ch);%M= valor, I=índices.
       
        bv(i) = Inv; %valor central detectado de la gaussiana para cada corte                
     end
     
      bvu = median(bv)  %posición línea vertical