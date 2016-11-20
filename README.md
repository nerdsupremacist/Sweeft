# Sweeft
Swift but a bit Sweeter - More Syntactic Sugar for Swift

This is a collection of extensions and operators that make swift a bit sweeter. I have added these from multiple projects where I've been using these.

*Note:* These operators are supposed to help me in the way I write Swift. Which is a functional style.
So most of these regard possible problems and annoyances with functional programming in Swift.

## Installing

To add this to your project you have to add this to your Podfile:

```ruby
pod Sweeft
```

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

#### (.?) Check for nil

Will check if a value is not nil


```Swift
.?myVariable
```

is equivalent to:


```Swift
myVariable != nil
```
