function plotter1
set(gca,'FontSize',12,'FontName', "Helvetica");
set(gca, 'ColorOrder', [1 0 0; 0.8500 0.3250 0.0980;0 0 0;0.4940    0.1840    0.5560], 'NextPlot', 'replacechildren');
xlabel('Zeit [s]','interpreter','latex');
ylabel('Temperatur [K]','interpreter','latex');
% Plotten Nichtlinearer Regler
 REGLERNL = evalin("base","REGLERNL");
 a = REGLERNL.time;
 b = REGLERNL.signals.values;
       plot(a,b(:,1), a, b(:,2),a, b(:,3),'LineWidth',1);
legend({'Brenner', ...
    'Wärmetauscherausgang','Brennerwand'},'Location','southeast');
saveas(gcf,'Vergleich.png')

 end 

