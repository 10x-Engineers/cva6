# Getting Started Guide - IOPMP

## Working Directory

Create your folder in the Apollo Server working directory and work there.
Please make sure that you are not working in your HOME directory.
(Refers to [Getting Started - Apollo Server](https://docs.google.com/document/d/1L5ufvgY5zSrtO46lfiKHP0QEoSSrz3FiOEySHVC7CNA/edit?tab=t.0#heading=h.d9g4ijxee34d))

### Create working directory in `/work`:

```bash
cd /work
mkdir <username>
cd /work/<username>
```

---

## GitHub Repository

Open terminal in your working directory and clone the repository:
(Make sure you have the permissions as it is a private repository.)

```bash
git clone git@github.com:10x-Engineers/riscv-iopmp.git
```

---

## Compile and Run the Default Test

### Launch the C Shell

First, make sure you have the `cshrc` file in your working directory.
You can either make your own `cshrc` file or can copy it manually from `/work/urwa_maryam/` in your working directory.

Once done:

- Open a terminal in your working directory.
- Switch to the C shell by typing:

```bash
csh
```

- Inside C shell, load the environment settings by running:

```bash
source cshrc
```

This will set up all necessary environment variables.
Now you can issue commands, such as launching Cadence tools (`virtuoso &`).

---

### Switch Branch

Switch to `main` branch:

```bash
cd /work/<username>/riscv-iopmp/
git checkout main
```

---

### Navigate to the Test Directory

```bash
cd /work/<username>/riscv-iopmp/verif/iopmp_top/
```

---

### Compile and Run the Default Test

```bash
make full_model
```

---

## View Waveforms with Cadence SimVision

To open the simulation in GUI mode:

```bash
make full_model gui=1
```

Once SimVision opens:

- Click on the waveform icon in the top right corner to open the Waveform window.
- In the new window, on the left-hand side, click the "Browse the design hierarchy" and import the design signals you want to see.

---

## View Waveform with GTKWave (Alternative Option)

If you prefer to use GTKWave, after step 2, type:

```bash
gtkwave xrun_results/waveform.vcd
```

---

> **Note:**
> To run a different test other than the default, modify the file `Makefile_tests` located in `riscv-iopmp/verif/iopmp_top/`.

---

# IOPMP Models and Running Tests

IOPMP can be configured for **9 different models**.

To run a test for a specific model:

- Uncomment the test you want to run in `Makefile_tests` by removing the `#` at the beginning of its line.
- Then follow the same procedures as listed above.

---

### After modifying `Makefile_tests`

- To compile and run:

```bash
make isolation_model
```

- To open GUI:

```bash
make isolation_model gui=1
```

---

### Generic Command

- Without GUI:

```bash
make <model_name>
```

- With GUI:

```bash
make <model_name> gui=1
```

Where `<model_name>` could be one of:

- `full_model`
- `rapid_k_model`
- `dynamic_k_model`
- `isolation_model`
- `compact_k_model`
- `unnamed_model_1`
- `unnamed_model_2`
- `unnamed_model_3`
- `unnamed_model_4`
