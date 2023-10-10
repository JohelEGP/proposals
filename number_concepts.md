Doc. no:  DxxxxR0 \
Date:     2023-10-09 \
Author:   Johel Ernesto Guerrero Peña <johelegp@gmail.com> \
Reply-at: Development is currently happening at [10]. <!-- This repetition is not accidental. --> \
Audience: SG6 \
Source:   <https://github.com/johelegp/proposals/blob/master/number_concepts.md>

# The design of a library of number concepts

## Revision history

- _cv_ `void` -> R0
    + `2023y/October/09`, pre-Kona.

## Introduction

This paper presents the design of a library of number concepts.
The design differs from P1813 [5], but its feedback was taken into account.
The paper is informational because the design is known to be incomplete and lacking in usage experience.
I present this as a path forward towards having number concepts for constraining generic components.
Development is currently happening at [10]. <!-- This repetition is not accidental. -->

## History

After finding the pixel [1], Johel wrote generic components on numbers.
But those components failed to abide to the C++ Core Guidelines'
- I.9: If an interface is a template, document its parameters using concepts [2] and
- T.concepts: Concept rules [3].

So Johel armed himself with GCC's Concepts TS support,
and eventually the LLVM fork with C++ standard concepts.
He took the `Number` concept from Bjarne's presentation [4] as a starting point.
His main concerns then were to
- specify the semantics and
- to refactor it to support `std::chrono`'s `duration` and `time_point`.

He stumbled upon [6] while looking for an answer to these concerns.
The vocabulary of the first subject area of the Electropedia [7],
"Mathematics - General concepts and linear algebra",
would serve as building blocks to solve these concerns.

From there, Johel reviewed the feedback on P1813 [5] by the slides P2402 [8] and its proposal P1673 [9].
The sections "design" and "improvements" explain the actions taken and thoughts had based on these reviews.

The library then remained vitally unchanged for years.
Johel had hardly advanced his own application in the meantime.
That is what had spurred the inception and growth of the library.

Finally, on 2023-09-21, this library was proposed for merging into the mp-units library [10].
This spurred a revitalization on the improvement of the design of the library.

## Design

We hope that this library encourages the development of well-specified generic components that operate on numbers.
This section summarizes what is precisely defined in the section "API".
Additionally, we discuss what might not be evident in that reference documentation.

### Type traits

The type traits are mostly opt-in.
They are:
- The `number` opt-ins, `enable_number` and `enable_complex_number`.
- The identities, `number_zero` and `number_one`.
- The associated types, `number_different_t` and `vector_scalar_t`.

They are based on existing practice.
That is evident for the first two groups in the API.
The associated types follow the _`kind-of-structure`_`_`_`associated-type`_`_t`
of `std::iter_reference_t` and `std::ranges::range_value_t`.

### Concepts

#### `number`, common with, ordered

`number` is the least constrained number concept.
Then there are the simple `common_number_with` and `ordered_number`.
```C++
template<typename T>
concept number = enable_number_v<T> && std::regular<T>;

template<typename T, typename U>
concept common_number_with = number<T> && number<U> && std::common_with<T, U> && number<std::common_type_t<T, U>>;

template<typename T>
concept ordered_number = number<T> && std::totally_ordered<T>;
```

#### `number_line`

`number_line` is the concept that requires the complete set [26] of increment and decrement.
It is named after the term described in the Wikipedia article "Number line" [27]. \
[ _Note_:
_`decrementable`_ [28] doesn't work for number types.
- It's for integer-like types [29].
  Or we'd have to specialize `std::incrementable_traits` [30]
  with a `difference_type` that is an integer-like type
  and that is different to `number_difference_t`.
- It requires `std::regular`.
  Feedback at [10] is that it over-constrains expression templates that can't be default-initialized.

-- _end note_ ]

#### Arithmetic

Then follow the building blocks of the form (`compound_`)_`operation`_`_with`.

_`addition-with`_ requires that `+` performs an addition [20].
But addition is associative, i.e., $a + (b + c) = (a + b) + c$.
The feedback from [8] and [9] is that
- associativity is over-constraining, and
- users generally accept "associative enough".

It occurred to us that we can work around this issue in the same way integer type division [32] works.
`3 / 2` is conceptually carried out in real numbers, resulting in $1.5$.
Then, the operator `/` yields $1.5$ with the fractional part discarded, resulting in `1`.

