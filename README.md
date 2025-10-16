# vParseStacked
I was reading about the forth programming language and this was the result of me experimenting with some stack-based ideas.


In this project im using a nim seq to represent the stack and it's values are objects that have fields for a char, string, int or float and these are then pushed/pulled to the stack between operations on their fields.

named values are added to a table (string, float) and passed as an argument to parseFormula along with the names which are then assigned to the stack elements when they are used.

It can parse formulas in this schema: 
["example*", "1/", "example2-", "example3"]

it is calculated from right to left

This could probably be improved by changing the seq to another type of array but i don't know when i'll get around to it so if you find some use for this feel free to use it!
