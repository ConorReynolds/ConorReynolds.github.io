#lang pollen

◊(define-meta title "Haskell Assignment Sheet 1")
◊(define-meta toc-title "Haskell Assignment Sheet 1")
◊(define-meta subtitle "An introduction to Haskell and the typed lambda calculus")
◊(define-meta math? #true)
◊(define-meta created "2023-03-06")

◊section{Submission Instructions}

Your full submission should be a ◊bold{single Haskell file} with the following template:

◊codeblock['haskell #:name "Assignment01.hs" #:download #t]{
  module Assignment01 where

  -----------------------------------------------------------
  -- QUESTION 1


  -----------------------------------------------------------
  -- QUESTION 2


  -----------------------------------------------------------
  -- QUESTION 3


  -----------------------------------------------------------
  -- QUESTION 4
}

You can download the template using the ◊i[#:class "fa fa-download" #:style "position: relative; margin: 0 0.1em 0 0.1em; top: -0.05em; font-size: 0.9em; color: var(--muted-color);"] button next to the file name. You can also copy any code snippet by hovering over it and clicking the ◊i[#:class "fa fa-copy" #:style "margin: 0 0.1em 0 0.1em; color: var(--muted-color);"] button which appears on the top right.

◊warning{
  Your file name and module name ◊em{must} match the template---any other file or module name will be rejected.
  
  You may ◊em{not} use any imports to solve this lab. If your file contains an import statement, you will get zero marks.
}

Do you already have Haskell set up on your system? If so, you can skip to the ◊xref["#Question 1"]{questions}. Otherwise, read on.

◊section{Setting Up Haskell}

Nowadays, installing Haskell is painless.

◊ol[#:compact #f]{
  ◊item{
    Navigate to ◊extlink["https://www.haskell.org/get-started"]{haskell.org/get-started}. Follow the instructions there and install ◊extlink["https://www.haskell.org/ghcup/"]{GHCup}.
  }

  ◊item{
    You will be prompted to make some decisions in the GHCup install script. Just make sure both stack and cabal are installed. I would highly recommend letting GHCup add PATH variables, installing the Haskell Language Server (HLS), and enabling better stack integration with GHCup. The remaining defaults are probably fine.
  }

  ◊item{
    I recommend using ◊extlink["https://code.visualstudio.com/"]{VS Code} as an editor, but you're welcome to use whatever you prefer. It's a great general purpose text editor and has good integration with the Haskell Language Server. If you are using VS Code, install the ◊extlink["https://marketplace.visualstudio.com/items?itemName=haskell.haskell"]{official Haskell extension}.
  }
}

I will assume that you are using VS Code with the Haskell extension and HLS on either Linux or Mac. If you are using something else, you should be able to adapt the following instructions to your situation.

To test if your install is working: Create a new directory and open it in VS Code. Create a file called ◊code{Main.hs} and copy the following into it.

◊codeblock['haskell #:name "Main.hs" #:download #t]{
  module Main where

  main :: IO ()
  main = putStrLn "Hello, world!"
}

You can execute this in a few different ways. The simplest is to use Haskell's interpreter.

◊codeblock['text]{
  ❯ runhaskell Main.hs 
  Hello, world!
}

If you want to compile ◊code{Main.hs} into an executable, do this:

◊codeblock['text]{
  ❯ ghc Main.hs 
  [1 of 1] Compiling Main             ( Main.hs, Main.o )
  Linking Main ...
}

This will create an executable ◊code{Main}, but also a ◊code{Main.o} and ◊code{Main.hi} file, both of which you can ignore. ◊aside{If you pass the flags ◊code{-no-keep-hi-files} and ◊code{-no-keep-o-files} to GHC, these files will be automatically deleted after compilation.}

◊codeblock['text]{
  ❯ ./Main
  Hello, world!
}

A final note: If you follow these instructions correctly, you will have the GHC2021 language variant enabled. If, somehow, you managed to install an old variant---such as Haskell2010 or Haskell98---you ◊em{should} be fine, but you might need to explicitly enable some language extensions. The list of extensions enabled by default in GHC2021 is available ◊extlink["https://downloads.haskell.org/ghc/latest/docs/users_guide/exts/control.html#extension-GHC2021"]{here}.

◊section[#:id "cant install haskell"]{What if I can't get Haskell working?}

I can't help you to get Haskell installed, but it might be worth trying ◊extlink["https://replit.com"]{repl.it}. It's a browser-based IDE that supports Haskell, so as long as you have a browser, you can write, compile, and run Haskell code from there. Its features are more than sufficient for this course. (It's free, but unfortunately requires sign-up to use.)

◊section{Where are the Haskell docs?}

You can visit ◊extlink["https://www.stackage.org"]{Stackage}. The search bar uses ◊extlink["https://hoogle.haskell.org/"]{Hoogle} under the hood, which you might prefer to use directly.

One useful feature is that you can search by type signature. This can help when you need a function with a particular type but are not sure what it's called.

You should get used to consulting the documentation every so often. I can't explicitly cover all built-in functions and features, even if they would be useful for solving problems. You will have to discover some features of Haskell on your own.

◊hrule

◊section{Question 1}

Here is a recursive function in Haskell which computes the exponent ◊${b^n}, for ◊${b, n \in \Z}.

◊codeblock['haskell]{
  recExp :: Integer -> Integer -> Integer
  recExp b n =
    if n == 0
      then 1
      else b * recExp b (n - 1)
}

Rewrite this algorithm in iterative style, mirroring the examples in the first lecture. Your function need not work for ◊${n < 0}.

◊; ◊section{Question 2}

◊; In the untyped lambda calculus, the Y combinator is defined as

◊; ◊$${
◊;   Y = (\lambda t.\ (\lambda x.\ t\ (x\ x)) (\lambda x.\ t\ (x\ x)))
◊; }

◊; This can be directly transcribed into Haskell like so:

◊; ◊codeblock['haskell]{
◊;   y = \t -> (\x -> t (x x)) (\x -> t (x x))
◊; }

◊; This does not type-check. Can you conclude that it is impossible to encode the Y combinator in Haskell? If you think it is impossible, justify your answer. If you think it is possible, prove it by providing a definition of the Y combinator in Haskell.

◊section{Question 2}

Consider the following program.

◊codeblock['haskell]{
  data T a = T (T a)

  facT :: T a -> Int -> Int
  facT _ 0 = 1
  facT (T t) n = n * facT t (n - 1)
  
  foo :: T a
  foo = T (T (T (T (error "⊥"))))
}

For which values of ◊code{n}, if any, does the expression ◊code{facT foo n} reduce to a value? Justify your answer.

◊section{Question 3}

Write a function which interleaves two lists. For example, ◊code{interleave [1,2,3] [4,5,6,7,8]} should return ◊code{[1,4,2,5,3,6,7,8]}.

◊codeblock['haskell]{
  interleave :: [a] -> [a] -> [a]
  interleave = undefined
}

◊section{Question 4 (Hard)}

Inhabit the following term.

◊codeblock['haskell]{
  term :: ((((a -> b) -> a) -> a) -> b) -> b
  term = undefined
}

In other words, provide a ◊em{self-contained} definition for ◊code{term} which type-checks and does not include ◊code{undefined} or any other value that reduces to ◊${\bot}. Importantly, you do not need any information other than the type signature to complete this question.