_`addition-with`_ is specified similarly to integer type division [32].
That relaxes the associativity to "associative enough".
_`addition-with`_ requires that `a + b` performs the addition [20] 𝘍 in an unspecified set.
Then, it requires that `+` yields 𝘍 by mapping it to a value of the type of the result.

First, we introduce an unspecified set.
The over-constraining associative addition [20] is done in this unspecified set.
Then, we introduce a mapping from the addition to the result of `+`.
The mapping is left unspecified, so the result isn't over-constrained.

The operations required by refinements of `number` are specified similarly.

#### Terse

Some concepts ending in `_for` just require a single concept ending in `_with` with inverted arguments.
```C++
template<typename T, typename U>
concept modulus_for = modulo_with<U, T>;
template<typename T, typename U>
concept vector_space_for = point_space_for<U, T>;
```
These enable the terse concept syntax:
- `template<vector_space_for<Number>> auto& operator+=(vector<Number>);`.
- `auto operator%(modulus_for<Number> auto);`.

#### Algebraic structures

Finally, the building blocks are used to define some helpers.
These helpers are used to define heterogeneous concepts on algebraic structures.
There also are homogeneous counterparts with a default.

| Concept             | Close model                        |
|:--------------------|:-----------------------------------|
| `point_space`       | `std::chrono::sys_seconds`         |
| `f_vector_space`    | `std::chrono::seconds`             |
| `field_number`      | `std::complex<double>`             |
| `field_number_line` | `double`                           |
| `scalar_number`     | `double` or `std::complex<double>` |

## Improvements

Development is currently happening at [10]. <!-- This repetition is not accidental. -->

### Relax to generalize

The concepts are known to be over-constraining for templates like `boost::hana::int_c` [11].
The feedback from [10] suggests its time for the hierarchy to be refactored.
This will allow a wider variety of number templates that make interesting uses of the type system.

### More operations

There are operations beyond those required by the definition of a vector space [12].

P2980 [15] needs some of those to specify some quantities.
Just like there are scalar quantities [14], there are vector and tensor quantities.
An example is speed [24] (a scalar quantity [14]),
defined as the magnitude [18] of the velocity [25] (a vector quantity).
Here are other operations from [13]:
```C++
concept VectorRepresentation = std::regular<T> && Vector<T> &&
  requires(T a, T b, std::intmax_t i, long double f) {
    …
    { dot_product(a, b) } -> Scalar;
    { cross_product(a, b) } -> Vector;
    { tensor_product(a, b) } -> Tensor;
    { norm(a) } -> Scalar;
  };
concept TensorRepresentation = std::regular<T> && Tensor<T> &&
  requires(T a, T b, std::intmax_t i, long double f) {
    …
    { tensor_product(a, b) } -> Tensor;
    { inner_product(a, b) } -> Tensor;
    { scalar_product(a, b) } -> Scalar;
  };
```

Scalars, vectors, and tensors are vector spaces [12].
The number concepts library has `scalar_number`, which represents a scalar [16].
`vector_space` could be refined with these additional operations to support vectors and tensors.

But vector is an overloaded word.
Its Wikipedia article [17] says
> In mathematics and physics,
> vector is a term that refers colloquially to some quantities
> that cannot be expressed by a single number (a scalar),
> or to elements of some vector spaces.

`vector_space` can be renamed to the alternative term `linear_space` [12].
Then we could add `vector` for the colloquial "tuple of 2 or more scalars" and `tensor`.

The C++ standard library offers many more operations on arithmetic types,
which are models of `scalar_number`.
mp-units also offers a subset of those [31] for `mp_units::quantity`,
whose specializations model `vector_space`.
The current design of the number concepts library doesn't consider generalizing this.

Development is currently happening at [10]. <!-- This repetition is not accidental. -->

### Mixed expressions

Mixed expressions refers to expressions with more than two operands.
[9] describes, in particular in §10.8.4, why concepts generally are of little help.

The number concepts only require expressions with up to two operands.
But an implementation of an algorithm might need to use more mixed expressions.
The unfeasible alternative would be to include all possible constraints an algorithm might use.

