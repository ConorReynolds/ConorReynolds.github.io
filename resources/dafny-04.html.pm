#lang pollen

◊(define-meta title "Dafny Lab Sheet 4")
◊(define-meta toc-title "Dafny Lab Sheet 4: Frames, References, Mutability")
◊(define-meta subtitle "Frames, references, mutability")
◊(define-meta math? #t)
◊(define-meta created "2023-09-22")

You can skip to the ◊xref["#Question 1"]{lab questions} if you're in a hurry, but as always I recommend reading the following sections as they give good context for the lab.

◊note{
  Code snippets can be copied by hovering over the snippet and clicking the ◊i[#:class "fa fa-copy" #:style "margin: 0 0.1em 0 0.1em; color: var(--muted-color);"] button which appears on the top right.
  
  Some snippets are declared as files---those can be downloaded directly by clicking the ◊i[#:class "fa fa-download" #:style "position: relative; margin: 0 0.1em 0 0.1em; top: -0.05em; font-size: 0.9em; color: var(--muted-color);"] button next to the filename.
}

◊section{Dynamic Frames}

Dafny contains a few reference types, mainly arrays and objects. The values pointed to by references are stored on the heap.

Dafny methods are not allowed to modify any heap values by default, but they may modify values stored on the stack, or heap-allocated values local to the method. The set of objects that may be modified by a method is called its ◊em{frame}. We have already seen methods with frames---for example, the ◊xref["resources/dafny-01.html#Question 4"]{swap method in lab 1}.

To specify a method's frame, use a ◊code{modifies} clause. A method that modifies an array ◊code{a} and an object ◊code{o} can be written in any one of the following ways.

◊codeblock['dafny]{
  modifies a, o
  modifies {a, o}
  modifies {a} + {o}
}

Functional code can read the heap state but cannot modify it. Functions and predicates therefore use a ◊code{reads} clause instead of a ◊code{modifies} clause.

Postconditions for methods in Dafny are so-called 'two-state predicates', since they have access to the state of the heap before and after a method is executed. The expression ◊code{old(E)} refers to the value of ◊code{E} just before the enlosing method. For example, consider this postcondition for a method that increments each value in an integer array.

◊codeblock['dafny]{
  forall i | 0 <= i < a.Length :: a[i] == old(a[i]) + 1
}

This says that for each index ◊code{i}, the new value ◊code{a[i]} is equal to the old value of ◊code{a[i]} plus one.

It's important not to write ◊code{old(a)[i]}. The value ◊code{a} is a ◊em{reference} passed as a parameter to the method and does not change. Think of it like a pointer to the location in memory where the array values are stored. It's always true that ◊code{old(a) == a}, and therefore ◊code{old(a)[i] == a[i]}, since the reference itself can't be modified. The value ◊code{a[i]}, however, is the heap value obtained by dereferencing ◊code{a}. This can change, and hence ◊code{old(a[i])} may not be equal to ◊code{a[i]}.

◊section{Classes}

Classes in Dafny look exactly like classes in any other object-oriented language. A class is just a list of members of that class—fields, methods, functions.

◊codeblock['dafny]{
  class Point2 {
      var x: real, y: real

      constructor(x: real, y: real)
          ensures this.x == x && this.y == y
      {
          this.x := x;
          this.y := y;
      }

      function Dot(other: Point2): real
          reads this, other
      {
          x * other.x + y * other.y
      }
  }

  method {:main} TestPoint() {
      var p := new Point2(3.0, 4.0);
      var q := new Point2(1.2, -3.5);
      assert p.Dot(q) == -10.4;
      print p.Dot(q), "\n";
  }
}

◊hrule

◊section{Question 1}

Consider the following class which represents a pointer to an array. It contains a single method ◊code{InitArray} which sets ◊code{a} to a new array of a given size. What does ◊code{InitArray} modify? Explain your answer.

◊codeblock['dafny]{
  class Pointer {
      var a: array<int>

      method InitArray(size: nat)
          // modifies what?
      {
          var b := new int[size];
          a := b;
      }
  }
}

◊section{Question 2}

Write a method which doubles the values of an array ◊code{s} and stores it in an array ◊code{t}.

◊codeblock['dafny]{
  method DoubleArray(s: array<int>, t: array<int>)
      // needs a frame
      // needs one precondition
      // needs a postcondition saying that t[i] is twice s[i]
  {
      // todo
  }
}

Be careful: the input arguments ◊code{s} and ◊code{t} might refer to the same array.

◊section{Question 3}

Write a method ◊code{CumulativeSum} which updates an array to its cumulative sum. Prove that each new ◊code{a[i]} is equal to the sum ◊code{old(a[0] + ⋯ + a[i])}.

For example, if ◊code{a = [1, 2, 3, 4]} then ◊code{CumulativeSum(a)} should modify ◊code{a} such that ◊code{a = [1, 3, 6, 10]}. You will need the function ◊code{SumTo} provided below which computes the sum of an array's elements up to but not including a specified index.

◊codeblock['dafny]{
  function SumTo(a: array<int>, i: nat): int
      reads a
      requires 0 <= i <= a.Length
  {
      if i == 0 then 0 else SumTo(a, i - 1) + a[i - 1]
  }

  method CumulativeSum(a: array<int>)
      // needs modifies clause and postcondition
  {
      // todo
  }
}
