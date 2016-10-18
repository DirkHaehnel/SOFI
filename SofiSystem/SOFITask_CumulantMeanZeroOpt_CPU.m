%slowly imlpementation only for bigger structures and out memory error,,
function cum = SOFITask_CumulantMeanZeroOpt_CPU(im,n,flag)

if nargin<3 || isempty(flag)
    im = im - repmat(mean(im,3),[1 1 size(im,3)]);
end

dimensiones = size(im);
switch n
    case 1
        cum = 0;
    case 2
        cum = zeros(dimensiones(1),dimensiones(2));
        for f=1:dimensiones(1) 
            cum(f,:) = mean((im(f,:,1:end-1).*im(f,:,2:end)),3);
        end
        clear temporal;
    case 3
        cum = zeros(dimensiones(1),dimensiones(2));
        for f=1:dimensiones(1) 
            cum(f,:) = mean((im(f,:,1:end-2).*im(f,:,2:end-1).*im(f,:,3:end)),3);
        end
    case 4
        cum = zeros(dimensiones(1),dimensiones(2));
        for f=1:dimensiones(1) 
            temp1 = mean(im(f,:,1:end-3).*im(f,:,4:end),3);
            temp2 = mean(im(f,:,2:end-2).*im(f,:,3:end-1),3);
            temp3 = mean(im(f,:,1:end-3).*im(f,:,3:end-1),3);
            temp4 = mean(im(f,:,2:end-2).*im(f,:,4:end),3);
            temp5 = mean(im(f,:,1:end-3).*im(f,:,2:end-2),3);
            temp6 = mean(im(f,:,3:end-1).*im(f,:,4:end),3);
            temp7 = mean(im(f,:,1:end-3).*im(f,:,2:end-2).*im(f,:,3:end-1).*im(f,:,4:end),3);
            cum(f,:) = -temp1.*temp2-temp3.*temp4-temp5.*temp6+temp7;
        end
        clear temp* f
        %cum = -mean(im(:,:,1:end-3).*im(:,:,4:end),3).*mean(im(:,:,2:end-2).*im(:,:,3:end-1),3)-mean(im(:,:,1:end-3).*im(:,:,3:end-1),3).*mean(im(:,:,2:end-2).*im(:,:,4:end),3)-mean(im(:,:,1:end-3).*im(:,:,2:end-2),3).*mean(im(:,:,3:end-1).*im(:,:,4:end),3)+mean(im(:,:,1:end-3).*im(:,:,2:end-2).*im(:,:,3:end-1).*im(:,:,4:end),3);
    case 5
        cum = zeros(dimensiones(1),dimensiones(2));
        for f=1:dimensiones(1) 
            temp1 = mean(im(f,:,4:end-1).*im(f,:,5:end),3);
            temp2 = mean(im(f,:,1:end-4).*im(f,:,2:end-3).*im(f,:,3:end-2),3);
            temp3 = mean(im(f,:,3:end-2).*im(f,:,5:end),3);
            temp4 = mean(im(f,:,1:end-4).*im(f,:,2:end-3).*im(f,:,4:end-1),3);
            temp5 = mean(im(f,:,3:end-2).*im(f,:,4:end-1),3);
            temp6 = mean(im(f,:,1:end-4).*im(f,:,2:end-3).*im(f,:,5:end),3);
            temp7 = mean(im(f,:,2:end-3).*im(f,:,5:end),3);
            temp8 = mean(im(f,:,1:end-4).*im(f,:,3:end-2).*im(f,:,4:end-1),3);
            temp9 = mean(im(f,:,2:end-3).*im(f,:,4:end-1),3);
            temp10 = mean(im(f,:,1:end-4).*im(f,:,3:end-2).*im(f,:,5:end),3);
            temp11 = mean(im(f,:,2:end-3).*im(f,:,3:end-2),3);
            temp12 = mean(im(f,:,1:end-4).*im(f,:,4:end-1).*im(f,:,5:end),3);
            temp13 = mean(im(f,:,1:end-4).*im(f,:,5:end),3);
            temp14 = mean(im(f,:,2:end-3).*im(f,:,3:end-2).*im(f,:,4:end-1),3);
            temp15 = mean(im(f,:,1:end-4).*im(f,:,4:end-1),3);
            temp16 = mean(im(f,:,2:end-3).*im(f,:,3:end-2).*im(f,:,5:end),3);
            temp17 = mean(im(f,:,1:end-4).*im(f,:,3:end-2),3);
            temp18 = mean(im(f,:,2:end-3).*im(f,:,4:end-1).*im(f,:,5:end),3);
            temp19 = mean(im(f,:,1:end-4).*im(f,:,2:end-3),3);
            temp20 = mean(im(f,:,3:end-2).*im(f,:,4:end-1).*im(f,:,5:end),3);
            temp21 = mean(im(f,:,1:end-4).*im(f,:,2:end-3).*im(f,:,3:end-2).*im(f,:,4:end-1).*im(f,:,5:end),3);
            
            cum(f,:) = -temp1.*temp2-temp3.*temp4-temp5.*temp6-temp7.*temp8-temp9.*temp10-...
                temp11.*temp12-temp13.*temp14- temp15.*temp16-temp17.*temp18-temp19.*temp20+temp21;
        end
        
        clear temp* f                
        %cum = -mean(im(:,:,4:end-1).*im(:,:,5:end),3).*mean(im(:,:,1:end-4).*im(:,:,2:end-3).*im(:,:,3:end-2),3)-mean(im(:,:,3:end-2).*im(:,:,5:end),3).*mean(im(:,:,1:end-4).*im(:,:,2:end-3).*im(:,:,4:end-1),3)-mean(im(:,:,3:end-2).*im(:,:,4:end-1),3).*mean(im(:,:,1:end-4).*im(:,:,2:end-3).*im(:,:,5:end),3)-mean(im(:,:,2:end-3).*im(:,:,5:end),3).*mean(im(:,:,1:end-4).*im(:,:,3:end-2).*im(:,:,4:end-1),3)-mean(im(:,:,2:end-3).*im(:,:,4:end-1),3).*mean(im(:,:,1:end-4).*im(:,:,3:end-2).*im(:,:,5:end),3)-mean(im(:,:,2:end-3).*im(:,:,3:end-2),3).*mean(im(:,:,1:end-4).*im(:,:,4:end-1).*im(:,:,5:end),3)-mean(im(:,:,1:end-4).*im(:,:,5:end),3).*mean(im(:,:,2:end-3).*im(:,:,3:end-2).*im(:,:,4:end-1),3)-mean(im(:,:,1:end-4).*im(:,:,4:end-1),3).*mean(im(:,:,2:end-3).*im(:,:,3:end-2).*im(:,:,5:end),3)-mean(im(:,:,1:end-4).*im(:,:,3:end-2),3).*mean(im(:,:,2:end-3).*im(:,:,4:end-1).*im(:,:,5:end),3)-mean(im(:,:,1:end-4).*im(:,:,2:end-3),3).*mean(im(:,:,3:end-2).*im(:,:,4:end-1).*im(:,:,5:end),3)+mean(im(:,:,1:end-4).*im(:,:,2:end-3).*im(:,:,3:end-2).*im(:,:,4:end-1).*im(:,:,5:end),3);
    case 6
        cum = zeros(dimensiones(1),dimensiones(2));
        for f=1:dimensiones(1) 
            temp1 = mean(im(f,:,1:end-5).*im(f,:,6:end),3);
            temp2 = mean(im(f,:,2:end-4).*im(f,:,5:end-1),3);
            temp3 = mean(im(f,:,3:end-3).*im(f,:,4:end-2),3);
            temp4 = mean(im(f,:,1:end-5).*im(f,:,5:end-1),3);
            temp5 = mean(im(f,:,2:end-4).*im(f,:,6:end),3);
            temp6 = mean(im(f,:,3:end-3).*im(f,:,4:end-2),3);
            temp7 = mean(im(f,:,1:end-5).*im(f,:,6:end),3);
            temp8 = mean(im(f,:,2:end-4).*im(f,:,4:end-2),3);
            temp9 = mean(im(f,:,3:end-3).*im(f,:,5:end-1),3);
            temp10 = mean(im(f,:,1:end-5).*im(f,:,4:end-2),3);
            temp11 = mean(im(f,:,2:end-4).*im(f,:,6:end),3);
            temp12 = mean(im(f,:,3:end-3).*im(f,:,5:end-1),3);
            temp13 = mean(im(f,:,1:end-5).*im(f,:,5:end-1),3);
            temp14 = mean(im(f,:,2:end-4).*im(f,:,4:end-2),3);
            temp15 = mean(im(f,:,3:end-3).*im(f,:,6:end),3);
            temp16 = mean(im(f,:,1:end-5).*im(f,:,4:end-2),3);
            temp17 = mean(im(f,:,2:end-4).*im(f,:,5:end-1),3);
            temp18 = mean(im(f,:,3:end-3).*im(f,:,6:end),3);
            temp19 = mean(im(f,:,1:end-5).*im(f,:,6:end),3);
            temp20 = mean(im(f,:,2:end-4).*im(f,:,3:end-3),3);
            temp21 = mean(im(f,:,4:end-2).*im(f,:,5:end-1),3);
            temp22 = mean(im(f,:,1:end-5).*im(f,:,3:end-3),3);
            temp23 = mean(im(f,:,2:end-4).*im(f,:,6:end),3);
            temp24 = mean(im(f,:,4:end-2).*im(f,:,5:end-1),3);
            temp25 = mean(im(f,:,1:end-5).*im(f,:,2:end-4),3);
            temp26 = mean(im(f,:,3:end-3).*im(f,:,6:end),3);
            temp27 = mean(im(f,:,4:end-2).*im(f,:,5:end-1),3);
            temp28 = mean(im(f,:,1:end-5).*im(f,:,5:end-1),3);
            temp29 = mean(im(f,:,2:end-4).*im(f,:,3:end-3),3);
            temp30 = mean(im(f,:,4:end-2).*im(f,:,6:end),3);
            temp31 = mean(im(f,:,1:end-5).*im(f,:,3:end-3),3);
            temp32 = mean(im(f,:,2:end-4).*im(f,:,5:end-1),3);
            temp33 = mean(im(f,:,4:end-2).*im(f,:,6:end),3);
            temp34 = mean(im(f,:,1:end-5).*im(f,:,2:end-4),3);
            temp35 = mean(im(f,:,3:end-3).*im(f,:,5:end-1),3);
            temp36 = mean(im(f,:,4:end-2).*im(f,:,6:end),3);
            temp37 = mean(im(f,:,1:end-5).*im(f,:,4:end-2),3);
            temp38 = mean(im(f,:,2:end-4).*im(f,:,3:end-3),3);
            temp39 = mean(im(f,:,5:end-1).*im(f,:,6:end),3);
            temp40 = mean(im(f,:,1:end-5).*im(f,:,3:end-3),3);
            temp41 = mean(im(f,:,2:end-4).*im(f,:,4:end-2),3);
            temp42 = mean(im(f,:,5:end-1).*im(f,:,6:end),3);
            temp43 = mean(im(f,:,1:end-5).*im(f,:,2:end-4),3);
            temp44 = mean(im(f,:,5:end-1).*im(f,:,6:end),3);
            temp45 = mean(im(f,:,3:end-3).*im(f,:,4:end-2),3);
            temp46 = mean(im(f,:,1:end-5).*im(f,:,5:end-1).*im(f,:,6:end),3);
            temp47 = mean(im(f,:,2:end-4).*im(f,:,3:end-3).*im(f,:,4:end-2),3);
            temp48 = mean(im(f,:,1:end-5).*im(f,:,4:end-2).*im(f,:,6:end),3);
            temp49 = mean(im(f,:,2:end-4).*im(f,:,3:end-3).*im(f,:,5:end-1),3);
            temp50 = mean(im(f,:,1:end-5).*im(f,:,4:end-2).*im(f,:,5:end-1),3);
            temp51 = mean(im(f,:,2:end-4).*im(f,:,3:end-3).*im(f,:,6:end),3);
            temp52 = mean(im(f,:,1:end-5).*im(f,:,3:end-3).*im(f,:,6:end),3);
            temp53 = mean(im(f,:,2:end-4).*im(f,:,4:end-2).*im(f,:,5:end-1),3);
            temp54 = mean(im(f,:,1:end-5).*im(f,:,3:end-3).*im(f,:,5:end-1),3);
            temp55 = mean(im(f,:,2:end-4).*im(f,:,4:end-2).*im(f,:,6:end),3);
            temp56 = mean(im(f,:,1:end-5).*im(f,:,3:end-3).*im(f,:,4:end-2),3);
            temp57 = mean(im(f,:,2:end-4).*im(f,:,5:end-1).*im(f,:,6:end),3);
            temp58 = mean(im(f,:,1:end-5).*im(f,:,2:end-4).*im(f,:,6:end),3);
            temp59 = mean(im(f,:,3:end-3).*im(f,:,4:end-2).*im(f,:,5:end-1),3);
            temp60 = mean(im(f,:,1:end-5).*im(f,:,2:end-4).*im(f,:,5:end-1),3);
            temp61 = mean(im(f,:,3:end-3).*im(f,:,4:end-2).*im(f,:,6:end),3);
            temp62 = mean(im(f,:,1:end-5).*im(f,:,2:end-4).*im(f,:,4:end-2),3);
            temp63 = mean(im(f,:,3:end-3).*im(f,:,5:end-1).*im(f,:,6:end),3);
            temp64 = mean(im(f,:,1:end-5).*im(f,:,2:end-4).*im(f,:,3:end-3),3);
            temp65 = mean(im(f,:,4:end-2).*im(f,:,5:end-1).*im(f,:,6:end),3);
            temp66 = mean(im(f,:,5:end-1).*im(f,:,6:end),3);
            temp67 = mean(im(f,:,1:end-5).*im(f,:,2:end-4).*im(f,:,3:end-3).*im(f,:,4:end-2),3);
            temp68 = mean(im(f,:,4:end-2).*im(f,:,6:end),3);
            temp69 = mean(im(f,:,1:end-5).*im(f,:,2:end-4).*im(f,:,3:end-3).*im(f,:,5:end-1),3);
            temp70 = mean(im(f,:,4:end-2).*im(f,:,5:end-1),3);
            temp71 = mean(im(f,:,1:end-5).*im(f,:,2:end-4).*im(f,:,3:end-3).*im(f,:,6:end),3);
            temp72 = mean(im(f,:,3:end-3).*im(f,:,6:end),3);
            temp73 = mean(im(f,:,1:end-5).*im(f,:,2:end-4).*im(f,:,4:end-2).*im(f,:,5:end-1),3);
            temp74 = mean(im(f,:,3:end-3).*im(f,:,5:end-1),3);
            temp75 = mean(im(f,:,1:end-5).*im(f,:,2:end-4).*im(f,:,4:end-2).*im(f,:,6:end),3);
            temp76 = mean(im(f,:,3:end-3).*im(f,:,4:end-2),3);
            temp77 = mean(im(f,:,1:end-5).*im(f,:,2:end-4).*im(f,:,5:end-1).*im(f,:,6:end),3);
            temp78 = mean(im(f,:,2:end-4).*im(f,:,6:end),3);
            temp79 = mean(im(f,:,1:end-5).*im(f,:,3:end-3).*im(f,:,4:end-2).*im(f,:,5:end-1),3);
            temp80 = mean(im(f,:,2:end-4).*im(f,:,5:end-1),3);
            temp81 = mean(im(f,:,1:end-5).*im(f,:,3:end-3).*im(f,:,4:end-2).*im(f,:,6:end),3);
            temp82 = mean(im(f,:,2:end-4).*im(f,:,4:end-2),3);
            temp83 = mean(im(f,:,1:end-5).*im(f,:,3:end-3).*im(f,:,5:end-1).*im(f,:,6:end),3);
            temp84 = mean(im(f,:,2:end-4).*im(f,:,3:end-3),3);
            temp85 = mean(im(f,:,1:end-5).*im(f,:,4:end-2).*im(f,:,5:end-1).*im(f,:,6:end),3);
            temp86 = mean(im(f,:,1:end-5).*im(f,:,6:end),3);
            temp87 = mean(im(f,:,2:end-4).*im(f,:,3:end-3).*im(f,:,4:end-2).*im(f,:,5:end-1),3);
            temp88 = mean(im(f,:,1:end-5).*im(f,:,5:end-1),3);
            temp89 = mean(im(f,:,2:end-4).*im(f,:,3:end-3).*im(f,:,4:end-2).*im(f,:,6:end),3);
            temp90 = mean(im(f,:,1:end-5).*im(f,:,4:end-2),3);
            temp91 = mean(im(f,:,2:end-4).*im(f,:,3:end-3).*im(f,:,5:end-1).*im(f,:,6:end),3);
            temp92 = mean(im(f,:,1:end-5).*im(f,:,3:end-3),3);
            temp93 = mean(im(f,:,2:end-4).*im(f,:,4:end-2).*im(f,:,5:end-1).*im(f,:,6:end),3);
            temp94 = mean(im(f,:,1:end-5).*im(f,:,2:end-4),3);
            temp95 = mean(im(f,:,3:end-3).*im(f,:,4:end-2).*im(f,:,5:end-1).*im(f,:,6:end),3);
            temp96 = mean(im(f,:,1:end-5).*im(f,:,2:end-4).*im(f,:,3:end-3).*im(f,:,4:end-2).*im(f,:,5:end-1).*im(f,:,6:end),3);

            cum(f,:) =  2.*temp1.*temp2.*temp3+2.*temp4.*temp5.*temp6+2.*temp7.*temp8.*temp9+...
                        2.*temp10.*temp11.*temp12+ 2.*temp13.*temp14.*temp15+2.*temp16.*temp17.*temp18+...
                        2.*temp19.*temp20.*temp21+2.*temp22.*temp23.*temp24+2.*temp25.*temp26.*temp27+...
                        2.*temp28.*temp29.*temp30+2.*temp31.*temp32.*temp33+2.*temp34.*temp35.*temp36+...
                        2.*temp37.*temp38.*temp39+2.*temp40.*temp41.*temp42+2.*temp43.*temp44.*temp45-...
                        temp46.*temp47-temp48.*temp49-temp50.*temp51-temp52.*temp53-temp54.*temp55-...
                        temp56.*temp57-temp58.*temp59-temp60.*temp61-temp62.*temp63-temp64.*temp65-...
                        temp66.*temp67-temp68.*temp69-temp70.*temp71-temp72.*temp73-temp74.*temp75-...
                        temp76.*temp77-temp78.*temp79-temp80.*temp81-temp82.*temp83-temp84.*temp85-...
                        temp86.*temp87-temp88.*temp89-temp90.*temp91-temp92.*temp93-temp94.*temp95+temp96;
        end

        clear temp* f        
        
        %cum = 2.*mean(im(:,:,1:end-5).*im(:,:,6:end),3).*mean(im(:,:,2:end-4).*im(:,:,5:end-1),3).*mean(im(:,:,3:end-3).*im(:,:,4:end-2),3)+
        %2.*mean(im(:,:,1:end-5).*im(:,:,5:end-1),3).*mean(im(:,:,2:end-4).*im(:,:,6:end),3).*mean(im(:,:,3:end-3).*im(:,:,4:end-2),3)+
        %2.*mean(im(:,:,1:end-5).*im(:,:,6:end),3).*mean(im(:,:,2:end-4).*im(:,:,4:end-2),3).*mean(im(:,:,3:end-3).*im(:,:,5:end-1),3)+
        %2.*mean(im(:,:,1:end-5).*im(:,:,4:end-2),3).*mean(im(:,:,2:end-4).*im(:,:,6:end),3).*mean(im(:,:,3:end-3).*im(:,:,5:end-1),3)+
        %2.*mean(im(:,:,1:end-5).*im(:,:,5:end-1),3).*mean(im(:,:,2:end-4).*im(:,:,4:end-2),3).*mean(im(:,:,3:end-3).*im(:,:,6:end),3)+
        %2.*mean(im(:,:,1:end-5).*im(:,:,4:end-2),3).*mean(im(:,:,2:end-4).*im(:,:,5:end-1),3).*mean(im(:,:,3:end-3).*im(:,:,6:end),3)+
        %2.*mean(im(:,:,1:end-5).*im(:,:,6:end),3).*mean(im(:,:,2:end-4).*im(:,:,3:end-3),3).*mean(im(:,:,4:end-2).*im(:,:,5:end-1),3)+
        %2.*mean(im(:,:,1:end-5).*im(:,:,3:end-3),3).*mean(im(:,:,2:end-4).*im(:,:,6:end),3).*mean(im(:,:,4:end-2).*im(:,:,5:end-1),3)+
        %2.*mean(im(:,:,1:end-5).*im(:,:,2:end-4),3).*mean(im(:,:,3:end-3).*im(:,:,6:end),3).*mean(im(:,:,4:end-2).*im(:,:,5:end-1),3)+
        %2.*mean(im(:,:,1:end-5).*im(:,:,5:end-1),3).*mean(im(:,:,2:end-4).*im(:,:,3:end-3),3).*mean(im(:,:,4:end-2).*im(:,:,6:end),3)+
        %2.*mean(im(:,:,1:end-5).*im(:,:,3:end-3),3).*mean(im(:,:,2:end-4).*im(:,:,5:end-1),3).*mean(im(:,:,4:end-2).*im(:,:,6:end),3)+
        %2.*mean(im(:,:,1:end-5).*im(:,:,2:end-4),3).*mean(im(:,:,3:end-3).*im(:,:,5:end-1),3).*mean(im(:,:,4:end-2).*im(:,:,6:end),3)+
        %2.*mean(im(:,:,1:end-5).*im(:,:,4:end-2),3).*mean(im(:,:,2:end-4).*im(:,:,3:end-3),3).*mean(im(:,:,5:end-1).*im(:,:,6:end),3)+
        %2.*mean(im(:,:,1:end-5).*im(:,:,3:end-3),3).*mean(im(:,:,2:end-4).*im(:,:,4:end-2),3).*mean(im(:,:,5:end-1).*im(:,:,6:end),3)+
        %2.*mean(im(:,:,1:end-5).*im(:,:,2:end-4),3).*mean(im(:,:,3:end-3).*im(:,:,4:end-2),3).*mean(im(:,:,5:end-1).*im(:,:,6:end),3)-
        %mean(im(:,:,1:end-5).*im(:,:,5:end-1).*im(:,:,6:end),3).*mean(im(:,:,2:end-4).*im(:,:,3:end-3).*im(:,:,4:end-2),3)-
        %mean(im(:,:,1:end-5).*im(:,:,4:end-2).*im(:,:,6:end),3).*mean(im(:,:,2:end-4).*im(:,:,3:end-3).*im(:,:,5:end-1),3)-
        %mean(im(:,:,1:end-5).*im(:,:,4:end-2).*im(:,:,5:end-1),3).*mean(im(:,:,2:end-4).*im(:,:,3:end-3).*im(:,:,6:end),3)-
        %mean(im(:,:,1:end-5).*im(:,:,3:end-3).*im(:,:,6:end),3).*mean(im(:,:,2:end-4).*im(:,:,4:end-2).*im(:,:,5:end-1),3)-
        %mean(im(:,:,1:end-5).*im(:,:,3:end-3).*im(:,:,5:end-1),3).*mean(im(:,:,2:end-4).*im(:,:,4:end-2).*im(:,:,6:end),3)-
        %mean(im(:,:,1:end-5).*im(:,:,3:end-3).*im(:,:,4:end-2),3).*mean(im(:,:,2:end-4).*im(:,:,5:end-1).*im(:,:,6:end),3)-
        %mean(im(:,:,1:end-5).*im(:,:,2:end-4).*im(:,:,6:end),3).*mean(im(:,:,3:end-3).*im(:,:,4:end-2).*im(:,:,5:end-1),3)-
        %mean(im(:,:,1:end-5).*im(:,:,2:end-4).*im(:,:,5:end-1),3).*mean(im(:,:,3:end-3).*im(:,:,4:end-2).*im(:,:,6:end),3)-
        %mean(im(:,:,1:end-5).*im(:,:,2:end-4).*im(:,:,4:end-2),3).*mean(im(:,:,3:end-3).*im(:,:,5:end-1).*im(:,:,6:end),3)-
        %mean(im(:,:,1:end-5).*im(:,:,2:end-4).*im(:,:,3:end-3),3).*mean(im(:,:,4:end-2).*im(:,:,5:end-1).*im(:,:,6:end),3)-
        %mean(im(:,:,5:end-1).*im(:,:,6:end),3).*mean(im(:,:,1:end-5).*im(:,:,2:end-4).*im(:,:,3:end-3).*im(:,:,4:end-2),3)-
        %mean(im(:,:,4:end-2).*im(:,:,6:end),3).*mean(im(:,:,1:end-5).*im(:,:,2:end-4).*im(:,:,3:end-3).*im(:,:,5:end-1),3)-
        %mean(im(:,:,4:end-2).*im(:,:,5:end-1),3).*mean(im(:,:,1:end-5).*im(:,:,2:end-4).*im(:,:,3:end-3).*im(:,:,6:end),3)-
        %mean(im(:,:,3:end-3).*im(:,:,6:end),3).*mean(im(:,:,1:end-5).*im(:,:,2:end-4).*im(:,:,4:end-2).*im(:,:,5:end-1),3)-
        %mean(im(:,:,3:end-3).*im(:,:,5:end-1),3).*mean(im(:,:,1:end-5).*im(:,:,2:end-4).*im(:,:,4:end-2).*im(:,:,6:end),3)-
        %mean(im(:,:,3:end-3).*im(:,:,4:end-2),3).*mean(im(:,:,1:end-5).*im(:,:,2:end-4).*im(:,:,5:end-1).*im(:,:,6:end),3)-
        %mean(im(:,:,2:end-4).*im(:,:,6:end),3).*mean(im(:,:,1:end-5).*im(:,:,3:end-3).*im(:,:,4:end-2).*im(:,:,5:end-1),3)-
        %mean(im(:,:,2:end-4).*im(:,:,5:end-1),3).*mean(im(:,:,1:end-5).*im(:,:,3:end-3).*im(:,:,4:end-2).*im(:,:,6:end),3)-
        %mean(im(:,:,2:end-4).*im(:,:,4:end-2),3).*mean(im(:,:,1:end-5).*im(:,:,3:end-3).*im(:,:,5:end-1).*im(:,:,6:end),3)-
        %mean(im(:,:,2:end-4).*im(:,:,3:end-3),3).*mean(im(:,:,1:end-5).*im(:,:,4:end-2).*im(:,:,5:end-1).*im(:,:,6:end),3)-
        %mean(im(:,:,1:end-5).*im(:,:,6:end),3).*mean(im(:,:,2:end-4).*im(:,:,3:end-3).*im(:,:,4:end-2).*im(:,:,5:end-1),3)-
        %mean(im(:,:,1:end-5).*im(:,:,5:end-1),3).*mean(im(:,:,2:end-4).*im(:,:,3:end-3).*im(:,:,4:end-2).*im(:,:,6:end),3)-
        %mean(im(:,:,1:end-5).*im(:,:,4:end-2),3).*mean(im(:,:,2:end-4).*im(:,:,3:end-3).*im(:,:,5:end-1).*im(:,:,6:end),3)-
        %mean(im(:,:,1:end-5).*im(:,:,3:end-3),3).*mean(im(:,:,2:end-4).*im(:,:,4:end-2).*im(:,:,5:end-1).*im(:,:,6:end),3)-
        %mean(im(:,:,1:end-5).*im(:,:,2:end-4),3).*mean(im(:,:,3:end-3).*im(:,:,4:end-2).*im(:,:,5:end-1).*im(:,:,6:end),3)+
        %mean(im(:,:,1:end-5).*im(:,:,2:end-4).*im(:,:,3:end-3).*im(:,:,4:end-2).*im(:,:,5:end-1).*im(:,:,6:end),3);
end

return
