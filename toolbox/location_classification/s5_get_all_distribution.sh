#!/usr/bin/env bash

cat << EOF > temp.py
#!/usr/bin/env python
import sys

if len(sys.argv) != 3:
    print('Command:', sys.argv[0], '[groove water index file]', '[surface water index file]')
    print('Check your parameters')
    exit()


with open(sys.argv[1], 'r') as file:
    groove_water = set(file.read().split())


with open(sys.argv[2], 'r') as file:
    origin_surface  = set(file.readline().split())
    origin_groove   = origin_surface & groove_water
    origin_backbone = origin_surface - groove_water
    count_groove    = 0
    count_backbone  = 0
    i = 1
    for line in file:
        now_surface     = set(line.split())
        groove_leave    = origin_groove - now_surface
        backbone_leave  = origin_backbone - now_surface
        origin_groove   = origin_groove & now_surface
        origin_backbone = origin_backbone & now_surface
        if i % 1000 != 0:
            count_groove   += len(groove_leave)
            count_backbone += len(backbone_leave)
        else:
            count_groove   += len(groove_leave)
            count_backbone += len(backbone_leave)
            print(i-500, count_groove)
            count_groove   = 0
            count_backbone = 0
        i += 1
exit()
EOF


