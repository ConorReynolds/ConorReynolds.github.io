#lang pollen

◊(define-meta title "Designing Invariants (Draft)")
◊(define-meta toc-title "Designing Invariants (Draft)")
◊(define-meta subtitle "Using Dafny to verify nontrivial programs")
◊(define-meta math? #true)
◊(define-meta created "2022-11-26")

◊; ◊section{Iterative Factorial}

◊; Create the following file.

◊; ◊codeblock['dafny #:name "Factorial.dfy"]{
◊;   function Fac(n: nat): nat
◊;   {
◊;       if n == 0
◊;         then 1
◊;         else n * Fac(n - 1)
◊;   }

◊;   method FacIter(n: nat) returns (r: nat)
◊;   {
◊;       r := 1;
◊;       var i := n;
◊;       while i > 0 {
◊;           r := r * i;
◊;           i := i - 1;
◊;       }
◊;   }
◊; }

◊; An ◊em{invariant} is a value that remains the same or a property that remains true under a certain transformation. Identifying invariants is a key technique not just in software verification, but in mathematics more generally.

◊; How do we discover invariants? Unfortunately there is no general principle that can help---though, if you can find such a principle, there might be a Field's medal in it for you.

◊; Often the best approach is simply to tabulate the values at each iteration of the loop and stare at them until you see a pattern. Let's calculate ◊code{FacIter(5)}.

◊; ◊quick-table{
◊;   ◊${\boldsymbol{r}} | ◊${\boldsymbol{i}}
◊;   ◊${1} | ◊${5}
◊;   ◊${5} | ◊${4}
◊;   ◊${20} | ◊${3}
◊;   ◊${60} | ◊${2}
◊;   ◊${120} | ◊${1}
◊; }

◊; Helpful? Maybe not. Sometimes it's more useful to tabulate the values without actually performing the calculations, since the calculations can often hide structure.

◊; ◊quick-table{
◊;   ◊${\boldsymbol{r}} | ◊${\boldsymbol{i}}
◊;   ◊${1} | ◊${5}
◊;   ◊${5} | ◊${4}
◊;   ◊${5 \times 4} | ◊${3}
◊;   ◊${5 \times 4 \times 3} | ◊${2}
◊;   ◊${5 \times 4 \times 3 \times 2} | ◊${1}
◊; }

◊; Do you see a pattern emerging yet? We can go further an tabulate the values for an arbitrary ◊${n}.

◊; ◊quick-table{
◊;     ◊${\mathit{\boldsymbol{r}}} | ◊${\mathit{\boldsymbol{i}}} | ◊${\mathit{\boldsymbol{r \cdot i!}}}
◊;     ◊${1} | ◊${n} | ◊${n!}
◊;     ◊${n} | ◊${n - 1} | ◊${n \cdot (n - 1)! = n!}
◊;     ◊${n \cdot (n - 1)} | ◊${n - 2} | ◊${[n \cdot (n - 1)] \cdot (n - 2)! = n!}
◊;     ◊${\vdots} | ◊${\vdots} | ◊${\vdots}
◊;     ◊${n!} | ◊${0} | ◊${n!}
◊; }

◊; Try to figure out what the invariant property should be. Don't peek at the answer until you've tried it.

◊; ◊spoiler{
◊;     The invariant property is ◊${r \cdot i! = n!}---notice that this equation holds at each iteration. We can encode this in Dafny by writing ◊code{invariant r * Fac(i) == Fac(n)}.
◊; }

◊; ◊section{Fast Exponentiation by Squaring}

As we have seen already, the elementary integer exponentiation algorithm can be encoded and verified in Dafny as follows.

◊codeblock['dafny #:name "FastExp.dfy"]{
    function ExpDef(a: int, n: nat): int
    {
        if n == 0 then
            1
        else
            a * ExpDef(a, n - 1) 
    }
    
    method SlowExp(a: int, n: nat) returns (r: int)
        ensures r == ExpDef(a, n)
    {
        r := 1;
        var i := n;
        while i > 0
            invariant r == ExpDef(a, n - i)
        {
            r := r * a;
            i := i - 1;
        }
    }
}

This verification is in many ways not very interesting, but the main reason is because the definition ◊code{ExpDef} computes powers in basically the same way as ◊code{SlowExp}.

The definition computes by β-reduction like this:

◊codeblock['text]{
  ExpDef(3, 4) ⇝ᵦ 3 * ExpDef(3, 3)
               ⇝ᵦ 3 * 3 * ExpDef(3, 2)
               ⇝ᵦ 3 * 3 * 3 * ExpDef(3, 1)
               ⇝ᵦ 3 * 3 * 3 * 3 * ExpDef(3, 0)
               ⇝ᵦ 3 * 3 * 3 * 3 * 1
               ⇝ᵦ 3 * 3 * 3 * 3
               ⇝ᵦ 3 * 3 * 9
               ⇝ᵦ 3 * 27
               ⇝ᵦ 81
}

... and the imperative computation table looks like this:

◊quick-table{
  ◊${\boldsymbol{i}} | ◊${\boldsymbol{r}}
  ◊${4} | ◊${1}
  ◊${3} | ◊${1 \times 3 = 3}
  ◊${2} | ◊${3 \times 3 = 9}
  ◊${1} | ◊${9 \times 3 = 27}
  ◊${0} | ◊${27 \times 3 = 81}
}

Specifications are supposed to tell us ◊em{what} we are computing. Programs are supposed to tell us ◊em{how} to compute it. Sometimes, like in this case, the ◊em{what} gives us sufficient information to perform the computation.

But sometimes the algorithm is too slow and we want to speed it up. In doing so, however, we want to compute the same ◊em{what}. Tools like Dafny allow us to improve on the ◊em{how} in such a way that we do not change what we are computing.

Let's return to exponentiation. Notice that ◊${a^{10} = (a^2)^5}. This seemingly trivial observation is very useful. With the naive algorithm, ◊${a^{10}} takes ten iterations. But ◊${(a^2)^5} only takes six---one iteration to square ◊${a}, five to compute ◊${(a^2)^5}. This leads to the following much faster algorithm for exponentiation.

◊codeblock['dafny]{
    method FastExp(a: int, n: nat) returns (r: int)
    {
        r := 1;
        var b := a;
        var i := n;

        while i > 0 {
            if i % 2 == 0 {
                b := b * b;
                i := i / 2;
            } else {
                r := r * b;
                i := i - 1;
            }
        }
    }

    method {:main} TestFastExp()
    {
        var x := FastExp(3, 4);
        print x, "\n";  // prints 81
    }
}

But how can we be sure that we've computed the right thing? This algorithm is much less straightforward than the simple one and therefore genuinely ◊em{requires} a proof for us to be really certain that it works.

Again, the trick here is to identify an invariant. Let's tabulate the values for ◊${3^7}.

◊quick-table{
  ◊${\boldsymbol{b}} | ◊${\boldsymbol{i}} | ◊${\boldsymbol{r}}
  ◊${3} | ◊${7} | ◊${1}
  ◊${3} | ◊${6} | ◊${3}
  ◊${3^2} | ◊${3} | ◊${3}
  ◊${3^2} | ◊${2} | ◊${3 \times 3^2} 
  ◊${3^4} | ◊${1} | ◊${3 \times 3^2}
  ◊${3^4} | ◊${0} | ◊${3 \times 3^2 \times 3^4}
}

At the beginning of the loop, ◊${r \cdot b^i = 1 \cdot 3^7 = 3^7}, which is the result we're looking for---that's usually a good start.

That will remain true in the simple case since ◊${r \cdot b^i = 3 \cdot 3^6} on the second line. On the third line, after one iteration in the more complicated branch, ◊${r \cdot b^i = 3 \cdot (3^2)^3 = 3 \cdot 3^6 = 3^7}---exactly what we wanted.

Now that we have identified what we think is an invariant, we should prove it. You can do this on paper, or you can get Dafny to do it for you.

◊codeblock['dafny]{
    method FastExp(a: int, n: nat) returns (r: int)
        ensures r == ExpDef(a, n)
    {
        r := 1;
        var b := a;
        var i := n;

        while i > 0
            // ✗ fails – might not be maintained
            invariant r * ExpDef(b, i) == ExpDef(a, n)
        {
            if i % 2 == 0 {
                b := b * b;
                i := i / 2;
            } else {
                r := r * b;
                i := i - 1;
            }
        }
    }
}

Unfortunately, Dafny is not ◊em{quite} that smart. What is the problem? If you copy the invariant into the loop, you will notice that it holds in the second branch, but not in the first. The reason for this is that Dafny does not know the properties of exponentiation like we do.

Performing Hoare logic calculations by hand, we can work up to the top of the condition to see what Dafny is missing.

◊codeblock['dafny]{
    if i % 2 == 0 {
        assert r * ExpDef(b * b, i / 2) == ExpDef(a, n);
        b := b * b;
        i := i / 2;
    }
}

If Dafny knew that ◊${(b^2)^{i/2} = b^i} (when ◊${i} is even), Dafny could complete the proof. For that, we will need a lemma.

A ◊em{lemma} in Dafny is a ghost method where the sole purpose is to establish the postcondition. For example, you might imagine writing a lemma like this:

◊codeblock['dafny]{
    lemma prop_54_43()
        ensures 1 + 1 == 2
    {}
}

This method has no body and cannot be executed besides, but if you call it somewhere, Dafny will be exposed to the earth-shattering realisation that ◊${1 + 1 = 2}. This occasionally useful fact does not require a lemma, but our fact about exponentiation does.

We want Dafny to be able to prove the following:

◊codeblock['dafny]{
    lemma ExpSquare(a: int, n: nat)
        ensures ExpDef(a, n) == ExpDef(a*a, n / 2)
    {}
}

This requires that ◊${n} is even, of course. We can add this as a precondition.

◊codeblock['dafny]{
    lemma ExpSquare(a: int, n: nat)
        requires n % 2 == 0
        ensures ExpDef(a, n) == ExpDef(a*a, n / 2)
    {}
}

Dafny cannot automatically prove that this holds, but it turns out to be enough to remind Dafny that the inductive hypothesis holds in the case where ◊${n \ne 0}.

◊codeblock['dafny]{
    lemma ExpSquare(a: int, n: nat)
        requires n % 2 == 0
        ensures ExpDef(a, n) == ExpDef(a*a, n / 2)
    {
        if n != 0 {
            // note that n > 1 here (Dafny knows this)
            ExpSquare(a, n - 2);
        }
    }
}

Now all that remains is to make this lemma visible in the body of ◊code{FastExp}.

◊codeblock['dafny]{
    method FastExp(a: int, n: nat) returns (r: int)
        ensures r == ExpDef(a, n)  // ✓ succeeds
    {
        r := 1;
        var b := a;
        var i := n;

        while i > 0
            invariant r * ExpDef(b, i) == ExpDef(a, n)
        {
            if i % 2 == 0 {
                ExpSquare(b, i);  // ← this line added
                b := b * b;
                i := i / 2;
            } else {
                r := r * b;
                i := i - 1;
            }
        }
    }
}

This is now fully verified.
