Doc. no:  DxxxxR0 \
Date:     2019-01-01 \
Reply-to: Johel Guerrero <johelegp@gmail.com> \
Audience: Library Incubator \
Source:   https://github.com/johelegp/proposals/blob/master/is_clamped.md

# `is_clamped`

## Abstract

Introduce `std::is_clamped(v, lo, hi)` to mean `lo <= v && v <= hi`,
except that `v` is only evaluated once.

## Problem

Expressions equivalent to `lo <= v && v <= hi` are common.
They are used to check whether `v` is within the range [`lo`, `hi`].
However, because `v` appears twice, they
- are error prone to type and update,
- reduce readability as `v` gets longer, and
- may degrade performance due to the repeated evaluation of `v`.

We propose `std::is_clamped(v, lo, hi)` as an alternative spelling
that better captures intent and is potentially more performant.

## Alternatives

### Chaining Comparisons (rejected)

P0893 [1] would have allowed us to write `lo <= v <= hi`.
Its rejection made us write this proposal.

> There was no consensus on making comparison operators chain,
> nor was there encouragement for further work in that area. \
> -- P1018R2 [2]

### Initialize intermediate variable with `v`

It may be undesirable for some of the reasons
selection and iteration statements have been getting space for initialization.

In some contexts it is impossible,
such as member intializer lists and requires clauses.

### Immediately invoked lambda expression

This works, at the cost of much syntactical noise on par with repeating `v`:
- `[&] { const auto& w{v}; return `_`what we actually care about`_`; }()`, or
- `[](const auto& v) { return `_`what we actually care about`_`; }(v)`.

## Wording

Add the following declarations to [algorithm.syn] after those of `clamp`.

```C++
template<class T>
  constexpr bool is_clamped(const T& v, const T& lo, const T& hi);
template<class T, class Compare>
  constexpr bool is_clamped(const T& v, const T& lo, const T& hi, Compare comp);

namespace ranges {
  template<class T, class Proj = identity,
           IndirectStrictWeakOrder<projected<const T*, Proj>> Comp = ranges::less<>>
    constexpr bool is_clamped(const T& v, const T& lo, const T& hi, Comp comp = {}, Proj proj = {});
}
```

Add the following detailed specifications to [alg.clamp] after those of `clamp`.

```C++
template<class T>
  constexpr bool is_clamped(const T& v, const T& lo, const T& hi);
template<class T, class Compare>
  constexpr bool is_clamped(const T& v, const T& lo, const T& hi, Compare comp);

namespace ranges {
  template<class T, class Proj = identity,
           IndirectStrictWeakOrder<projected<const T*, Proj>> Comp = ranges::less<>>
    constexpr bool is_clamped(const T& v, const T& lo, const T& hi, Comp comp = {}, Proj proj = {});
}
```
_Expects:_ The value of `lo` is no greater than `hi`.
For the first form, type `T` shall be _Cpp17LessThanComparable_ (Table 24).

_Returns:_ `true` if
- `v` is not less than `lo`, and
- `hi` is not less than `v`. \
Otherwise, `false`.

[ _Note:_ If NaN is avoided, `T` can be a floating-point type. -- _end note_ ]

_Complexity:_ At most two comparisons and
three applications of the projection, if any.

## Possible implementation

```C++
template<class T>
  constexpr bool is_clamped(const T& v, const T& lo, const T& hi)
{
  return !(v < lo) && !(hi < v);
}

template<class T, class Compare>
  constexpr bool is_clamped(const T& v, const T& lo, const T& hi, Compare comp)
{
  return !comp(v, lo) && !comp(hi, v);
}

namespace ranges {
  template<class T, class Proj = identity,
           IndirectStrictWeakOrder<projected<const T*, Proj>> Comp = ranges::less<>>
    constexpr bool is_clamped(const T& v, const T& lo, const T& hi, Comp comp = {}, Proj proj = {})
  {
    auto&& pv{invoke(proj, v)};
    return !invoke(comp, pv, invoke(proj, lo)) &&
           !invoke(comp, invoke(proj, hi), pv);
  }
}
```

## Revision history

- _cv_ `void` -> R0
    + `2019y/January/1`, pre-Kona.

## Related proposals

| Paper     | Title                  | Relation                         |
| --------- | ---------------------- | -------------------------------- |
| P1243 [3] | Rangify New Algorithms | Introduces `std::ranges::clamp`. |

## References

\[1]: https://wg21.link/P0893 \
\[2]: https://wg21.link/P1018r2 \
\[3]: https://wg21.link/P1234
