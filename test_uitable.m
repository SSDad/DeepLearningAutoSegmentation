clearvars

t = readtable("patients.xls");
vars = ["Age","Systolic","Diastolic","Smoker"];
t = t(1:15,vars);

fig = uifigure;
uit = uitable(fig,"Data",t,"Position",[20 20 350 300]);

uit.ColumnEditable = [false false true true];