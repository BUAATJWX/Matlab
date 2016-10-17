function S = echo_creation(C,H,Yc,lambda,Lsar,Kr,Tr,Tau,Ra,Targets)
%Lsar �ϳɿ׾�����
%Tr �������ʱ��
%Tau ������ʱ������
%Ra ��λ���������
%Targets Ŀ����� ���� ��ʽΪ �У� x ��y��rcs  ���У�ÿ��Ŀ��
N = size(Targets,1);%Ŀ������
Nr = size(Tau,2);
Na = size(Ra,2);

S = zeros(Na,Nr);
for i = 1:N
    delta_x = Ra - Targets(i,1); %ƽ̨��Ŀ���x������
    delta_y = Yc;%y������
    delta_z = H;%z������
    
    range = sqrt(delta_x.^2 + delta_y^2 + delta_z^2);
    rcs = Targets(i,3);
    tau = ones(Na,1) * Tau - (2*range ./ C)' * ones(1,Nr); % ʱ������
    phase = pi * (-4 / lambda * (range' * ones(1,Nr)) + Kr * tau.^2);%�����ź���λ
    S = S + rcs * exp(1i * phase) .* ((abs(delta_x) < Lsar / 2)' * ones(1,Nr)) .* (tau > 0 & tau < Tr);
end

