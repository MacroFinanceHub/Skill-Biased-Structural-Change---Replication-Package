GObundle=TotalRequirements*PCEmatrix;
VAratio=sum(VAvectorfromDRtable(:,:),1)'
for i=1:76
VAbundle(:,i)=GObundle(:,i).*VAratio;
HsectbundleVA(i)=HsectFracH(:,1)'*(GObundle(:,i).*VAratio);
end
dataforCEXmergeVA=[PCEcodes HsectbundleVA]

laborshare=VAvectorfromDRtable(1,:)'

for i=1:76
Hsectbundle(i)=HsectFracH(:,1)'*(GObundle(:,i).*laborshare);
sectortotal=Hsectbundle(i)+Lsectbundle(i);
Hsectbundle(i)=Hsectbundle(i)/sectortotal;
end
dataforCEXmergeNew=[PCEcodes Hsectbundle]
save skillVA.mat
