# Developer Documentation

## Function Naming Guidelines

Following the Julia style guidelines, functions that mutate arguments should
end with `!`.  Following the JuMP style guidelines functions beginning with
an `_` are intended for internal package use only (i.e. similar private
scope functions).  Underscores are used to separate multi-word function names
and the words should typically be ordered from general to more specific,
so that alphabetical sorting clusters similar functions together.

Due to model-agnostic design of PowerModels, top level functions are implicitly defined on complex numbers.  Specializations of these functions yield different complex coordinates systems and real-valued model parameters.

Top level functions have the following structure,

```
<variable|constraint>_<component short name>_<quantity name>(_fr|_to)(_on_off)
```

The suffixes have the following meanings,

  - `_fr`: the from-side of a two-terminal component (e.g., branch or switch)
  - `_to`: the to-side of a two-terminal component (e.g., branch or switch)
  - `_on_off`: indicates that the constraint can be added or removed with a discrete 0-1 indicator variable.
    Note that the from-to orientation of two-terminal components is often arbitrary and does not imply a direction of flow.

The most common values of `<quantity name>` are `power`, `current` and `voltage`.  Compound names like `voltage_product` are also possible.

Lower level functions have the following structure,

```
<variable|constraint>_<component short name>_<quantity name>
(_real|_imaginary|_magnitude|_angle|_factor)(_fr|_to)(_sqr)(_on_off)
```

The additional suffixes have the following meanings,

  - `_real`: the real component of a complex value in rectangular coordinates
  - `_imaginary`: the imaginary component of a complex value in rectangular coordinates
  - `_magnitude`: the magnitude of a complex value in polar coordinates
  - `_angle`: the angle of a complex value in polar coordinates
  - `_factor`: a continuous real value (usually in the range 0.0 to 1.0), that scales a complex value in equal proportions
  - `_sqr`: the square of a value, usually paired with `_magnitude`

### Special Cases

In the interest of intuitive names for users, the following special cases are also acceptable,

  - The value of `<component short name>` can be omitted from constraint definitions for one of the canonical components that it applies to.
  - `_power_real` -(can be replaced with)-> `_active`
  - `_power_imaginary` -(can be replaced with)-> `_reactive`

## Variable and Parameter Naming Guidelines

### Power

Defining power $s = p + j \cdot q$ and $sm = |s|$

  - `s`: complex power (VA)
  - `sm`: apparent power (VA)
  - `p`: active power (W)
  - `q`: reactive power (var)

### Voltage

Defining voltage $v = vm \angle va = vr + j \cdot vi$:

  - `vm`: magnitude of (complex) voltage (V)
  - `va`: angle of complex voltage (rad)
  - `vr`: real part of (complex) voltage (V)
  - `vi`: imaginary part of complex voltage (V)

### Current

Defining current $c = cm \angle ca = cr + j \cdot ci$:

  - `cm`: magnitude of (complex) current (A)
  - `ca`: angle of complex current (rad)
  - `cr`: real part of (complex) current (A)
  - `ci`: imaginary part of complex current (A)

### Voltage products

Defining voltage product $w = v_i \cdot v_j$ then
$w = wm \angle wa = wr + j\cdot wi$:

  - `wm` (short for vvm): magnitude of (complex) voltage products (V$^2$)
  - `wa` (short for vva): angle of complex voltage products (rad)
  - `wr` (short for vvr): real part of (complex) voltage products (V$^2$)
  - `wi` (short for vvi): imaginary part of complex voltage products (V$^2$)

### Current products

Defining current product $cc = c_i \cdot c_j$ then
$cc = ccm \angle cca = ccr + j\cdot cci$:

  - `ccm`: magnitude of (complex) current products (A$^2$)
  - `cca`: angle of complex current products (rad)
  - `ccr`: real part of (complex) current products (A$^2$)
  - `cci`: imaginary part of complex current products (A$^2$)

### Transformer ratio

