---
title: Lua doesn't like you, or, a table is not always a table
tags: lua, maygodhavemercy
---

In Lua, everything is a table, and everything that isn't a table is just syntax sugar around a table.

But of course, having only tables - which are hashmaps - is kind of cumbersome - what if you want an array instead of a hashmap?

So of course, tables can also be arrays.

Observe:

    ~ % lua                                                                                                                      ~
    Lua 5.3.4  Copyright (C) 1994-2017 Lua.org, PUC-Rio
    > t={}
    > t[1]="foo"; t[2]="bar"; t[3]="baz"
    > i,v = next(t,nil)
    > while i do
    >> print(i,v)
    >> i,v=next(t,i)
    >> end
    1	foo
    2	bar
    3	baz
    > t[1]=nil
    > t[8]="foo"
    > i,v = next(t,nil)
    > while i do
    print(i,v)
    i,v=next(t,i)
    end
    8	foo
    2	bar
    3	baz
    > 

As long as you have a table that looks like an array - which lua also has syntax sugar for creating:

    > t = {"foo","bar","baz"}
    > t[1]
    foo
    > t[3]
    baz

\- iterating it (`next` is the "primitive" for iteration in lua) will behave nice and iterate in key order.

If your table doesn't... well, it'll be hash order. Good luck.
