# Hash Compare

## What's Hash Compare?

Hash Compare is a new solution to
compare two hashes in a similar style to
how git does. It supports deep and shallow
comparisons.

```
ex output:

hash1 = {
  "a" => [
    "a1",
    "a2",
    "a3",
    {
      "c" => ["d", true]
    }
  ]
}

hash2 = {
  "a" => [
    "a1",
    "a2",
    "a4",
    {
      "c" => %w[e d1]
    }
  ],
  "b" => "c"
}

irb> puts HashCompare.to_s(hash1, hash2)

a =>
  <<<<<< hash1
  =======
  a3
  >>>>>> hash2
  c =>
    <<<<<< hash1
    e
    d1
    =======
    d
    >>>>>> hash2
b =>
  <<<<<< hash1
  c
  =======
  >>>>>> hash2
```