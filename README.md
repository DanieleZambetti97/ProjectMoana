<img align="right" width="300" src="https://github.com/DanieleZambetti97/ProjectMoana/blob/master/examples/PM_logo_2.png">

# ProjectMoana :ocean::ocean:
[![Unit tests](https://github.com/DanieleZambetti97/ProjectMoana/actions/workflows/UnitTests.yml/badge.svg?branch=cameras)](https://github.com/DanieleZambetti97/ProjectMoana/actions/workflows/UnitTests.yml)
> “Sometimes our strengths lie beneath the surface … Far beneath, in some cases.”  [💬](https://www.youtube.com/watch?v=fZ3QhwgVOTU)

ProjectMoana is a Julia rendering program, able to generate images starting from a input text file (using the proper syntax).
The current stable version is 1.0.0.

## Requirements :heavy_exclamation_mark:

1. Running this program requires an installed version of Julia Language (v1.6 or higher, download [here](https://julialang.org/downloads/)); :heavy_check_mark:
2. This program requires a Linux/MacOS terminal to be run. If you are using a Windows machine we recommend you to install a [WSL](https://docs.microsoft.com/it-it/windows/wsl/install-win10). :heavy_check_mark:

## Installation :top:

1. Download the latest version tar.gz file from the ProjectMoana GitHub [repository](https://github.com/DanieleZambetti97/ProjectMoana/releases/tag/v1.0.0) or from the terminal
   
   ```bash
   wget https://github.com/DanieleZambetti97/ProjectMoana/archive/refs/tags/v1.0.0.tar.gz
   ```

> Note: check for the latest version on the repo and change to the current one in the above command.

2. Exctract the file in the directory you want to use the program:
   
   ```bash
   tar -xf v1.0.0.tar.gz -C /path/to/your/directory
   ```

3. From the Julia REPL import Pkg and activate the ProjectMoana package with the following commands:
   
   ```bash
   ~$ julia
   julia> using Pkg          # press ] to enter the package manager;
   (@v1.5) pkg> activate .
   (ProjectMoana) pkg>       # press backspace to exit;
   julia> Pkg.instantiate()  # this command will download and update the dependencies needed (it might take a while...);
   julia> exit()             # exiting the REPL.
   ```

## Usage :keyboard:

Just type:

```bash
julia render.jl [--help] [--scene SCENE_FILE] [--anim_var ANIMATION_VAR] [--w WIDTH] [--h HEIGHT] 
                         [--file_out FILENAME] [--render_alg ALG] [--a A] [--seq S] [--nrays NUM_OF_RAYS]
```

where
- `--scene` is the name of the input scene file where you can define Shapes and a Camera with their options;
- `--anim_var` is a variable usefull for animations (see chapter **Advanced tips: animation**);
- `--w` is the width of the image you want to generate (in pixels);
- `--h` is the height of the image (in pixels);
- `--file_out` is the name of the output file (without extension, e.g. `demo_out`);
- `--render_alg` is the type of rendering algortihm (On-Off, Flat, Path Tracer);
- `--a` is the `a_factor` used in the normalization of the image luminosity during the convertion to LDR;
- `--seq` is the sequence number for PCG generator;
- `--nrays` is the number of rays used for antialasing.

Do not worry about writing all the correct parameters! All of them are set to a default value and for a basic usage you only have to explicit the name of input file with the option `--scene`. 

## Input files: the correct syntax

We implemented a new (very simple😄) language for creating images inside ProjectMoana.  

### A simple example

## What can Moana do?

## Advanced tips: animations

## Contributing :recycle:

Since this is a WIP project [pull requests](https://github.com/DanieleZambetti97/ProjectMoana/pulls) are more than welcome. For major changes, please open an issue first to discuss what you would like to change.

## License :registered::copyright:

This program is under a [MIT](https://github.com/DanieleZambetti97/ProjectMoana/blob/master/LICENSE) license.
