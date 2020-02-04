function filtered = mysgf(order, framelen, y)

m = (framelen-1)/2;

[B,g] = sgolay(order,framelen);

steady = conv(x,B(m+1,:),'same');

ybeg = B(1:m,:)*x(1:framelen);
yend = B(framelen-m+1:framelen,:)*x(lx-framelen+1:lx);

cmplt = steady;
cmplt(1:m) = ybeg;
cmplt(lx-m+1:lx) = yend;


end