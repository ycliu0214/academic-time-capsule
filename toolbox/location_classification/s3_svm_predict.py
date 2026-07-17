#!/usr/bin/env python
from sklearn import svm

#read training data set
name = []
feature = []
label = []
for i in range(1,5):
    with open('training_set/grp'+str(i)+'.dat', 'r') as f:
        for line in f:
            data = line.split()
            name.append(data[0])
            feature.append([float(j) for j in data[1:]])
            label.append(i)


clf = svm.SVC(kernel='rbf', tol=0.0001)
clf.fit(feature, label)

pred_name = []
pred_feature = []
with open('unknown_groove_water.txt', 'r') as f:
    for line in f:
        data = line.split()
        pred_name.append(data[0])
        pred_feature.append([float(j) for j in data[1:]])
result = clf.predict(pred_feature)

with open('narrow_0/index_list.txt', 'w') as f1, open('middle_90/index_list.txt', 'w') as f2,\
     open('wide_180/index_list.txt', 'w') as f3, open('middle_270/index_list.txt', 'w') as f4:
    for i in range(len(result)):
        if result[i] == 1:
            f1.write(pred_name[i]+"\n")
        elif result[i] == 2:
            f2.write(pred_name[i]+"\n")
        elif result[i] == 3:
            f3.write(pred_name[i]+"\n")
        elif result[i] == 4:
            f4.write(pred_name[i]+"\n")

exit()

