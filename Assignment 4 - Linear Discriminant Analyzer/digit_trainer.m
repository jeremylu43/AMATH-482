function [U,S,V,threshold,w,sortedA,sortedB] = digit_trainer(digitA, digitB, feature)
    na = size(digitA, 2);
    nb = size(digitB, 2);
    [U,S,V] = svd([digitA digitB], 'econ');
    digits = S*V';
    U = U(:,1:feature);
    digA = digits(1:feature, 1:na);
    digB = digits(1:feature, na+1:na+nb);
    ma = mean(digA, 2);
    mb = mean(digB, 2);
    
    Sw=0;
    for k=1:na
        Sw = Sw + (digA(:,k)-ma)*(digA(:,k)-ma)';
    end
    for k=1:nb
        Sw = Sw + (digB(:,k)-mb)*(digB(:,k)-mb)';
    end
    Sb = (ma-mb)*(ma-mb)';
    
    [V2,D] = eig(Sb,Sw);
    [lambda, ind] = max(abs(diag(D)));
    w = V2(:,ind);
    w = w/norm(w,2);
    va = w'*digA;
    vb = w'*digB;
    
    if mean(va)>mean(vb)
        w=-w;
        va=-va;
        vb=-vb;
    end
    
    sortedA = sort(va);
    sortedB = sort(vb);
    t1 = length(sortedA);
    t2 = 1;
    
    while sortedA(t1)>sortedB(t2)
        t1 = t1-1;
        t2 = t2+1;
    end
    
    threshold = (sortedA(t1)+sortedB(t2))/2;
    
end