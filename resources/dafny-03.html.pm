#lang pollen

◊(define-meta title "Dafny Lab Sheet 3")
◊(define-meta toc-title "Dafny Lab Sheet 3: Loops and Loop Invariants")
◊(define-meta subtitle "Loops and loop invariants")
◊(define-meta math? #true)
◊(define-meta created "2023-09-04")

You can skip to the ◊xref["#Question 1"]{lab questions} if you're in a hurry, but as always I recommend reading the following sections as they give good context for the lab. For this lab you should also keep in mind the documentation for ◊extlink["http://dafny.org/dafny/OnlineTutorial/Sequences"]{sequences}, ◊extlink["http://dafny.org/dafny/OnlineTutorial/ValueTypes#multisets"]{multisets}, and ◊extlink["http://dafny.org/dafny/OnlineTutorial/ValueTypes"]{value types} in general.

◊note{
  Code snippets can be copied by hovering over the snippet and clicking the ◊i[#:class "fa fa-copy" #:style "margin: 0 0.1em 0 0.1em; color: var(--muted-color);"] button which appears on the top right.
  
  Some snippets are declared as files---those can be downloaded directly by clicking the ◊i[#:class "fa fa-download" #:style "position: relative; margin: 0 0.1em 0 0.1em; top: -0.05em; font-size: 0.9em; color: var(--muted-color);"] button next to the filename.
}

◊section{Loop Specifications}

To fully specify a loop, you must provide two things: a termination metric and a loop invariant. Dafny can usually deduce the termination metric automatically, but it cannot guess the loop invariant, for the same reason that it cannot guess arbitrary postconditions for methods: It's up to you to decide what your code should be doing.

Consider the following invariant specification.

◊codeblock['dafny]{
  while x < 10
      invariant x % 2 == 0
}

By declaring this, you are instructing Dafny to check two things.

◊ol[#:compact #f]{
  ◊item{
    Is ◊code{x % 2 == 0} true before the loop?
  }

  ◊item{
    Given that ◊code{x % 2 == 0} is true before an iteration of the loop, does it remain true after that iteration?
  }
}

These correspond to the two cases that you may be familiar with in a proof by induction: the base case and the inductive case.

Let's see an example.

◊section{Iterative Factorial}

Consider the following definition.

◊codeblock['dafny]{
  function Factorial(n: nat): nat
  {
      if n == 0
        then 1
        else n * Factorial(n - 1)
  }
}

Let's write a method that computes factorial iteratively and prove that it agrees with the mathematical definition just given. (You should all be well able to write the code for such a method.) Here's a first pass:

◊codeblock['dafny]{
  method FacIter(n: nat) returns (r: nat)
  {
      r := 1;

      var i := 1;
      while i < n
      {
          i := i + 1;
          r := r * i;
      }
  }
}

Does this work? Let's add a postcondition and see.

◊codeblock['dafny]{
  method FacIter(n: nat) returns (r: nat)
      ensures r == Factorial(n)
}

Dafny can't prove this yet---we need to provide a loop invariant. But which invariant should we give?

We know that the loop is the last calculation before the function completes---this means that the negation of the loop condition combined with the loop invariant should imply (or be equivalent to) the postcondition, which is ◊${r = n!}. That is, we need an invariant ◊${P} such that ◊${P \wedge (i \ge n)} implies ◊${r = n!}.

Let's write out the computation table for the loop computing ◊code{Factorial(5)} to give ourselves more information to work with.

◊quick-table{
  ◊${\boldsymbol{i}} | ◊${\boldsymbol{r}}
  ◊${1} | ◊${1}
  ◊${2} | ◊${2 \textcolor{gray}{= 1 \times 2}}
  ◊${3} | ◊${6 \textcolor{gray}{= 2 \times 3}}
  ◊${4} | ◊${24 \textcolor{gray}{= 6 \times 4}}
  ◊${5} | ◊${120 \textcolor{gray}{= 24 \times 5}}
}

Notice that ◊${r = i!} at each step of the loop. This is a promising candidate for a loop invariant. Let's add it.

◊codeblock['dafny]{
  method FacIter(n: nat) returns (r: nat)
      ensures r == Factorial(n)
  {
      r := 1;

      var i := 1;
      while i < n
          invariant r == Factorial(i)  // added
      {
          i := i + 1;
          r := r * i;
      }
  }
}

Unfortunately this does not work---Dafny complains that it still cannot prove the postcondition. But we should not be that surprised, since ◊${(r = i!) \wedge (i \ge n)} does not imply ◊${r = n!}. We would need the stronger condition that ◊${i = n}. But we know this already---◊${i} is always equal to ◊${n} when the loop is finished. In fact, we know that ◊${0 \le i \le n} throughout the loop. Let's add this as an invariant as well.

◊codeblock['dafny]{
  method FacIter(n: nat) returns (r: nat)
      ensures r == Factorial(n)
  {
      r := 1;

      var i := 1;
      while i < n
          invariant 0 <= i <= n  // added
          invariant r == Factorial(i)
      {
          i := i + 1;
          r := r * i;
      }
  }
}

But this doesn't work either. Why? Dafny complains that it does not hold on entry. Right, because ◊${i = 1} before the loop begins, but ◊${n} could be ◊${0}, in which case ◊${i \nleq n}.

This is a special case; in any other case the new invariant is true. So, there are two ways to deal with this: modify the code, or modify the invariant.

We can modify the code to deal with this special case separately.

◊codeblock['dafny]{
  method FacIter(n: nat) returns (r: nat)
      ensures r == Factorial(n)
  {
      if (n == 0) {
          return 1;
      }

      assert n > 0;
      
      // ...
  }
}

Since Dafny knows that ◊${n > 0}, there's no issue.

But the code was perfectly fine as it was. Instead we can just modify the invariants to deal with the special case explicitly. When ◊${n = 0} we know ◊${i = 1}, and otherwise the old invariant holds.

◊codeblock['dafny]{
  method FacIter(n: nat) returns (r: nat)
      ensures r == Factorial(n)
  {
      r := 1;

      var i := 1;
      while i < n
          invariant n == 0 ==> i == 1
          invariant n != 0 ==> 0 <= i <= n
          invariant r == Factorial(i)
      {
          i := i + 1;
          r := r * i;
      }
  }
}

Dafny accepts this.

◊hrule

◊section{Question 1}

Write a method that computes the sum of the first ◊${n} natural numbers ◊em{without} using multiplication and prove that the result is equal to the ◊${n}th triangle number ◊${n(n + 1)/2}.

◊codeblock['dafny]{
  method SumFirst(n: nat) returns (sum: nat)
      ensures sum == n * (n + 1) / 2
  {
      // todo
  }
}

◊section{Question 2}

The Fibonacci sequence begins with the numbers ◊${0} and ◊${1}. To compute the next number in the sequence, sum the previous two. The sequence therefore continues as ◊${0, 1, 1, 2, 3, 5, 8, \dots}. Write a method which iteratively computes the ◊${n}th Fibonacci number without any recursive calls and verify that it is equal to the mathematical definition.

◊codeblock['dafny]{
  function Fib(n: nat): nat
  {
      if n < 2 then n else Fib(n - 1) + Fib(n - 2)
  }

  method FibIter(n: nat) returns (x: nat)
      ensures x == Fib(n)
  {
      // todo
  }
}

◊section{Question 3}

Write and verify a method which finds the index pointing to the smallest element in an array. You might find it useful to look at the binary search pre- and postconditions from the ◊xref["resources/dafny-02.html#Question 5"]{previous lab}.

◊codeblock['dafny]{
  method Smallest(a: array<int>) returns (minIndex: nat)
  {
      // todo
  }
}

◊section{Question 4}

Write a method ◊code{Filter} which takes an array ◊${a} and a predicate ◊${P} as arguments, then builds a sequence of all the elements in ◊${a} satisfying ◊${P}. For example, if ◊code{a = [1, 2, 3, 4]} then ◊code{Filter(a, IsEven)} should return ◊code{[2, 4]}.

Prove the following:

◊ol[#:compact #f]{
  ◊item{
    All the elements of the output sequence satisfy ◊${P}.
  }
  ◊item{
    If the output sequence is empty, then no element in the array ◊${a} satisfied ◊${P}.
  }
  ◊item{
    The output sequence only contains elements from ◊${a}---that is, prove ◊code{multiset(s) <= multiset(a[..])}.
  }
}

Explain in a comment above the method why this might not be enough to fully specify a filter method and ensure it works as intended.

◊codeblock['dafny]{
  method Filter<T>(a: array<T>, P: T -> bool) returns (s: seq<T>)
  {
      // todo
  }
}

Hints:
◊ul[#:compact #f]{
  ◊item{
    To append an element ◊code{a} to a sequence ◊code{s}, write ◊code{s + [a]}.
  }
  ◊item{
    You may need to remind the verifier that ◊code{a[..]} and ◊code{a[..a.Length]} are equal. It has a strange habit of forgetting.
  }
}
