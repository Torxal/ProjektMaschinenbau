function plotter3
set(gca,'FontSize',12,'FontName', "Helvetica");
set(gca, 'ColorOrder', [0.4660    0.6740    0.1880;0.3010    0.7450    0.9330; 0.6350    0.0780    0.1840], 'NextPlot', 'replacechildren');
xlabel('Zeit [s]','interpreter','latex');
ylabel('Temperatur [K]','interpreter','latex');
% Plotten Nichtlinearer Regler
 c = evalin("base","linearisiert");
 a = c.time;
 b = c.signals.values;
       plot(a,b(:,1), a, b(:,2),a, b(:,3),'LineWidth',1);
legend({'Brenner', ...
    'Wärmetauscherausgang','Brennerwand'},'Location','southeast');
saveas(gcf,'Linearisiert.png')

 end 

