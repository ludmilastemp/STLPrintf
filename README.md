# STLPrintf ♥
### I wrote my print, and it’s cooler than the standard one!

Specifiers that my printf supports:

|Specifier|Explanation|
|---|---|
|%|Literal percentage |
|c|Single character|
|s|Character string|
|d|Signed integer|
|b|Byte representation|
|o|Octal representation|
|x|Hex representation|

Examples:

```
printf    ("%d %s %x %d %%%c%b\n", -1, "love", 3802, 100, 33, 31);
STLPrintf ("%d %s %x %d %%%c%b\n", -1, "love", 3802, 100, 33, 31);
```
```
-1 love eda 100 %!b
-1 love EDA 100 %!11111
```
