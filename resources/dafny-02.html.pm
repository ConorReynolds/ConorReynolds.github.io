#lang pollen

◊(define-meta title "Dafny Lab Sheet 2")
◊(define-meta toc-title "Dafny Lab Sheet 2: Termination and Simple Invariants")
◊(define-meta subtitle "Termination and simple invariants")
◊(define-meta math? #true)
◊(define-meta created "2022-12-03")

You can skip to the ◊xref["#Question 1"]{lab questions} if you're in a hurry, but as always I recommend reading the following sections as they give good context for the lab.

◊note{
  Code snippets can be copied by hovering over the snippet and clicking the ◊i[#:class "fa fa-copy" #:style "margin: 0 0.1em 0 0.1em; color: var(--muted-color);"] button which appears on the top right.
  
  Some snippets are declared as files---those can be downloaded directly by clicking the ◊i[#:class "fa fa-download" #:style "position: relative; margin: 0 0.1em 0 0.1em; top: -0.05em; font-size: 0.9em; color: var(--muted-color);"] button next to the filename.
}

◊section{Functions vs Methods}

From outside a method's body, Dafny's verifier can only see the specification for that method, and not the code inside the method. But the verifier can always see the contents of a function. To illustrate this, consider the following function and method:

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

The first assertion succeeds, but the second fails, since Dafny's verifier can see the definition of ◊code{AbsDef}, but not ◊code{Abs}. This means that functions can be used to specify the behaviour of methods. ◊aside{Functions which exist ◊em{only} to specify the behaviour of methods can be marked 'ghost' so they are erased at compile time---more on this ◊xref["#Ghost and Compiled Constructs"]{later}.} This pattern is common and powerful. For example:

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

This is a bit clearer and less error-prone than the following more explicit specification for the absolute value function we gave in ◊xref["resources/dafny-01.html#Instructions"]{lab 1}.

◊codeblock['dafny]{
  ensures r >= 0
  ensures r == x || r == -x
}

Since the specification and the code are not meaningfully different in this case, this example isn't of much technical interest. We will see more interesting examples in the later labs.

◊section{Some Useful Collections}

Dafny supports sets, multisets, sequences, and (in)finite maps. These types can be useful for specifying program behaviour. In particular, I want to draw your attention to ◊em{sequences}, because they're extremely useful for specifying properties of arrays.

Normally, to specify that some element ◊code{e} is found in some array ◊code{a}, one must say that there exists an ◊code{i} such that ◊code{0 <= i < a.Length} and ◊code{a[i] == e}. But it's much easier to just convert ◊code{a} to a sequence by writing ◊code{a[..]}, and then ask if ◊code{e in a[..]}. That is to say, the following two predicates are exactly the same.

◊codeblock['dafny]{
  predicate elem(a: array<int>, e: int)
      reads a
  {
      exists i | 0 <= i < a.Length :: a[i] == e
  }

  predicate elem(a: array<int>, e: int)
      reads a
  {
      e in a[..]
  }
}

Check out the online ◊extlink["https://dafny-lang.github.io/dafny/OnlineTutorial/Sequences.html"]{Dafny documentation} for more information on sequences.

◊section{Termination}

We have so far only concerned ourselves with proving the ◊em{partial correctness} of programs. A program is partially correct when it gives the right result whenever it terminates. To prove ◊em{total correctness}, we must prove that it is partially correct ◊em{and} that it always terminates.

Why worry about termination? Besides the obvious issues with code that loops forever, nonterminating code can satisfy specifications without actually computing the correct result. As an example, consider the following method in Dafny for computing the square root of a real number ◊${a \in \R}.

◊codeblock['dafny]{
  method Sqrt(a: real) returns (x: real)
      decreases *  // disables termination check
      ensures x * x == a
  {
      x := *;  // ‘indefinite’ assignment
      while x * x != a
          decreases *  // disables termination check
      {
          // do nothing!
      }
  }
}

Dafny accepts this. Why? Because ◊em{if} the loop ever terminates, its loop condition must be false. If ◊${x^2 \neq a} is false, then ◊${x^2 = a} is true, so ◊${x} must be a square root of ◊${a}. This code is therefore partially correct. But it also doesn't do anything.

We will insist on total correctness for the remainder of this course. There are two situations where you must prove termination: loops and recursive functions/methods. To prove termination, you must show that some expression bounded from below strictly decreases with each recursive call or each iteration of a loop. Dafny can often figure this out if the expression is simple, but it will occasionally require some help. See the ◊extlink["http://dafny.org/dafny/DafnyRef/DafnyRef#sec-loop-termination"]{Dafny documentation on loop termination} for more details.

For example, consider the following function.

◊codeblock['dafny]{
  function interleave(a: seq<int>, b: seq<int>): seq<int>
  {
      if a == [] then
        b
      else
        [a[0]] + interleave(b, a[1..])
  }
}

This function will interleave two sequences together. Here is an example of how it works:

◊codeblock['text]{
    interleave([1, 2], [7, 8])
    = [1] + interleave([7, 8], [2])
    = [1] + [7] + interleave([2], [8])
    = [1] + [7] + [2] + interleave([8], [])
    = [1] + [7] + [2] + [8] + interleave([], [])
    = [1] + [7] + [2] + [8] + []
    = [1, 7, 2, 8]
}

Dafny cannot automatically prove termination for this function. Why?

By default, Dafny will guess that one of the parameters to the function decreases---so, in this case, it tries ◊code{decreases a, b}. This means that it will first try to prove that the first parameter decreases, and if it can't, it will try to prove that the second parameter decreases.

Be careful here: when deciding if, for example, ◊code{a} is decreasing, we're not comparing ◊code{a} and ◊code{a[1..]}, we're comparing the original function call's first parameter with the first parameter of the recursive call.

Let's see what this means in practice. If the function is called like:

◊codeblock['dafny]{
  interleave(a, b)
}

... then, assuming we're not at the base case, the recursive call is:

◊codeblock['dafny]{
  interleave(b, a[1..])
}

Dafny first tries to prove that ◊code{b} is smaller than ◊code{a}. Can it? No---nothing is known about the relative sizes of ◊code{a} and ◊code{b}. Then, it tries to prove that ◊code{a[1..]} is smaller than ◊code{b}. Can it? Again, no, for the same reasons.

The problem is that we're comparing the wrong things. The intuitive reason that this function terminates is because, at each recursive call, the ◊em{total} number of elements to process decreases. Can you use that information to provide an expression that strictly decreases at each step? (You may want to consult the ◊extlink["http://dafny.org/dafny/OnlineTutorial/Sequences.html"]{documentation on sequences}.)

◊section{Common Loop Invariants}

Most automatic verifiers need an awful lot of help seeing what a loop is supposed to be doing. Loop invariants are a specification of that behaviour.

Finding loop invariants is a difficult problem in general---there is no general method for finding them. But some invariants crop up over and over again, and are worth remembering.

One such invariant looks something like this.

◊codeblock['dafny]{
  while i < n
    invariant 0 <= i <= n
}

This instructs Dafny to check that ◊${i} is between ◊${0} and ◊${n} before the loop begins and stays there after each iteration. This is useful when you have a loop that uses ◊${i} to count up from ◊${0} to ◊${n}. If you don't include this invariant, then Dafny won't know what is true about ◊${i} besides the negation of the loop condition, which is ◊${i \ge n}. Usually you will need to conclude that ◊${i = n} once the loop finishes. In order to do so, Dafny needs an upper bound on ◊${i}, specifically ◊${i \leq n}.

The lower bound on ◊${i} is generally not necessary, especially if ◊${i} is a ◊code{nat}, since Dafny must always check ◊${i \ge 0}. For this reason, counting down typically does not require an invariant like this.

◊section{Ghost and Compiled Constructs}

All of Dafny's specification constructs are called ◊em{ghosts}. The reason for this is that specifications do not appear in the compiled code. The verifier takes into account ghost and non-ghost constructs in order to prove correctness, but your computer does not need to know anything about the specification for a program in order to execute it. They are ◊em{erased} at compile-time. We will therefore refer to non-ghost constructs as ◊em{compiled}.

There are two main types of 'simple' top-level declarations in Dafny: methods and functions. Methods contain imperative code, functions contain functional code. Methods and functions are both compiled by default (as of Dafny 4). Functions can be marked ghost, unsurprisingly, by declaring them as a ◊code{ghost function}. If a method is ghost, it's called a ◊em{lemma}. Boolean-valued functions can instead be declared as ◊em{predicates}---these are also compiled by default, and must be marked ghost if you want them to be erased at compile time.

◊hrule

◊section{Question 1}

Rewrite your ◊code{Max} and ◊code{Min} methods from the previous lab to use the following functions as part of their specification. (See the previous section on ◊xref["#Functions vs Methods"]{functions vs methods}.)

◊codeblock['dafny]{
  function MaxDef(a: int, b: int): int
  {
      if a > b then a else b
  }

  function MinDef(a: int, b: int): int
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

Unfortunately, Dafny cannot prove that this algorithm terminates. Provide a decreases clause for this function to prove that it terminates. (Hint: You are looking for an expression involving ◊${a} and ◊${b} which strictly decreases each time the function is called recursively. You might want to read the section on ◊xref["#Termination"]{termination} if you haven't already.)

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
