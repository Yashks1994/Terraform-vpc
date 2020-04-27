a = [5,2,6,4,6,5,-6,26,45,2,56,623]

for i in range(len(a)):
    for j in range(i+1, len(a)):
        if a[i] > a[j]:
            a[i], a[j] = a[j], a[i]

https://yash.com
print(a)

Localhost

New