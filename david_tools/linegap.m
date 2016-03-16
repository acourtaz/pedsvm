function linegap(coord,couleur)

i=1;
while i < size(coord,1)
    while (coord(i,2) == 0) & (i < size(coord,1))
        i = i+1;
    end
    j=i;
    while (coord(j,2) > 0) & (j < size(coord,1))
        j=j+1;
    end
    line(coord(i:j-1,2),coord(i:j-1,3),'color',couleur);
    i=j;
end