Defining complex transformer ratio
$t = tm \angle ta = tr + j\cdot ti$:

  - `tm`: magnitude of (complex) transformer ratio (-)
  - `ta`: angle of complex transformer ratio (rad)
  - `tr`: real part of (complex) transformer ratio (-)
  - `ti`: imaginary part of complex transformer ratio (-)

### Impedance

Defining impedance
$z = r + j\cdot x$:

  - `r`: resistance ($\Omega$)
  - `x`: reactance ($\Omega$)

### Admittance

Defining admittance
$y = g + j\cdot b$:

  - `g`: conductance ($S$)
  - `b`: susceptance ($S$)

### Standard Value Names

  - network ids:`network`, `nw`, `n`
  - conductors ids: `conductor`, `cnd`, `c`
  - phase ids: `phase`, `ph`, `h`

## DistFlow Derivation

### For an asymmetric pi section

Following notation of [^1], but recognizing it derives the SOC BFM without shunts.
In a pi-section, part of the total current $I_{lij}$ at the from side flows
through the series impedance, $I^{s}_{lij}$, part of it flows through the from
side shunt admittance $I^{sh}_{lij}$. Vice versa for the to-side. Indicated by
superscripts 's' (series) and 'sh' (shunt).

```math
\begin{align}
& \mbox{Ohm's law: }  U^{mag}_{j} \angle \theta_{j} = U^{mag}_{i}\angle \theta_{i}  - z^{s}_{lij} \cdot I^{s}_{lij} \nonumber \\
& \mbox{KCL at shunts: }  I_{lij} = I^{s}_{lij} + I^{sh}_{lij}, I_{lji} = I^{s}_{lji} + I^{sh}_{lji} \nonumber \\
& \mbox{Observing: }  Observing: I^{s}_{lij} = - I^{s}_{lji}, \vert I^{s}_{lij} \vert = \vert I^{s}_{lji} \vert \nonumber \\
& \mbox{Ohm's law times its own complex conjugate: } (U^{mag}_{j})^2 = (U^{mag}_{i}\angle \theta_{i}  - z^{s}_{lij} \cdot I^{s}_{lij})\cdot (U^{mag}_{i}\angle \theta_{i}  - z^{s}_{lij} \cdot I^{s}_{lij})^* \nonumber \\
& \mbox{Defining: } S^{s}_{lij} = P^{s}_{lij} + j\cdot Q^{s}_{lij} = (U^{mag}_{i}\angle \theta_{i}) \cdot (I^{s}_{lij})^* \nonumber \\
& \mbox{Working it out: } (U^{mag}_{j})^2 = (U^{mag}_{i})^2 - 2 \cdot(r^{s}_{lij} \cdot P^{s}_{lij} + x^{s}_{lij} \cdot Q^{s}_{lij})  + ((r^{s}_{lij})^2 + (x^{s}_{lij})^2)\vert I^{s}_{lij} \vert^2 \nonumber \\
\end{align}
```

Power flow balance w.r.t. branch *total* losses

```math
\begin{align}
& \mbox{Active power flow: } P_{lij} + P_{lji} = g^{sh}_{lij} \cdot (U^{mag}_{i})^2 + r^{s}_{l} \cdot \vert I^{s}_{lij} \vert^2 +  g^{sh}_{lji} \cdot (U^{mag}_{j})^2 \nonumber \\
& \mbox{Reactive power flow: } Q_{lij} + Q_{lji} = -b^{sh}_{lij} \cdot (U^{mag}_{i})^2 + x^{s}_{l} \cdot \vert I^{s}_{lij} \vert^2  - b^{sh}_{lji} \cdot (U^{mag}_{j})^2 \nonumber \\
& \mbox{Current definition: } \vert S^{s}_{lij} \vert^2 = (U^{mag}_{i})^2 \cdot \vert I^{s}_{lij} \vert^2 \nonumber \\
\end{align}
```