For example, the magnitude of a 2-dimensional Cartesian vector is $|𝙫| = √𝘹²+𝘺²$ [18].
Consider a C++ representation like this:
```C++
template<scalar_number Number>
struct vector2d {
  Number x;
  Number y;

  // A faster alternative when just ordering by magnitude.
  auto square_magnitude() { return x * x + y * y; }
};
```
`scalar_number` requires that the type of `Number` squared models `common_number_with<Number>`.
But it doesn't require that adding squared `Number`s works.
The best we could do is adding the additional constraint for the result of `Number` squared.
It could be `point_space`, the weakest constraint, as required by the algorithm.
Or it could be `scalar_number`, the same constraint as `Number`, as users would expect of the return value.
In code, it would look like a trailing `requires scalar_number<decltype(x * x)>`.
That doesn't scale to even more mixed expressions.

One of the points [9] summarizes is:
> - We can and do use existing Standard language, like _GENERALIZED_SUM_,
>   for expressing permissions that algorithms have.

For _GENERALIZED_SUM_, see [19].
I agree with [9] on this point.
But that doesn't preclude constraining algorithms with number concepts.

There is still value in [2] and [3].
The number concepts in this library already don't require the result of addition [20] to be associative.
It's also possible to require that mixed expression work as one would naturally expect.
This can be done by adding an extra semantic requirement on refinements of `number`.

How to deal with this lies in the use of `common_number_with` in refinements of `number`.
`common_number_with<T, U>` subsumes `std::common_with<T, U>` [21].
Although it's not part of `std::common_width`,
`std::common_type_t<T, U>` also generally behaves like `T` and `U`.

This is the idea for the semantic requirement on refinements of `number`.
If `common_number_with<T, U>` is required,
the user can use `T` in place of `U`, and
the semantic constraints on `U` also apply to `T`.

Let's reconsider the example of `auto square_magnitude() { return x * x + y * y; }` with this requirement.
`scalar_number<Number>` requires `{ c * u } -> common_number_with<V>;`,
which is essentially `{ x * x } -> common_number_with<Number>;`.
Even if the type of `Number` squared isn't the same as `Number`,
the semantic constraints of `scalar_number<decltype(x * x)>` apply
when the user writes one of its required expressions.
In this case, the algorithm is required to work as expected.

It is the intent that this doesn't preclude the `+` on squared `Number`s from being ill-formed.
It is also the intent that the `+` on squared `Number`s
is still not required to be a total function [22] or to be valid for all input values [23].
I.e., the result can still be incorrect or exit via an exception.

The worth of this formulation is that you can meet [2] and [3].
Even if an algorithm still needs to be more specific as with _GENERALIZED_SUM_ [19].

Development is currently happening at [10]. <!-- This repetition is not accidental. -->

## Comparisons

### P1813 [5]

The algorithms from `<numeric>` still don't have constrained counterparts in C++23's `std::ranges`.
P1813 aimed to remedy that.
P1813's approach to specifying algebraic structures was bottom-up.
The feedback [8] and [9] gave was that this is over-constraining.

This paper's approach is instead top-down.
Having started from Bjarne's `Number`,
we have refactored the existing concepts as need arise.

`<numeric>` algorithms work with numeric expressions or have overloads with function objects.
The precise suitability of the number concepts for constrained overloads hasn't been studied.
The unconstrained versions `std::accumulate` already allows accumulating on a `std::string`.
We would expect its constrained version to allow the same.

## API

This is a reference documentation.

Any resemblance to wording is purely incidental.

For now, please use the PDF at <https://github.com/mpusz/mp-units/pull/492#issuecomment-1730447738>.

## Acknowledgements

I'd like to thank Mateusz Pusz for encouraging me to write a paper about this number concepts library.

I'd also like to thank him and the other reviewers of [10] for their stimulating feedback.
It has brought back memories of the mostly unwritten history, design and improvements of these concepts.

All the advertised improvements over previous work
is thanks to the existence of [5] and its feedback by [8] and [9].
So thank you to everyone involved for making this possible.

## References

