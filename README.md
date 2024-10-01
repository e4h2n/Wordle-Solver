This is an assignment from CSE13s Computer Systems and C programming at the University of California, Santa Cruz.

## usage

In this directory, run ``./solver`` with no arguments to run the solver with an anonymous word, entering grey/yellow/green response every guess. Run ``./solver xxxxx`` where ``xxxxx`` is a 5-letter word to run the solver automatically on that word.

## picking a word to guess

There has been a lot of discussion on how to find the *optimal* guess words in
wordle (for example, see the [excellent](https://youtu.be/v68zYyaEmEA)
[videos](https://youtu.be/fRed0Xmc2Wg) from educational math YouTuber
3Blue1Brown) but here we will use a simple heuristic score -- we pick the
word that contains the letters that occur most commonly in the remaining
possible vocabulary.

So at each step in our solver, we select the word that maximizes the following
expression:

```
  score(word | vocabulary) = sum(score(letter | vocabulary), for unique letters in word)
```

where

```
  score(letter | vocabulary) = # words in vocabulary that contain letter
```

Why do we care about only considering *unique* letters? Well, if we
do not, we will only get information about the most common letters. If we do not
include this restriction, our first guess (given the initial vocabulary) will be
"eerie", since 'e' is so common. But the answer for the word "eerie" is only so
informative -- we could do better by including a more diverse selection of
common letters! (you could [formalize this by quantifying how many bits of
information you will learn by asking the
question](https://en.wikipedia.org/wiki/Entropy_(information_theory)).

Empirically, this heuristic works fairly well, and paired with the approaches to
whittling the vocabulary described in the next section, each guess causes the
size of our search space to *drasticly* go down.

## paring down our vocabulary

Every time we get feedback from a guess, this gives us the opportunity to cut
down the remaining vocabulary list, eliminating many words from consideration!

Each color in the response gives us information, constraining the remaining
search space. Here we guess "irate", and the official Wordle game will gave us
back at some point in the past: gray, green, gray, yellow, green. We represent
this in our programs as "xgxyg".

This means that 'r' and 'e' are in the correct place, and 't' is present
somewhere in the word, but not in the spot that we guessed. Also, 'i' and 'a' do
not appear in the true secret word. That's a lot of information! How can we
apply it?

### limiting the vocabulary based on "gray" responses

If we know that a letter is not present in the secret word, then we can simply
remove any word in the vocabulary if it contains that letter!

So for example, if we find out that the letter 'm' is not in the secret word,
then any word that *does* contain 'm' is not the secret word and can be safely
eliminated.

How do we eliminate words from our vocabulary? Recall that we've been
representing our vocabularies as an array of `char *` pointers, so a
dynamically-sized array of type `char **`. That means that each element of the
outer array is a pointer to a string.

We can simply free that string and set the corresponding pointer in the outer
array to `NULL`. And then the word is eliminated from consideration! We need to
make sure all functions that iterate over the vocabulary are robust to having
pointers in the outer array being `NULL` -- if we find a NULL pointer, just skip
it!

There is one more wrinkle on "gray" responses, and it is slightly subtle -- we
did not handle this particular rule in the previous homework -- if a letter
appears multiple times in a guess, but fewer times in the secret word, then the
"extra" instances of that letter are marked as gray in the wordle response. You
do not have to worry about this rule in your code, but it is addressed in
`solver.c`, so read the code and comment there if you are curious.

### limiting the vocabulary based on "yellow" responses

Similarly, a "yellow" response for a letter means that the corresponding letter
in the guess *appears in the secret word*, but interestingly, not in the
location that was guessed.

This means that we can eliminate any word that does not contain that particular
letter. But moreover, we can eliminate any word that contains the letter, in the
specific spot that was guessed!

### limiting the vocabulary based on "green" responses

Finally, the simplest case is "green" responses. Green responses allow us to
eliminate any word from the vocabulary that does not contain the specified
letter in the specified spot.
