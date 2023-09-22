#lang pollen

◊(define-meta title "Dafny Lab Sheet 1")
◊(define-meta toc-title "Dafny Lab Sheet 1: An Introduction to Dafny")
◊(define-meta subtitle "An introduction to the Dafny language")
◊(define-meta math? #true)
◊(define-meta created "2022-11-18")

◊section{Prerequisites}

Programming experience in C-style languages---Java, C, C#, JavaScript, etc.---must be assumed. The ◊extlink["http://dafny.org/dafny/DafnyRef/DafnyRef.html"]{Dafny language reference} and the ◊extlink["http://dafny.org/dafny/OnlineTutorial/guide.html"]{Dafny Guide} will be extremely useful resources for you. Finally, there's a ◊extlink["http://dafny.org/latest/QuickReference"]{quick reference} and ◊extlink["http://dafny.org/latest/DafnyCheatsheet.pdf"]{cheat sheet} if you need a refresher.

◊note{
  Code snippets can be copied by hovering over the snippet and clicking the ◊i[#:class "fa fa-copy" #:style "margin: 0 0.1em 0 0.1em; color: var(--muted-color);"] button which appears on the top right.
  
  Some snippets are declared as files---those can be downloaded directly by clicking the ◊i[#:class "fa fa-download" #:style "position: relative; margin: 0 0.1em 0 0.1em; top: -0.05em; font-size: 0.9em; color: var(--muted-color);"] button next to the filename.
}

◊section{Instructions}

If you're using the computers in the lab, everything should already be installed---just open VS Code.

If you're using your own computer, ◊extlink["https://code.visualstudio.com/download"]{install VS Code}, run it, hit ◊kbd{Ctrl + Shift + X} / ◊kbd[#:os 'mac]{Cmd + Shift + X} to bring up the extensions menu, then search for and install the Dafny extension.

In either case, create the following file:

◊codeblock['dafny #:name "Test.dfy" #:download #t]{
  method Abs(n: int) returns (result: int)
      ensures result >= 0
      ensures result == n || result == -n
  {
      if n < 0 {
          result := -n;
      } else {
          result := n;
      }
  }

  method {:main} TestAbs()
  {
      var x := Abs(-3);
      assert x == 3;
      print x, "\n";
  }
}

All going well, you should see a message at the bottom-left which reads 'Verification Succeeded'. If so, the installation was successful. If not, try reloading the window (◊kbd{Ctrl+Shift+P} / ◊kbd[#:os 'mac]{Cmd + Shift + P}, then type 'Reload Window' and press ◊kbd{Enter}). Press ◊kbd{F5} to compile and run the code.

If you're already comfortable with Dafny, you can skip right ahead to the ◊xref["resources/dafny-01.html#Question 1"]{lab questions}. If you are not, then I strongly recommend reading the next few sections carefully, since they will help prepare you for the lab.

◊section{Dafny Syntax}

Dafny's syntax is C-like, so it should be familiar to you. To demonstrate how similar Dafny and Java are, lets define a very basic ◊code{isPrime} function in both.

◊codeblock['java #:name "Primes in Java"]{
  // only works for n >= 0
  static boolean isPrime(int n)
  {
      if (n < 2) {
          return false;
      }

      for (int i = 2; i * i <= n; i++) {
          if (n % i == 0) {
              return false;
          }
      }
      
      return true;
  }
}

◊codeblock['dafny #:name "Primes in Dafny"]{
  method isPrime(n: nat) returns (r: bool)
  {
      if n < 2 {
          return false;
      }

      var i := 2;
      while i * i <= n {
          if n % i == 0 {
              return false;
          }
          i := i + 1;
      }

      return true;
  }
}

These two snippets only differ by minor syntactical details.

Notice that Dafny does not have for-loops, but they are at any rate an unnecessary syntactic convenience. Since Dafny supports verification constructs, it is more important than usual that its syntax is simple. Where in Java you would have written:

◊codeblock['java]{
  {
      // some code

      for (int i = 0; i < n; i++) {
          // loop body
      }
      
      // some more code
  }
}

... in Dafny, you can write:

◊codeblock['dafny]{
  {
      // some code

      var i := 0;
      while i < n {
          // loop body
          i := i + 1;
      }

      // some more code
  }
}

You can create new scopes in Dafny with braces just like you can in Java if you're concerned about ◊code{i} escaping its scope.

As you can see, assignment in Dafny is denoted ◊code{:=} rather than ◊code{=}. Dafny also has mathematical syntax for assertions, preconditions, and postconditions: ◊code{==>} is implication, ◊code{&&} is conjunction, ◊code{||} is disjunction, ◊code{!} is negation.

A key difference between Dafny methods and methods in other C-like languages is that Dafny methods require you to define the names of the return values in the function signature. For example, in ◊code{Abs} above, the name of the return variable was ◊code{result}.

This is necessary because there would otherwise be no straightforward way to refer to the returned value in the function's contract. The postcondition for ◊code{Abs} says that ◊code{result} must be either ◊code{n} or ◊code{-n}. We couldn't write this if ◊code{result} was not already defined. ◊aside{Some specification languages, like JML, use a special name for the return value instead.}

◊section{General Tips}

◊ol[#:compact #false]{
  ◊item{
    Dafny accepting your code as verified is not by itself an indication that you have answered the question correctly.
  }

  ◊item{
    You may know your code is correct before Dafny does. Correct code is not by itself an indication that you have answered the question correctly.
  }

  ◊item{
    Correct code and a verified postcondition together are not an indication that you have answered the question correctly.
  }

  ◊item{
    A weak condition is satisfied by many models. A strong condition is satisfied by few models.
  }

  ◊item{
    Always look for the weakest precondition. The ideal precondition is no condition at all. Ask for what you need, and no more.
  }

  ◊item{
    Always look for the strongest postcondition. ◊aside{This isn't always the case, but it's a good rule to follow as a beginner.} A postcondition is strengthened by exposing its weaknesses. Try to imagine output which satisfies your postcondition, but behaves in a way that you do not want or expect. What your code really does is irrelevant here---it may well be correct. But the postcondition is the means by which you communicate what your code does to the rest of the program. If it is too weak, then other methods may not know enough about what your code guarantees to progress with their own proofs.
  }
}

◊section{Worked Example}

To illustrate points 3--6, consider the following code which computes the absolute value of any ◊${x \in \Z}, denoted mathematically as ◊${\lvert x \rvert}.

◊codeblock['dafny]{
  method Abs(x: int) returns (result: int)
  {
      if x < 0 {
          result := -x;
      } else {
          result := x;
      }
  }
}

The code is correct, but it has no contract. This prevents the verifier from inferring anything about the code. For example, even this simple assertion will fail.

◊codeblock['dafny]{
  method {:main} TestAbs()
  {
      var x := Abs(-3);
      assert x >= 0;  // ✗ fails
  }
}

Let's fix that by adding a silly contract.

◊codeblock['dafny]{
  method Abs(x: int) returns (result: int)
      requires -10 < x < 10
      ensures result >= 0  // ✓ succeeds
  {
      if x < 0 {
          result := -x;
      } else {
          result := x;
      }
  }
}

Dafny can prove both the postcondition and the assertion automatically.

◊codeblock['dafny]{
  method {:main} TestAbs()
  {
      var x := Abs(-3);
      assert x >= 0;  // ✓ succeeds
  }
}

In some sense, this code is 'correct'---but it has some issues. The precondition requires that ◊${-10 < x < 10}, but the absolute value function should work for ◊em{any} integer, not just a small range of them. If we use any integer outside this range, Dafny will complain that the precondition is violated.

◊codeblock['dafny]{
  method {:main} TestAbs()
  {
      var x := Abs(-10);  // ✗ fails (precondition violation)
      assert x >= 0;
  }
}

Since there is no good reason to restrict ◊code{Abs} in this way, we can remove it. Of course, the postcondition still holds.

◊codeblock['dafny]{
  method Abs(x: int) returns (result: int)
      ensures result >= 0  // ✓ succeeds
  {
      if x < 0 {
          result := -x;
      } else {
          result := x;
      }
  }
}

Let's see what Dafny can infer about the function now.

◊codeblock['dafny]{
  method {:main} TestAbs()
  {
      var x := Abs(-3);
      assert x >= 0;  // ✓ succeeds
      assert x == 3;  // ✗ fails
  }
}

Dafny can prove the first assertion, but it cannot prove the stronger fact that ◊code{x} should not ◊em{just} be some non-negative integer, but ◊em{exactly} ◊code{3}. As far as Dafny is concerned, all ◊code{Abs} guarantees is that its output is greater than or equal to zero. Notice that this postcondition would still hold if instead ◊code{Abs} was defined to be ‘◊code{Abs} plus three’.

◊codeblock['dafny]{
  method Abs(x: int) returns (result: int)
      ensures result >= 0  // ✓ still succeeds!
  {
      if x < 0 {
          result := -x;
      } else {
          result := x;
      }
      result := result + 3;
      // or even `result := 0`!
  }
}

That's a big problem! But we can fix it easily by adding more postconditions that explain in more detail what ◊code{Abs} guarantees.

For any ◊${x \in \Z}, we know that ◊${\lvert x \rvert} has to be one of exactly two possible values: ◊${x} or ◊${-x}. Let's add this as a postcondition.

◊codeblock['dafny]{
  method Abs(x: int) returns (result: int)
      ensures result >= 0
      ensures result == x || result == -x
  {
      if x < 0 {
          result := -x;
      } else {
          result := x;
      }
  }
}

Notice that Dafny can now prove both assertions.

Alternatively, note that we know the exact conditions under which ◊${\lvert x \rvert} is ◊${x} or ◊${-x} respectively. Specifically, we know that ◊${\lvert x \rvert = x} when ◊${x \ge 0} and that ◊${\lvert x \rvert = -x} whenever ◊${x < 0}.

◊codeblock['dafny]{
  method Abs(x: int) returns (result: int)
      ensures result >= 0
      ensures x >= 0 ==> result == x
      ensures x < 0  ==> result == -x
  {
      if x < 0 {
          result := -x;
      } else {
          result := x;
      }
  }
}

Dafny can automatically verify these postconditions and both assertions.

◊hrule

◊section{Question 1}

Write and verify a method which computes the maximum of two integers. Use the following as a template. You should provide the weakest precondition and the strongest postcondition for full marks. All the tests in ◊code{TestMax} should pass. ◊aside{If the tests don't pass, it is almost certainly because your postcondition is not strong enough---Dafny can imagine a situation where your postcondition is true but the assertions don't hold.}

◊codeblock['dafny]{
  method Max(a: int, b: int) returns (m: int)
  {
      // todo
  }

  method {:test} TestMax()
  {
      var x := Max(2, 3);
      assert x == 3;

      var y := Max(-4, 1);
      assert y == 1;

      var z := Max(0, 0);
      assert z == 0;
  }
}

◊section{Question 2}

Write and verify a method which computes the minimum of two integers. Use the following as a template. You should provide the weakest precondition and the strongest postcondition for full marks. All the tests in ◊code{TestMin} should pass.

◊codeblock['dafny]{
  method Min(a: int, b: int) returns (m: int)
  {
      // todo
  }

  method {:test} TestMin()
  {
      var x := Min(2, 3);
      assert x == 2;

      var y := Min(-4, 1);
      assert y == -4;

      var z := Min(0, 0);
      assert z == 0;
  }
}

◊section{Question 3}

Decide what the methods ◊code{M1} and ◊code{A1} do and provide an appropriate postcondition for each. Verify the program using Dafny.

◊codeblock['dafny]{
  method M1(x: int, y: int) returns (r: int)
      // ensures r == ?
      decreases x < 0, x
  {
      if x == 0 {
          r := 0;
      } else if x < 0 {
          r := M1(-x, y);
          r := -r;
      } else {
          r := M1(x - 1, y);
          r := A1(r, y);
      }
  }

  method A1(x: int, y: int) returns (r: int)
      // ensures r == ?
  {
      r := x;
      if y < 0 {
          var n := y;
          while n != 0
              invariant r == x + y - n
              invariant -n >= 0
          {
              r := r - 1;
              n := n + 1;
          }
      } else {
          var n := y;
          while n != 0
              invariant r == x + y - n
              invariant n >= 0
          {
              r := r + 1;
              n := n - 1;
          }
      }
  }
}

◊section{Question 4}

Write a method that swaps the values ◊code{a[i]} and ◊code{a[j]} in-place. This method will modify ◊code{a}, so we have to declare that with the frame condition ◊code{modifies a}. (A frame condition for a method just describes what can and cannot be modified by that method. Dafny assumes that methods do not modify anything, unless you say otherwise.)

◊codeblock['dafny]{
  method swap(a: array<int>, i: nat, j: nat)
      modifies a

      // requires relationship between i and a.Length
      // requires relationship between j and a.Length

      ensures a[i] == old(a[j])
      ensures a[j] == old(a[i])
  {
      // todo
  }

  method {:main} TestSwap()
  {
      var a := new int[] [1, 2, 3, 4];

      assert a[1] == 2 && a[3] == 4;
      swap(a, 1, 3);
      assert a[1] == 4 && a[3] == 2;
  }
}
