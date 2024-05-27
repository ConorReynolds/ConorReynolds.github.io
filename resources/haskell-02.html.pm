#lang pollen

◊(define-meta title "Haskell Assignment Sheet 2")
◊(define-meta toc-title "Haskell Assignment Sheet 2")
◊(define-meta subtitle "Data, types, and typeclasses")
◊(define-meta math? #true)
◊(define-meta created "2023-03-07")

◊section{Submission Instructions}

Similar to the ◊xref["resources/haskell-01.html#Submission Instructions"]{previous assignment}---you must submit a ◊bold{single Haskell file} with the following template.

◊codeblock['haskell #:name "Assignment02.hs" #:download #t]{
  module Assignment02 where

  -----------------------------------------------------------
  -- QUESTION 1
  
  
  -----------------------------------------------------------
  -- QUESTION 2
  

  -----------------------------------------------------------
  -- QUESTION 3


  -----------------------------------------------------------
  -- QUESTION 4

  {-
    Write your answer as a comment here.
  -}
}

You can download the template using the ◊i[#:class "fa fa-download" #:style "position: relative; margin: 0 0.1em 0 0.1em; top: -0.05em; font-size: 0.9em; color: var(--muted-color);"] button next to the file name. You can also copy any code snippet by hovering over it and clicking the ◊i[#:class "fa fa-copy" #:style "margin: 0 0.1em 0 0.1em; color: var(--muted-color);"] button which appears on the top right.

◊warning{
  Your file name and module name ◊em{must} match the template---any other file or module name will be rejected.
  
  You may ◊em{not} use any imports to solve this lab. If your file contains an import statement, you will get zero marks.
}

◊hrule

◊section{Question 1}

Write a function which accepts a list of directions and uses that list to update the position of a point in space. Here is an example of how it should work.

◊codeblock['bash]{
  ghci> receiveAndProc
  L L L L L U U U D R U  # user input
  (-4,3)
}

Use the following template.

◊codeblock['haskell]{
  -- Represents a direction: left, right, up, down.
  data Direction = L | R | U | D
    deriving (Show, Read)

  -- Represents a position on a grid.
  type Position = (Int, Int)

  -- This is where the main work should happen.
  -- Examples:
  --   process [L,L,L,U,U] (0,0) == (-3,2)
  --   process [L,R,U,U,D,R] (1,-1) == (2,0)
  process :: [Direction] -> Position -> Position
  process = undefined

  -- This should read a space-separated list of directions
  -- and determine the new position of the point (0,0).
  receiveAndProc :: IO ()
  receiveAndProc = do
    undefined
}

You will find the following functions useful.

◊codeblock['haskell]{
  -- Simple parsing for ‘readable’ types. If Haskell can’t
  -- infer what the return type is from context, you will
  -- need to provide it like this:
  --    read @Int :: String -> Int
  --    read @Direction :: String -> Direction
  -- The @-symbol is, in this context, a ‘type application’
  -- operator — it specialises the type signature to a type
  -- that implements the Read typeclass.
  read :: Read a => String -> a

  -- Splits a string by whitespace.
  -- Example:
  --   words "1 2\n3" == ["1", "2", "3"]
  words :: String -> [String]

  -- Applies a function to each of the elements of a list.
  -- Example:
  --   map (+1) [1,2,3] == [2,3,4]
  map :: (a -> b) -> [a] -> [b]
}
◊; ◊section{Question 2}

◊; Is it possible to write a total function with the type ◊code{[a] -> a}?

◊section{Question 2}

Recall the following data type from the lectures.

◊codeblock['haskell]{
  data SimpleIO a
    = Put String (SimpleIO a)
    | Get (String -> SimpleIO a)
    | Return a
}

Write a function

◊codeblock['haskell]{
  exclaim :: SimpleIO a -> SimpleIO a
  exclaim = undefined
}

which takes a ◊code{SimpleIO} computation and appends an exclamation mark to every string that is ◊code{Put}. To test this, you will need the following:

◊codeblock['haskell]{
  io :: SimpleIO a -> IO a
  io computation =
    case computation of
      Put s rest -> do
        putStrLn s
        io rest

      Get k -> do
        s <- getLine
        io (k s)

      Return a ->
        return a
  
  example :: SimpleIO ()
  example =
    Put "Hello" $
    Get $ \name ->
    Put ("My name is " ++ name) $
    Return ()
}

For example:

◊codeblock['bash]{
  ghci> io example
  Hello
  Conor  # user input
  My name is Conor

  ghci> io (exclaim example)
  Hello!
  Conor  # user input
  My name is Conor!
}

◊section{Question 3}

Traditionally, monads are triples

◊$${
  \langle M, \; \eta : 1 \to M, \; \mu : M^2 \to M \rangle
}

You are already familiar with ◊${\eta}---that's ◊code{return} in Haskell. But ◊${\mu} is unfamiliar. In Haskell it is called ◊extlink["https://www.stackage.org/haddock/lts-20.15/base-4.16.4.0/Control-Monad.html#v:join"]{◊code{join}}, and has the type ◊code{Monad m => m (m a) -> m a}. It is possible---and sometimes easier---to define a monad in terms of ◊code{join} instead of ◊code{(>>=)}.

Provide a monad instance for the type ◊code{Arrow r} by defining ◊code{return} and ◊code{join}, where ◊code{join} is called ◊code{arrowJoin}, by replacing each ◊code{undefined} with working code. ◊aside{If, for some reason, you are running an older version of Haskell, you may need to explicitly enable the Generalized◊|soft-hyphen|Newtype◊|soft-hyphen|Deriving language extension.}

◊codeblock['haskell]{
  newtype Arrow r a = Arrow { apply :: r -> a }
    deriving (Functor, Applicative)

  instance Monad (Arrow r) where
    return a = undefined
    m >>= f = arrowJoin (fmap f m)

  arrowJoin :: Arrow r (Arrow r a) -> Arrow r a
  arrowJoin arrow = undefined
}

◊section{Question 4 (Hard)}

Prove that the monad instance you defined in ◊xref["#Question 3"]{Question 3} satisfies the following monad law: ◊aside{Note that ◊code{(.)} is function composition, which is defined ◊code{g . f = \x -> g (f x)}, and ◊code{id} is the identity function, defined by ◊code{id x = x}.}

◊codeblock['text]{
  join . return = id
}

In practice, this means that, for an arbitrary ◊code{x :: Arrow r a}, you should show the following:

◊codeblock['text]{
  arrowJoin (return x) = x
}

Write this proof as a comment in your Haskell file. 
