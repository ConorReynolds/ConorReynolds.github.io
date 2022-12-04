#lang pollen

◊(define-meta title "Dafny Lab Sheet 2 (Draft)")
◊(define-meta toc-title "Dafny Lab Sheet 2: Termination and Simple Invariants")
◊(define-meta subtitle "Termination and simple invariants")
◊(define-meta math? #true)
◊(define-meta created "2022-12-03")

You can skip to the ◊xref["resources/dafny-02.html#Question 1"]{lab questions} if you're in a hurry, but as always I recommend reading the succeeding sections as they give good context for the lab.

◊section{Termination}

We have so far only concerned ourselves with proving the ◊em{partial correctness} of programs. A program is partially correct when it gives the right result whenever it terminates. To prove ◊em{total correctness}, we must prove that it is partially correct ◊em{and} that it always terminates.

Why worry about termination? Besides the obvious issues with code that loops forever, there are even deeper issues. Consider the following method in Dafny for computing the square root of a real number ◊${a \in \R}.

◊codeblock['dafny]{
  method Sqrt(a: real) returns (x: real)
      decreases *  // disables termination check
      ensures x * x == a
  {
      while x * x != a
          decreases *  // disables termination check
      {
          // do nothing!
      }
  }
}

Dafny accepts this. Why? Because ◊em{if} the loop ever terminates, its loop condition must be false. If ◊${x^2 \neq a} is false, then ◊${x^2 = a} is true, so ◊${x} must be a square root of ◊${a}. This code is therefore partially correct. But it also doesn't do anything.

We will insist on total correctness for the remainder of this course. There are two situations where you must prove termination: loops and recursive functions. To prove termination, you must show that some value bounded from below strictly decreases with each recursive call or each iteration of a loop. Dafny is normally pretty good at figuring this out for you, but it will occasionally require some help. See the ◊extlink["http://dafny.org/dafny/DafnyRef/DafnyRef#sec-loop-termination"]{Dafny documentation on loop termination} for more details.

◊section{Functions vs Methods}

From outside a method's body, Dafny's verifier can only see the specification and not the code itself. However, Dafny's verifier can always see the contents of a function. To illustrate this, consider the following function and method:

◊codeblock['dafny]{
  function AbsDef(x: int): int
  {
      if x < 0 then -x else x
  }

  method Abs(x: int) returns (r: int)
  {
      if x < 0 {
          r := -x;
      } else {
          r := x;
      }
  }
}

Both do exactly the same thing, but we have not provided preconditions or postconditions for either. Now try this:

◊codeblock['dafny]{
  method {:main} Main()
  {
      var x := AbsDef(-3);
      assert x > 0;

      var y := Abs(-3);
      assert y > 0;
  }
}

The first assertion succeeds, but the second fails, since Dafny's verifier can see the definition of ◊code{AbsDef}, but not ◊code{Abs}. Now try to print the two variables by writing ◊code{print x} and ◊code{print y}. Dafny will happily print ◊code{y}, but not ◊code{x}. This is because Dafny functions are by default ◊em{ghost}---they can only be used in specification contexts.

This means that functions can be used to specify the behaviour of methods. This pattern is common and powerful. For example:

◊codeblock['dafny]{
  function AbsDef(x: int): int
      ensures AbsDef(x) >= 0  // unnecessary, but does no harm
  {
      if x < 0 then -x else x
  }

  method Abs(x: int) returns (r: int)
      ensures r == AbsDef(x)  // ✓ succeeds
  {
      if x < 0 {
          r := -x;
      } else {
          r := x;
      }
  }
}

This is quite a bit clearer than the following more explicit specification for the absolute value function we gave in ◊xref["resources/dafny-01.html"]{lab 1}.

◊codeblock['dafny]{
  ensures r >= 0
  ensures r == x || r == -x
}

This is not a particularly interesting example, since the specification and the code are not meaningfully different. We will see more interesting examples in the later labs.

◊section{Some Useful Collections}

Dafny supports sets, multisets, sequences, and (in)finite maps. These types can be useful for specifying program behaviour. In particular, I want to draw your attention to ◊em{sequences}, because they're extremely useful for specifying properties of arrays.

Normally, to specify that some element ◊code{e} is found in some array ◊code{a}, one must say that there exists an ◊code{i} such that ◊code{0 <= i < a.Length} and ◊code{a[i] == e}. But it's much easier to just convert ◊code{a} to a sequence by writing ◊code{a[..]}, and then ask if ◊code{e in a[..]}. That is to say, the following two predicates are exactly the same.

◊codeblock['dafny]{
  predicate elem(a: array<int>, e: int)
  {
      exists i | 0 <= i < a.Length :: a[i] == e
  }

  predicate elem(a: array<int>, e: int)
  {
      e in a[..]
  }
}

Check out the online ◊extlink["https://dafny-lang.github.io/dafny/OnlineTutorial/Sequences.html"]{Dafny documentation} for more information on sequences.

◊section{Common Loop Invariants}
Similarly to the way that Dafny cannot see 'inside' methods, neither can it see inside loops. Most automatic verifiers need an awful lot of help seeing what a loop is supposed to be doing. Loop invariants are a specification of that behaviour.

A common invariant looks something like this.

◊codeblock['dafny]{
  while i < n
    invariant 0 <= i <= n
}

This instructs Dafny to check that, whatever happens in the loop, ◊${i} should remain between ◊${0} and ◊${n}.

The body of the loop will usually say something like ◊code{i := i + 1}, but Dafny can't do anything with this information unless you provide an invariant. Usually you will want to conclude that ◊${i = n} once the loop finishes, but all Dafny will know is the negation of the loop condition, which is ◊${i \geq n}. In order to conclude ◊${i = n}, Dafny needs an upper bound on ◊${i}, specifically ◊${i \leq n}.

Note that counting down to zero often does not require nearly as much care. If ◊${i} is declared ◊code{nat}, then Dafny already knows that it must check that ◊${i \ge 0}.

◊section{Ghost and Compiled Constructs}

All of Dafny's specification constructs are called ◊em{ghosts}. The reason for this is that specifications do not appear in the compiled code. The verifier takes into account ghost and non-ghost constructs in order to prove correctness, but your computer does not need to know anything about the specification for a program in order to execute it. They are ◊em{erased} at compile-time. We will therefore refer to non-ghost constructs as ◊em{compiled}.

There are two main types of 'simple' top-level declarations in Dafny: methods and functions. Methods contain imperative code, functions contain functional code. Methods are compiled by default. Functions are ghost by default. If a method is ghost, it's a lemma. If a function is compiled, it's a function method. If a function is boolean-valued, it's a predicate.

◊section{Recursive Algorithms}
A recursive algorithm is any algorithm which makes a call to itself in its own definition. Some problems can be solved by dividing them into smaller sub-problems and combining the results. These algorithms can usually be expressed recursively.

Consider the problem of sorting a list of numbers. If I have two lists, both of which are sorted, I can easily merge them into one list which is itself sorted: walk through both lists at once and take the smaller element from each to construct the new list. If I have a singleton list, that is automatically sorted. That sounds like a fine sorting algorithm to me. Let's try it out. 

◊codeblock['dafny]{
  function method merge(a: seq<int>, b: seq<int>): seq<int>
  {
      if a == [] then b else
      if b == [] then a
      else
        if a[0] < b[0] then
          [a[0]] + merge(a[1..], b)
        else
          [b[0]] + merge(a, b[1..])
  }

  function method sort(s: seq<int>): seq<int>
  {
      if |s| <= 1 then s
      else
        var mid := |s| / 2;
        merge(sort(s[..mid]), sort(s[mid..]))
  }
}

Try this out if you like.

◊section{Question 1}

Rewrite your ◊code{Max} and ◊code{Min} methods from last week to use the following functions as part of their specification. (See the previous section on ◊xref["resources/dafny-02.html#Functions vs Methods"]{functions vs methods}.)

◊codeblock['dafny]{
  function max(a: int, b: int): int
  {
      if a > b then a else b
  }

  function min(a: int, b: int): int
  {
      if a < b then a else b
  }
}

◊section{Question 2}

Define a recursive function which computes ◊${2^n} for any ◊${n \in \N}. Consider ◊${n = 0} and ◊${n > 0} as separate cases.

◊codeblock['dafny]{
  function pow2(n: nat): nat
  {
      if n == 0 then
          // todo
      else
          // todo
  }
}

Generalise this function to compute ◊${a^n} for any ◊${a \in \Z} and ◊${n \in \N}.

◊section{Question 3}

Write a method which computes ◊${a^n} for any ◊${a \in \Z} and ◊${n \in \N}. Use the function you defined in the previous question as part of its specification.

◊codeblock['dafny]{
  method Pow(a: int, n: nat) returns (result: int)
      // needs postcondition
  {
      // todo
      
      var i := 0;
      while i < n
          invariant 0 <= i <= n
          // needs another invariant
      {
          // todo
          i := i + 1;
      }
  }
}

◊section{Question 4}

Euclid detailed an algorithm in his ◊em{Elements} for computing the greatest common divisor (GCD) of two natural numbers. It works by noticing that the GCD of ◊${a} and ◊${b}, where ◊${a < b}, is the same as the GCD of ◊${a} and ◊${b - a}. We can therefore calculate the GCD of any two non-zero natural numbers by repeating this process until we reach the case ◊${\gcd(a, a) = a}. This can be specified in Dafny as follows.

◊codeblock['dafny]{
  function gcd(a: int, b: int): int
      requires a > 0 && b > 0
  {
      if a == b then
        a
      else if b > a then
        gcd(b - a, a)
      else
        gcd(b, a - b)
  }
}

Unfortunately, Dafny cannot prove that this algorithm terminates. Provide a decreases clause for this function to prove that it terminates. (Hint: You are looking for an expression involving ◊${a} and ◊${b} which strictly decreases each time the function is called recursively.)

◊section{Question 5}

The code below specifies an incomplete predicate and method for binary search through an array. You may assume that the code is correct and does not need changing. Complete the specification by fixing the commented-out lines. ◊aside{Note that this method uses the standard convention of returning ◊${-1} if the value could not be found.}

◊codeblock['dafny]{
  predicate sorted(a: array<int>)
      reads a
  {
      // forall i, j | 0 <= i < j < a.Length :: ...
  }

  method BinarySearch(a: array<int>, value: int) returns (index: int)
      requires sorted(a)
      ensures index == -1 || 0 <= index < a.Length
      // ensures index == -1 ==> ...
      // ensures index >= 0  ==> ...
  {
      var low := 0;
      var high := a.Length;

      while low < high
          invariant 0 <= low <= high <= a.Length
          invariant value !in a[..low] && value !in a[high..]
      {
          var mid := (high + low) / 2;

          if a[mid] < value {
              low := mid + 1;
          } else if a[mid] > value {
              high := mid;
          } else {
              return mid;
          }
      }
      index := -1;
  }
}

Note that the statement

◊codeblock['dafny]{
  forall x, y | P :: Q
}

means 'for all ◊${x} and ◊${y} such that ◊${P}, we have ◊${Q}', or ◊${\forall x, y.\ P \to Q} in mathematical syntax.

◊; % ◊section{Extras: Coinduction and Corecursion}
◊; % Some programs are not supposed to terminate, like a web server handling requests. How can we reason formally about programs that do not terminate? The answer is to consider the 'duals' to induction and recursion: ◊em{coinduction} and ◊em{corecursion}.

◊; % Consider the following stream type and some associated functions for describing the Fibonacci sequence ◊${0, 1, 1, 2, 3, 5, 8, \dots}.
◊; % \begin{lstlisting}[language=dafny]
◊; % codatatype IStream<T> =
◊; %     ICons(head: T, tail: IStream)

◊; % function fibsFrom(a: nat, b: nat): IStream<nat>
◊; % {
◊; %     ICons(a, fibsFrom(b, a + b))
◊; % }

◊; % function fibs(): IStream<nat>
◊; % {
◊; %     fibsFrom(0, 1)
◊; % }
◊; % \end{lstlisting}
◊; % This is a complete specification of the Fibonacci sequence. Here is a recursive specification:
◊; % \begin{lstlisting}[language=dafny]
◊; % function fibs_rec(n: nat): nat
◊; % {
◊; %     if n == 0
◊; %       then 0
◊; %     else if n == 1
◊; %       then 1
◊; %     else
◊; %       fibs_rec(n - 1) + fibs_rec(n - 2)
◊; % }
◊; % \end{lstlisting}
◊; % The recursive specification says how to break the problem into smaller pieces, and gives a direct solution for the two smallest numbers, ◊${0} and ◊${1}. Dually, the corecursive specification explains how to build larger results using smaller results, and gives us a starting point, ◊${0} and ◊${1}. Both adequately describe the sequence.

◊; % Corecursively, I might say \textquote{to generate the Fibonacci sequence, start with ◊${0} and ◊${1}---each subsequent number in the sequence is the sum of the previous two.} Recursively, I might say \textquote{the ◊${n}th Fibonacci number is the sum of the previous two Fibonacci numbers---the first two such numbers are ◊${0} and ◊${1}.}

◊; % Corecursive functions are obligated to be ◊em{productive}, which is a technical requirement analogous to termination. To show that a recursive function terminates, we have to show that it really does break the problem into \textquote{smaller} pieces. To show that a corecursive function is productive, we have to show that it really does construct \textquote{larger} pieces from \textquote{smaller} ones.
