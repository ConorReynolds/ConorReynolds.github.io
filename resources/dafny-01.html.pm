#lang pollen

◊(define-meta title "Dafny Lab Sheet 1 (Draft)")
◊(define-meta toc-title "Dafny Lab Sheet 1 (Draft)")
◊(define-meta subtitle "An introduction to the Dafny language")
◊(define-meta math? #false)
◊(define-meta created "2022-11-18")

◊section{Prerequisites}

Programming experience in C-style languages---Java, C, C#, JavaScript, etc.---must be assumed. The algorithms you will write and verify are deliberately simple so that you can focus on the verification.

The ◊extlink["http://dafny.org/dafny/DafnyRef/DafnyRef.html"]{Dafny language reference} and the ◊extlink["http://dafny.org/dafny/OnlineTutorial/guide.html"]{Dafny Guide} will be extremely useful resources for you.

◊section{Instructions}

Open VS Code---◊em{not} Visual Studio. If you're using one of the lab computers, Dafny is already installed. If not, hit ◊kbd{Ctrl + Shift + X} to bring up the extensions menu, then search for and install the Dafny extension.

Create the following file:

◊codeblock['dafny #:name "Dafny01.dfy"]{
  method Abs(n: int) returns (result: nat)
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

All going well, you should see a message at the bottom-left which reads 'Verification Succeeded'. If so, the installation was successful. If not, try reloading the window (◊kbd{Ctrl+Shift+P}, then type 'Reload Window' and press Enter). Press F5 to compile and run the code.

◊section{Dafny Syntax}

Dafny's syntax is C-like, so it should be familiar to you. To demonstrate how similar the languages are, here is the absolute value function defined above translated to Java.

◊codeblock['java]{
  static int abs(int n)
  {
      if (n < 0) {
          return -n;
      } else {
          return n;
      }
  }
}

Dafny does not have for-loops, but they are an unnecessary syntactic convenience. Since Dafny supports verification constructs, it is more important than usual that its syntax is simple. Where in Java you would have written:

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

A key difference between Dafny methods and methods in other C-like languages is that Dafny methods require you to define the names of the return values in the function signature. For example, in ◊code{abs} above, the name of the return variable was ◊code{result}.

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
    Always look for the strongest postcondition. A postcondition is strengthened by exposing its weaknesses. Try to imagine output which satisfies your postcondition, but behaves in a way that you do not want or expect. What your code really does is irrelevant here. It may well be correct. But the postcondition is the means by which you communicate what your code does to the rest of the program. If it is too weak, then other functions may not know enough about what your function guarantees to progress with their own proofs.
  }

  ◊item{
    Always look for the weakest precondition. The ideal precondition is no condition at all. Ask for what you need, and no more.
  }
}

◊hrule

◊section{Question 1}

Write and verify a method which computes the maximum of two integers. Use the following as a template. You should provide the weakest precondition and the strongest postcondition for full marks. All the tests in ◊code{TestMax} should pass.

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
      assert y == -4;

      var z := Max(0, 0);
      assert z == 0;
  }
}

◊section{Question 2}

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

◊section{Question 3}

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
}
