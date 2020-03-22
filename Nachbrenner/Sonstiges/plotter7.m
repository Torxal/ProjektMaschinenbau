function plotter7
set(gca,'FontSize',12,'FontName', "Helvetica");
set(gca, 'ColorOrder', [1 0 0; 0.8500 0.3250 0.0980;0 0 0;0.4940    0.1840    0.5560], 'NextPlot', 'replacechildren');
xlabel('Zeit [s]','interpreter','latex');
ylabel('Massenstrom [kg/s]','interpreter','latex');
% Plotten Nichtlinearer Regler
 REGLERNL = evalin("base","Stell2");
 a = REGLERNL.time;
 b = REGLERNL.signals.values;
       plot(a,b(:,1),'LineWidth',1);
legend({'Stellgröße'},'Location','southeast');
saveas(gcf,'ges.png')
 end 


