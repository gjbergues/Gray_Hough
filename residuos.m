dif = xlsread('exp.xls','D3:D27');%med nivel antihorario
ang = xlsread('exp.xls','A3:A27');%med nivel antihorario

 mdl = LinearModel.fit(-ang, dif); 
 figure; plot(mdl)
 title('Residuos');
 xlabel('Measurment angele');
 ylabel('Residuos');
    
a='caseorder';	
b='fitted'	;
c='histogram'	;
d='lagged'	;
e='probability';
f='symmetry';

    
    res = mdl.Residuals.Raw
    plot(ang,res,'*r');
    h = plotResiduals(mdl,b);
    ecm = sqrt(sum(res.^2)/25);