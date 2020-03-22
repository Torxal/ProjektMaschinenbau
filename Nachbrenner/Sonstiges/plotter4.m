function plotter4
set(gca,'FontSize',12,'FontName', "Helvetica");
set(gca, 'ColorOrder', [0 0 0; 0 0 1], 'NextPlot', 'replacechildren');
xlabel('Re');
ylabel('Im');
% Plotten Nichtlinearer Regler
 REGLERNL = evalin("base","REGLERNL");
 a = REGLERNL.time;
 b = REGLERNL.signals.values;
       plot([-437.5386 -0.0526 -0.0024],[0 0 0],'o',[-416.7034 -0.0053 -0.0023],[0 0 0], 'X','MarkerSize',15);
legend({'Berechnete Eigenwerte','Verschobene Eigenwerte'},'Location','southeast');
saveas(gcf,'Vergleich.png')

 end 

