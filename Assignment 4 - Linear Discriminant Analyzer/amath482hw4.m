%% Loading in data
[images, labels] = mnist_parse('train-images.idx3-ubyte', 'train-labels.idx1-ubyte');
training_data = zeros(784,60000);

[timages, tlabels] = mnist_parse('t10k-images.idx3-ubyte', 't10k-labels.idx1-ubyte');
testing_data = zeros(784,10000);
%% Reshaping and doing SVD
for i = 1:60000
    training_data(:,i) = im2double(reshape(images(:,:,i),784,1));
end
[m,n] = size(training_data);
mn = mean(training_data,2);
training_data = training_data - repmat(mn,1,n);
[U,S,V] = svd(training_data,'econ');
sig = diag(S);
lambda = diag(S).^2;

for i = 1:10000
    testing_data(:,i) = im2double(reshape(timages(:,:,i),784,1));
end
[m,n] = size(testing_data);
testing_data = testing_data - repmat(mn,1,n);
%% We use the first 100 features

figure()
subplot(2,1,1);
plot(lambda/sum(lambda),'ko','Linewidth',1);
set(gca,'Fontsize',12, 'Xlim', [0 200]);
xlabel('n-th Singular Value Mode')
ylabel('Singular Value Energy')
title("PCA Energies")
subplot(2,1,2)
semilogy(diag(S),'ko','Linewidth',1);
set(gca,'Fontsize',12);
xlabel('n-th Singular Value Mode')
ylabel('Singular Value')
title("Singular Value Spectrum (log scale)")
saveas(gcf, 'PCA_data.png')
%First 100 = 0.9146 of energy
%% Projection onto 3 V-modes
projection = U(:,[1,2,3])'*training_data;
for label=0:9
    digit_proj = projection(:,find(labels == label));
    plot3(digit_proj(1,:),digit_proj(2,:),digit_proj(3,:),...
        'o', 'DisplayName', sprintf('%i',label), 'Linewidth', 1)
    hold on
end
xlabel('1st V-Mode'), ylabel('2nd V-Mode'), zlabel('3rd V-Mode')
title('Projection onto V-modes 1, 2, 3')
legend
set(gca,'Fontsize', 14)
saveas(gcf, 'V_node_projection.png')
%% build model
feature = 100;
n=1;
accuracies=zeros(3,45);
total_correct = 0;
total_predictions = 0;
for i = 0:8
    for j = i+1:9
        digitA = training_data(:,find(labels==i));
        digitB = training_data(:,find(labels==j));
        [U,S,V,threshold,w,sortedA,sortedB] = digit_trainer(digitA,digitB,feature);
        testA = testing_data(:,find(tlabels==i));
        correct = 0;
        alength = size(testA,2);
        for k = 1:alength
            digit = testA(:,k);
            imat = U' * digit;
            digitval = w' * imat;
    
            if digitval < threshold
                correct = correct + 1;
            end
        end
        testB = testing_data(:,find(tlabels==j));
        blength = size(testB,2);
        for k = 1:size(testB,2)
            digit = testB(:,k);
            imat = U' * digit;
            digitval = w' * imat;
    
            if digitval > threshold
                correct = correct + 1;
            end
        end

        accuracy = correct/(alength+blength);
        accuracies(1,n)=i;
        accuracies(2,n)=j;
        accuracies(3,n)=accuracy;
        n=n+1;
        total_predictions=total_predictions+alength+blength;
        total_correct = total_correct+correct;
    end
end
total_correct/total_predictions;
%total accuracy = 0.9839
%% minimum
% index = 35
accuracies(:,35);
%4,9, 0.9508
accuracies(:,4);
%0,4, 0.9985

%% SVM
[U,S,V] = svd(training_data,'econ');
U=U(:,1:feature);
proj = S*V';
train_input = (U'*training_data)'./max(proj(:));
Mdl = fitcecoc(train_input,labels);
%%
test_input = (U' * testing_data)'./max(proj(:));
testlabels = predict(Mdl,test_input);
correct = 0;
s = testlabels == tlabels;
sum(s)/numel(s)
%accuracy = 0.9425
%% Decision Tree
d_tree = fitctree(train_input,labels);
%%
testlabels = predict(d_tree, test_input);
s = testlabels == tlabels;
sum(s)/numel(s);
%accuracy = 0.8383

%% SVM on easiest and hardest pairs
train_input = train_input';
train_zero = train_input(:,find(labels==0));
train_four = train_input(:,find(labels==4));
train_nine = train_input(:,find(labels==9));

label_zero = zeros(1,size(train_zero,2));
label_four = zeros(1,size(train_four,2)) + 4;
label_nine = zeros(1,size(train_nine,2)) + 9;

train_onefour = [train_zero train_four];
label_onefour = [label_zero label_four];
train_fournine = [train_four train_nine];
label_fournine = [label_four label_nine];

Mdl4 = fitcsvm(train_onefour',label_onefour);
Md49 = fitcsvm(train_fournine',label_fournine);
%%
test_input=test_input';
test_zero = test_input(:,find(tlabels==0));
test_four = test_input(:,find(tlabels==4));
test_nine = test_input(:,find(tlabels==9));

tlabel_zero = zeros(1,size(test_zero,2));
tlabel_four = zeros(1,size(test_four,2)) + 4;
tlabel_nine = zeros(1,size(test_nine,2)) + 9;

test_onefour = [test_zero test_four];
tlabel_onefour = [tlabel_zero tlabel_four];
test_fournine = [test_four test_nine];
tlabel_fournine = [tlabel_four tlabel_nine];

testlabels = predict(Mdl4,test_onefour');
s = testlabels == tlabel_onefour';
sum(s)/numel(s)
%0.9985

testlabels = predict(Md49,test_fournine');
s = testlabels == tlabel_fournine';
sum(s)/numel(s)
%0.9684
%% Classification tree on easiest and hardest pairs
d_tree = fitctree(train_onefour',label_onefour);

testlabels = predict(d_tree,test_onefour');
s = testlabels == tlabel_onefour';
sum(s)/numel(s)
%0.9776

d_tree = fitctree(train_fournine', label_fournine);
testlabels = predict(d_tree,test_onefour');
s = testlabels == tlabel_onefour';
sum(s)/numel(s)
% 0.4572
%%
view(d_tree,'mode','graph')