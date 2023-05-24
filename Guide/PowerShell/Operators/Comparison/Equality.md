You will most like use Equality comparisons more than any other comparison in PowerShell. 

In short, they are the same things you learned in 1st grade how to tell is somethig is the same, more, or less. So, I won't bore you will an explanation of what less than means.

Or in PowerShell speak:
- -eq : equals
- -ne : not equals
- -gt : greater than
- -ge : greater than or equal
- -lt : less than
- -le : less than or equal

# Do be so sensetivity
As mentioned in the Comparison overview, all string comparisons in PowerShell are case-insensitive. This means that according to PowerShell the following is true.

~~~PowerShell
'PowerShell' -eq 'powershell'
~~~

However, there are times when you do what to check casing. In these situations, you can add the letter `C` to any of the Equality operators to make it case-sensitive. 

So now our previous example will be false.

~~~PowerShell
'PowerShell' -ceq 'powershell'
~~~

# What the I
Just like `C` makes the comparison case-sensitive, the letter `I` makes it case-insensitive.

Now, if you are like me, the first thing that comes to mind is, “why would I ever need that if PowerShell is case-insensitive to begin with?”

The short answer is...you don’t.

The correct answer is...I can be helpful in situations where you have a mixture of case-sensitive and insensitive comparisons. You can throw that I in there as pseudo documentation of what the comparison is doing. (Full disclosure, I have never once used the `I`).
