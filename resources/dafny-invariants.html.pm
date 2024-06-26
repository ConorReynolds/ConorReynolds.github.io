#lang pollen

◊(define-meta title "Designing Invariants (Draft)")
◊(define-meta toc-title "Designing Invariants: Using Dafny to Verify Nontrivial Programs")
◊(define-meta subtitle "Using Dafny to verify nontrivial programs")
◊(define-meta math? #true)
◊(define-meta created "2022-11-26")

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

But this verification is not very interesting. Why? Because the definition ◊code{ExpDef} computes powers in basically the same way as ◊code{SlowExp}.

To see this, note that the function computes by ◊${\beta}-reduction like this:

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

... and the method computes according to this computation table in the loop:

◊quick-table{
  ◊${\boldsymbol{i}} | ◊${\boldsymbol{r}}
  ◊${4} | ◊${1}
  ◊${3} | ◊${3 \textcolor{grey}{= 1 \times 3}}
  ◊${2} | ◊${9 \textcolor{grey}{= 3 \times 3}} 
  ◊${1} | ◊${27 \textcolor{grey}{= 9 \times 3}}
  ◊${0} | ◊${81 \textcolor{grey}{= 27 \times 3}}
}

Here the specification and the code are just two ways of describing the same algorithm. It would be more interesting to prove that two different algorithms compute the same thing. So let's consider a new algorithm.

Notice that ◊${a^{10} = (a^2)^5}. This seemingly trivial observation is very useful. With the naive algorithm for computing exponentials, ◊${a^{10}} takes ten iterations. But ◊${(a^2)^5} only takes six---one iteration to square ◊${a}, five to compute ◊${(a^2)^5}. This leads to the following much faster algorithm for exponentiation, in which we effectively rewrite ◊${a^{2n}} as ◊${(a^2)^n} whenever possible.

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

But how can we be sure that this works? This algorithm is not as straightforward as the simple one and therefore genuinely ◊em{requires} a proof for us to be certain that it works.

Again, the trick here is to identify an invariant---a logical expression that is true for each iteration of the loop. Let's tabulate the values for ◊${3^7}.

◊quick-table{
  ◊${\boldsymbol{b}} | ◊${\boldsymbol{i}} | ◊${\boldsymbol{r}}
  ◊${3} | ◊${7} | ◊${1}
  ◊${3} | ◊${6} | ◊${3}
  ◊${3^2} | ◊${3} | ◊${3}
  ◊${3^2} | ◊${2} | ◊${3 \times 3^2} 
  ◊${3^4} | ◊${1} | ◊${3 \times 3^2}
  ◊${3^4} | ◊${0} | ◊${3 \times 3^2 \times 3^4}
}

The expression should probably involve all variables. The most sensible way to combine them seems to be ◊${r \cdot b^i}, which at the beginning evaluates to ◊${1 \cdot 3^7 = 3^7}.

This remains true on the second line, after one iteration in the simple branch in the loop (where ◊${i} is odd): ◊${r \cdot b^i = 3 \cdot 3^6 = 3^7}. On the third line, after one iteration in the more complicated branch, ◊${r \cdot b^i = 3 \cdot (3^2)^3 = 3 \cdot 3^6 = 3^7}. So it seems that ◊${r \cdot b^i = 3^7} is an invariant.

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

Unfortunately, Dafny is not ◊em{quite} that smart. What's the problem? If you copy the invariant into the loop, you will notice that it holds in the second branch, but not in the first. The reason for this is that Dafny does not know the properties of exponentiation like we do.

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

Dafny will try to prove lemmas automatically by induction on the lemma's arguments, if possible. But Dafny cannot automatically prove that this lemma is true. It turns out to be enough to remind Dafny that the inductive hypothesis holds for ◊${n - 2} in the case where ◊${n \ne 0}.

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

◊hrule

Why couldn't Dafny prove the ◊code{ExpSquare} lemma automatically by induction? I don't know for sure, but I have a sensible guess.

The base case is easy, so we won't bother discussing that. The proof of the inductive step can't start in the usual way---if we assume that the lemma holds for ◊${a^k}, we can't prove it for ◊${a^{k + 1}}, since ◊${k + 1} is odd, and the lemma does not apply. We want to prove it for all ◊em{even} numbers, so we prove it in the case ◊${n = 0}, and then, assuming it holds for even ◊${k}, prove it for ◊${k + 2}. ◊aside{Note that the equality marked ◊${\stackrel{\ast}{=}} follows from the inductive hypothesis.}

◊$${
    a^{k + 2} &= a^2 \cdot a^{k} \\
              &\stackrel{\ast}{=} a^2 \cdot (a^2)^{k/2} \\
              &= (a^2)^{(k + 2)/2}
}

I can't give you the precise reason why Dafny fails to guess this calculation, but more than likely it is due to the fact that the induction step is unusual, requiring ◊em{strong induction}. This is probably why it sufficed to point out that the induction step held for ◊${n - 2} in the lemma itself. ◊aside{Proving something for all natural numbers ◊${n}, under the condition that ◊${n} is even, is subtly different from proving something for all even numbers. In the first case you need strong induction, but in the second case you don't.}

If instead we declare the lemma like so:

◊codeblock['dafny]{
    lemma ExpSquare(a: int, n: nat)
        ensures ExpDef(a, 2*n) == ExpDef(a*a, n)
    {}
}

... then Dafny ◊em{can} prove this automatically. Why? Presumably because the proof only requires standard induction. There's also no more precondition, and we no longer have to reason about division.

◊$${
    a^{2(k + 1)} &= a^2 \cdot a^{2k} \\
                 &\stackrel{\ast}{=} a^2 \cdot (a^2)^{k} \\
                 &= (a^2)^{k + 1}
}

Always keep in mind that automated and interactive theorem provers can be sensitive to the specific way in which a goal is expressed. Even if two lemmas are logically equivalent, it does not guarantee that they will be equivalently easy to prove.
