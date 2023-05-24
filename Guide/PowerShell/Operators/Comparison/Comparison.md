It's if statements all the way down my dudes!

No matter what level of programing you are doing comparisons will be required.

Also, like most things in the world, comparisons can be split into separate categories:
- Equality: Not all things are created equal, and these operators will help you identify them.
- Matching: Some things are "kind of equal" and a lot of times that is good enough.
- Replacement: Wouldn’t it be nice if everything was exactly how we expected it to be? Well, we can at least try to make it that way.
- Containment: We’re not talking about aliens or monsters here; we are talking arrays.
- Type: And finally, sometimes you just need to know if they are the same type 

# Univeral Constants
Well PowerShell constants that is.

All string comparisons are case-insensitive by default, but have the ability to be changed to case-sensitive.

Not all comparisons return a Boolean value. These will be addressed in the individual sections where applicable.

# Using comparisons

You use comparisons any time you need to compare two things. 

The End. Okay fine, how about some examples?

Some of the most common places you will see Comparison operators are in if/else statements and Where clauses. 

~~~PowerShell
If($a -eq $b){
    Write-Host 'They are equal'
}
~~~

~~~PowerShell
Get-Service | Where-Object { $_.Name -eq 'pwsh' }
~~~

Both of these examples are looking for instances where the values are equal. There are many other types of comparisons that we will go in-depth on later.

# Fun with comparisons
Comparisons in PowerShell do not always return Boolean (true/false) values. And sometime what you think will be true will be false or visa-versa.

If for instance, if you compare an array with against a single value, it will return the values that match. However, if you reverse it, it will do nothing.

~~~PowerShell
1,2,3 -eq 1
1 -eq 1,2,3
~~~

If you compare an integer and string, and the string can be converted to an integer, it will do so for you.

So, all the following would be true:

~~~PowerShell
1 -eq 1
1 -eq '1'
1 -eq '1.0'
~~~

And all of the following with return false:

~~~PowerShell
1 -eq 2
1 -eq 'One'
1 -eq '#2.0'
~~~

It's smart, but not that smart.

## To Boolean or not to Boolean
Along with converting strings to integers PowerShell can convert string and integer to Boolean values.

So again all the following will return true:

~~~PowerShell
$true  -eq $true
'true' -eq $true
1      -eq $true
~~~

The reson the last one works is because True is 1 and False is 0. Any other number in there will have produce a false comparison.

And all of the following with return false:

~~~PowerShell
$false  -eq $true
'word'  -eq $true
0       -eq $true
'0'     -eq $true
'2.0'   -eq $true
2       -eq $true
'false' -eq $true
' '     -eq $true
~~~

### O, beware, my lord, of Boolean ordering*
If you put $true or $false on the left side of you comparison you are no longer checking for straight Boolean matches. You are checking for the existence of a value.

For instance, while `'false' -eq $true` returns false, `$true -eq 'false'` would return true.

In the first case, PowerShell converts 'false' to `$false`, but in the second case any values other than `$false`, `0`, or `$null` will return true because it is checking for existence.

So, in this case all of the examples below will return true.


~~~PowerShell
$true -eq 'word'
$true -eq '0'
$true -eq '2.0'
$true -eq 2
$true -eq 'false'
$true -eq ' '
~~~

Confused yet? Don't worry, just follow the rule of `$true` and `$false` to the right and you'll be alright.

*That's right I snuck in two Shakespeare references while discussing Boolean