[1] Show off the power of the new variadic dimensions system · Issue #124 · nholthaus/units, <https://github.com/nholthaus/units/issues/124#issuecomment-390773279> \
[2] C++ Core Guidelines -- I.9: If an interface is a template, document its parameters using concepts, <https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Ri-concepts> \
[3] C++ Core Guidelines -- T.concepts: Concept rules, <https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#SS-concepts> \
[4] CppCon 2018: Bjarne Stroustrup “Concepts: The Future of Generic Programming (the future is here)”, <https://youtu.be/HddFGPTAmtU?t=3504> \
[5] A Concept Design for the Numeric Algorithms, <https://wg21.link/P1813> \
[6] [intro.defs], <https://eel.is/c++draft/intro.defs#2.2> \
[7] IEC 60050 - International Electrotechnical Vocabulary - Welcome, <https://www.electropedia.org/iev/iev.nsf/index?openform&part=102> \
[8] A free function linear algebra interface based on the BLAS (slides), <https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2021/p2402r0.pdf> \
[9] A free function linear algebra interface based on the BLAS, <https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/p1673r12.html#constraining-matrix-and-vector-element-types-and-scalars> \
[10] feat!: add number concepts by JohelEGP · Pull Request #492 · mpusz/mp-units, <https://github.com/mpusz/mp-units/pull/492> \
[11] Boost.Hana: boost::hana::integral_constant< T, v > Struct Template Reference, <https://www.boost.org/doc/libs/1_83_0/libs/hana/doc/html/structboost_1_1hana_1_1integral__constant.html#autotoc_md0> \
[12] IEC 60050 - International Electrotechnical Vocabulary - Details for IEV number 102-03-01: "vector space", <https://www.electropedia.org/iev/iev.nsf/display?openform&ievref=102-03-01> \
[13] Vector and Tensor quantities by mpusz · Pull Request #493 · mpusz/mp-units, <https://github.com/mpusz/mp-units/pull/493> \
[14] IEC 60050 - International Electrotechnical Vocabulary - Details for IEV number 102-02-19: "scalar quantity", <https://www.electropedia.org/iev/iev.nsf/display?openform&ievref=102-02-19> \
[15] A motivation, scope, and plan for a physical quantities and units library, <https://wg21.link/P2980R0#systems-of-quantities> \
[16] IEC 60050 - International Electrotechnical Vocabulary - Details for IEV number 102-02-18: "scalar", <https://www.electropedia.org/iev/iev.nsf/display?openform&ievref=102-02-18> \
[17] Vector (mathematics and physics) - Wikipedia, <https://en.wikipedia.org/wiki/Vector_(mathematics_and_physics)> \
[18] IEC 60050 - International Electrotechnical Vocabulary - Details for IEV number 102-03-23: "magnitude", <https://www.electropedia.org/iev/iev.nsf/display?openform&ievref=102-03-23> \
[19] [numeric.ops], <https://eel.is/c++draft/numeric.ops> \
[20] IEC 60050 - International Electrotechnical Vocabulary - Details for IEV number 102-01-11: "addition", <https://www.electropedia.org/iev/iev.nsf/display?openform&ievref=102-01-11> \
[21] [concept.common], <https://eel.is/c++draft/concept.common> \
[22] [structure.requirements], <https://eel.is/c++draft/structure.requirements#8> \
[23] [concepts.equality], <https://eel.is/c++draft/concepts.equality#2> \
[24] IEC 60050 - International Electrotechnical Vocabulary - Details for IEV number 113-01-33: "speed", <https://www.electropedia.org/iev/iev.nsf/display?openform&ievref=113-01-33> \
[25] IEC 60050 - International Electrotechnical Vocabulary - Details for IEV number 113-01-32: "velocity", <https://www.electropedia.org/iev/iev.nsf/display?openform&ievref=113-01-32> \
[26] C++ Core Guidelines -- T.21: Require a complete set of operations for a concept, <https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Rt-complete> \
[27] Number line - Wikipedia, <https://en.wikipedia.org/wiki/Number_line> \
[28] [range.iota], <https://eel.is/c++draft/range.iota#concept:decrementable> \
[29] [iterator.concept.winc], <https://eel.is/c++draft/iterator.concept.winc> \
[30] [incrementable.traits], <https://eel.is/c++draft/incrementable.traits> \
[31] mp-units/src/utility/include/mp-units/math.h at v2.0.0 · mpusz/mp-units, <https://github.com/mpusz/mp-units/blob/v2.0.0/src/utility/include/mp-units/math.h> \
[32] [expr.mul], <https://eel.is/c++draft/expr.mul#4.sentence-3>
