function plotter5
set(gca,'FontSize',12,'FontName', "Helvetica");
set(gca, 'ColorOrder', [1 0 0; 0.8500 0.3250 0.0980;0 0 0;0.4940    0.1840    0.5560;0.4660    0.6740    0.1880;0.3010    0.7450    0.9330; 0.6350    0.0780    0.1840], 'NextPlot', 'replacechildren');
xlabel('Zeit [s]','interpreter','latex');
ylabel('Temperatur [K]','interpreter','latex');
% Plotten Nichtlinearer Regler
 c = evalin("base","REGLERNL");
 a = c.time;
 b = c.signals.values;
       plot(a,b(:,1), a, b(:,2),a, b(:,3), a, b(:,4),a, b(:,5),a, b(:,6),'LineWidth',1);
legend({"Brenner gestört",'Wärmetauscher (Ausgang) gestört','Brennerwand gestört','Brenner ungestört', ...
    'Wärmetauscher (Ausgang) ungestört','Brennerwand ungestört'},'Location','southeast');
saveas(gcf,'Modell.png')

 end 

