%% Определение графа
clc; clear all;
A=randi([0 1], 5,5);
M = triu(A) + triu(A,1)';
M(1,end)=1; M(end,1)=1;
for i=1:1:size(M,1)
    for j=1:1:size(M,2)
        if i==j
            M(i,j)=0;
        end
    end
    if sum(M(:,i))==0
        if i~=size(M,1)
            M(i+1,i)=1;
        else
            M(i-1,i)=1;
        end
        M=M';
        if i~=size(M,1)
            M(i+1,i)=1;
        else
            M(i-1,i)=1;
        end
    end
end
G = graph(M);
figure(1);
plot(G); title('Случайный граф')
%% Расчёт центрального по степини
SumBond(:,1)=1:1:length(M);
S=sum(M);
figure(2);
plot(S,'-or'); title('Кол-во связей у пользывателей')
SumBond(:,2)=S./max(max(S));
SumBond=sortrows(SumBond,2,'descend');
for i=1:1:size(SumBond,1)
    disp(['Пользыватель ',num2str(SumBond(i,1)),' Кол-во связей ',num2str(SumBond(i,2))]);
    Bondi=M(SumBond(i,1),:);
    X=find(Bondi==1);
    if ~isempty(X)
        disp('Связан с: ');
        disp(X');
    end
end
disp(['Центральный(-е) по степини ',num2str((SumBond(SumBond(:,2)==max(SumBond(:,2))))')]);
%% Расчёт суммы кротчайших путей
distance(:,1)=1:1:length(M); distance(:,2)=0;
PatMhatrix{size(M,1),size(M,2)}=[];
Kolvo=zeros(size(M));
for i=1:1:size(M,1)
    for j=1:1:size(M,1)
        PatMhatrix{i,j} = shortestpath(G,i,j);
        PM{i,j}=PatMhatrix{i,j};
        distance(i,2) = distance(i,2)+(numel(PatMhatrix{i,j}));
        if ~isempty(PatMhatrix{i,j})
            if numel(PatMhatrix{i,j})~=1
                Kolvo(i,j)=1;
                A=PatMhatrix{i,j};
                PatMhatrix{i,j}=A(2:end);
            else
                PatMhatrix{i,j}=0;
            end
        else
            PatMhatrix{i,j}=0;
        end
    end
end
%% Расчёт центральности по близости
CC=distance;
CC(:,2)=ones(size(distance,1),1)./distance(:,2);
disp(['Цетральный(-е) по близости ',num2str((CC(CC(:,2)==max(CC(:,2))))')]);
%% Расчёт центральности по посредничеству
CB(:,1)=1:1:length(M);
CB(:,2)=centrality(G,'betweenness','Cost',G.Edges.Weight);
CB(:,2)=CB(:,2)./max(max(CB(:,2)));
disp(['Цетральный(-е) по посредничеству ',num2str((CB(CB(:,2)==max(CB(:,2))))')]);
%% Матреца интенсивности интенсивности
Intens=zeros(size(M));
for i=1:1:numel(M)
    if M(i)==1
        Intens(i)=rand;
    end
end
% Расчитать для всех нуливых
for i=1:1:size(Intens,1)
    for j=1:1:size(Intens,2)
        if i~=j
            if Intens(i,j)==0
                A=(PM{i,j});
                if mod(length(A),2)~=0
                    X=A(fix(length(A)/2)+1);
                else
                    X=A(fix(length(A)/2));
                    if X==0
                        A(fix(length(A)/2)+1)
                    end
                end
                Intens(i,j)=(Intens(i,X)*Intens(X,j)+(1-Intens(i,X))*(1-Intens(X,j)));
            end
        else
            Intens(i,j)=1;
        end
    end
end
% sum(Intens)
SumIntens(:,1)=1:1:length(Intens);
SumIntens(:,2)=sum(Intens)./(max(max(sum(Intens))));
disp(['Центральный(-е) по интенсивности ',num2str((SumIntens(SumIntens(:,2)==max(SumIntens(:,2))))')]);
%% Расчёт центраьного агента
CentSum(:,1)=SumIntens(:,1);
CentSum(:,2)=(SumIntens(:,2)+CB(:,2)+CC(:,2)+SumBond(:,2));
disp(['Центральный(-е) агент(-ы) ',num2str((CentSum(CentSum(:,2)==max(CentSum(:,2))))')]);
disp('Список центральности для всех агентов:');
disp('    id        Cent');
disp(CentSum);