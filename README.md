<div style="text-align:center;"><img src="https://raw.githubusercontent.com/mathiasquintero/Sweeft/master/logo.png" height=250></div>


# Sweeft
Swift but a bit Sweeter - More Syntactic Sugar for Swift

This is a collection of extensions and operators that make swift a bit sweeter. I have added these from multiple projects where I've been using these.

*Note:* These operators are supposed to help me in the way I write Swift. Which is a functional style.
So most of these regard possible problems and annoyances with functional programming in Swift.

**Please** Contribute to make Swift a bit cooler looking... Post your ideas in the issues as enhancements

## Installing Sweeft

Sweeft is available both as a Pod in Cocoapods and as a Dependency in the Swift Package Manager. So you can choose how you include Sweeft into your project.

### Cocoapods

Add 'Sweeft' to your Podfile:

```ruby
pod 'Sweeft'
```

### Swift Package Manager

Add 'Sweeft' to your Package.swift:

```Swift
import PackageDescription

let package = Package(
    // ... your project details
    dependencies: [
        // As a required dependency
        .Package(url: "ssh://git@github.com/mathiasquintero/Sweeft.git", majorVersion: 0)
    ]
)
```

## Why use Sweeft?

Sweeft allows you to make your code so much shorter.

For instance: let's say you have an array with some integers and some nil values.

```Swift
let array: [Int?]? = [1, 2, 3, nil, 5, nil]
```

And now you want to store all of the even numbers in a single array. Easy right:

```Swift
var even = [Int]()
if let array = array {
    for i in array {
        if let i = i, i % 2 == 0 {
            even.append(i)
        }
    }
}
```

Seems a bit too much.
Now those who know swift a bit better will tell me to write something more along the lines of:

```Swift
let even = (array ?? [])
            .flatMap { $0 }
            .filter { $0 & 1 == 0 }
```

But even that seems a bit too long. Here's that same code written using **Sweeft**:

```Swift
let even = !array.? |> { $0 & 1 == 0 }
```

Now to be clear, the last two solutions are following the same principles.

In this case first we are unwrapping the array with '.?'. Meaning that if it's nil we should get an empty array. Which in turn means: we unwrapped it safely.

Then we get rid of all the nil values from the array and cast it as a [Int] using the prefix '!'.
Finally we just call filter. But since our fingers are to lazy we spelled it '|>' ;)

### Still not convinced?

Ok. Another example:

Say you're really curious and want to know all the numbers from 0 to 1000 that are both palindromes and primes. Exciting! I know.

Well easy:

```Swift
let palindromePrimes = (0...1000).array |> { $0.isPalindrome } |> { $0.isPrime }
```

First we turn a range into an array that we can filter by using the '.array' property.
Then we filter out the non-palindromes.
And then we filter out the non-primes.

### Wow! You're a hard sell.

Ok. If you still are not sure if you should use Sweeft, see this example.

Say you're looping over an array:

```Swift
for item in array {
    // Do Stuff
}
```

And all of the sudden you notice that you're going to need the index of the item as well.
So now you have to use a range:

```Swift
for index in 0..<array.count {
    let item = array[index]
    // Do Stuff
}
```

But you still haven't accounted for the fact that this will crash if the array is empty:
So you need:

```Swift
if !array.isEmpty {
    for index in 0..<array.count {
        let item = array[index]
        // Do Stuff
    }
}
```

Ok... That's too much work for a loop. Instead you could just use '.withIndex' property of the array.

```Swift
for (item, index) in array.withIndex {
    // Do Stuff
}
```

Or even better. With the built in for-each operator:

```Swift
array => { item, index in
    // Do Stuff
}
```

I think we can all agree that's much cleaner looking.

## Usage

### Operators

#### (|) Pipe

Will pipe the left value to the function to the right. Just like in Bash:

```Swift
value | function
```

is the same as:

```Swift
function(value)
```

#### (=>) Map with

This will call map with the function to the right:

```Swift
array => function
```

is the same as:

```Swift
array.map(function)
```

#### (==>) FlatMap with

The same as above but with flatMap.

#### (|>) Filter with

The same as above but with filter

#### ( ** ) Drop input/output from function

Will cast a function to allow any input and drop it.

```Swift
**{
    // Do stuff
}
```

is the same as:

```Swift
{ _,_ in
    // Do stuff
}
```

or as a postfix it will drop the output

```Swift
{
    return something
}**
```

is equivalent to:

```Swift
{
    _ = something
}
```

#### (<-) Assignment of non-nil

Will assign b to a if b is not nil

```Swift
a <- b
```

is equivalent to:

```Swift
a = b ?? a
```

#### (<-) Assign result of map

Will assign the result of a map to an array.

```Swift
array <- handler
```

is equivalent to:

```Swift
array = array.map(handler)
```

If the handler returns an optional, but the array can't handle optionals then it will drop all of the optionals.

#### (<|) Assign result of filter

Will assign the result of a filter to the array

```Swift
array <| handler
```

is the same as:

```Swift
array = array.filter(handler)
```

#### (!) Will remove all the optional values from an array

```Swift
let array = [1, nil, 3]
!array // [1, 3]
```

#### (<=>) Will swap the values of two variables

```Swift
// a = 1 and b = 2
a <=> b // a = 2 and b = 1
```

#### (.?) Will unwrap an optional. Is not it will give the types default value

*Note:* the type has to conform to the *Defaultable* protocol.

```Swift
let i: Int? = nil
let j: Int? = 2

i.? // 0
j.? // 2
```

#### (??) Check for nil

Will check if a value is not nil


```Swift
??myVariable
```

is equivalent to:


```Swift
myVariable != nil
```