Substitution:

```math
\begin{align}
& \mbox{Voltage from: } (U^{mag}_{i})^2 \rightarrow w_{i} \nonumber \\
& \mbox{Voltage to: } (U^{mag}_{j})^2 \rightarrow w_{j} \nonumber \\
& \mbox{Series current: } \vert I^{s}_{lij} \vert^2  \rightarrow l^{s}_{l} \nonumber \\
\end{align}
```

Note that $l^{s}_{l}$ represents squared magnitude of the *series* current,
i.e. the current flow through the series impedance in the pi-model.
Power flow balance w.r.t. branch *total* losses

```math
\begin{align}
& \mbox{Active power flow: } P_{lij} + P_{lji} = g^{sh}_{lij} \cdot w_{i} + r^{s}_{l} \cdot l^{s}_{l} +  g^{sh}_{lji} \cdot  w_{j}  \nonumber \\
& \mbox{Reactive power flow: } Q_{lij} + Q_{lji} = -b^{sh}_{lij} \cdot w_{i} + x^{s}_{l} \cdot l^{s}_{l}  - b^{sh}_{lji} \cdot  w_{j} \nonumber \\
\end{align}
```

Power flow balance w.r.t. branch *series* losses:

```math
\begin{align}
& \mbox{Active power flow: } P^{s}_{lij} + P^{s}_{lji}  = r^{s}_{l} \cdot l^{s}_{l}  \nonumber \\
& \mbox{Reactive power flow: } Q^{s}_{lij} + Q^{s}_{lji}  = x^{s}_{l} \cdot l^{s}_{l}  \nonumber \\
\end{align}
```

Valid equality to link $w_{i}, l_{lij}, P^{s}_{lij}, Q^{s}_{lij}$:

```math
\begin{align}
& \mbox{Nonconvex current definition: } (P^{s}_{lij})^2 + (Q^{s}_{lij})^2   =w_{i} \cdot l_{lij}  \nonumber \\
& \mbox{SOC current definition: } (P^{s}_{lij})^2 + (Q^{s}_{lij})^2   \leq w_{i} \cdot l_{lij}  \nonumber \\
\end{align}
```

### Adding an ideal transformer

Adding an ideal transformer at the from side implicitly creates an internal
branch voltage, between the transformer and the pi-section.

```math
\begin{align}
& \mbox{New voltage: } w^{'}_{l} \nonumber \\
& \mbox{Ideal voltage magnitude transformer: } w^{'}_{l} = \frac{w_{i}}{(t^{mag})^2} \nonumber \\
\end{align}
```

W.r.t to the pi-section only formulation, we effectively perform the following substitution in all the equations above:

```math
\begin{align}
& w_{i} \rightarrow \frac{w_{i}}{(t^{mag})^2} \nonumber \\
\end{align}
```

The branch's power balance isn't otherwise impacted by adding the ideal transformer, as such transformer is lossless.

### Adding total current limits

```math
\begin{align}
& \mbox{Total current from: }  \vert I_{lij} \vert \leq I^{rated}_{l} \nonumber \\
& \mbox{Total current to: }  \vert I_{lji} \vert \leq I^{rated}_{l} \nonumber \\
\end{align}
```

In squared voltage magnitude variables:

```math
\begin{align*}
& \mbox{Total current from: }  (P_{lij})^2 + (Q_{lij})^2  \leq (I^{rated}_{l})^2 \cdot  w_{i} \nonumber \\
& \mbox{Total current to: }  (P_{lji})^2 + (Q_{lji})^2  \leq (I^{rated}_{l})^2 \cdot w_{j} \nonumber \\
\end{align*}
```

[^1] Gan, L., Li, N., Topcu, U., & Low, S. (2012). Branch flow model for radial networks: convex relaxation. 51st IEEE Conference on Decision and Control, 1–8. Retrieved from http://smart.caltech.edu/papers/ExactRelaxation.pdf
